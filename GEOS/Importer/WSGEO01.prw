#include "totvs.ch"
#include "protheus.ch"

/*
Job para execução da importação de pedidos do Geosales, por filial.
Ariane Galindo
02/09/2019
*/
User Function ZWSGEO1J()
	Local _cFunction := ""
	Local cQuery 	:= ""
	Local lJob		:= .F.
	Local cXAlias

	If Select("SX2")=0		//Se for via Schedule prepara o ambiente
		RpcSetType(2)
		RpcSetEnv("02","02010001")
		cUsername    := "GEOS01"
		__cUserId	 := "001568" 
		lJOb	:= .T.
	Endif
	
	cXAlias	:= GetNextAlias()

	cQuery := " SELECT ZZV.ZZV_DESCRI FILIAL "
	cQuery += " FROM " + RetSQLName('ZZV') + " ZZV "
	cQuery += " WHERE ZZV.ZZV_TABELA = 'FIL' " 
	cQuery += " AND ZZV.ZZV_CAMPNE <> '' "
	cQuery += " AND ZZV.ZZV_DESCRI <> '' "
	cQuery += " AND ZZV.D_E_L_E_T_ = ' ' "
	cQuery += " ORDER BY FILIAL "
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cXAlias, .T., .F. )

	While (cXAlias)->(!Eof())

		GetEmpr( "02" + AllTrim((cXAlias)->FILIAL) )  

		_cFunction := 'U_ZWSGEO1J' + cEmpAnt + cFilAnt
		If LockByName(_cFunction,.F.,.F.)	
			U_WSGEO01()
			UnLockByName(_cFunction)
		Else
			conout("[GEOSALES] - FUNÇÃO " + _cFunction + " JÁ ESTÁ EM EXECUÇÃO " + DTOC(DATE()) + " " + Time() + " ------------")
		EndIf

		(cXAlias)->(DbSkip())
	EndDo

	(cXAlias)->(DbCloseArea())
	
	If lJob
		RpcClearEnv()
	EndIf

Return 


/*/{Protheus.doc} WSGEO01
//TODO Descrição auto-gerada.
@author Miguel Franca
@since 19/03/2018
@version 1.0

@type function Servico para consumir o Web Services REST do GeoSales com padrao JSON e
em seguida importar o dados para o Protheus
/*/
User Function WSGEO01()
	Local cHostWS		:= U_getHost()												//HOST do servico
	Local cEmpHost		:= U_getEmpHost()
	Local cPath			:= U_getPathImp()
	Local cPathImp		:= "/" + cPath + "/" + cEmpHost + "/sync/pedido/"			//URL consumiro servico
	Local cPathAck		:= "/" + cPath + "/" + cEmpHost + "/ack/pedido/"			//URL confirmacao do servico
	Local oRestCli		:= FWRest():New(cHostWS)
	Local aHeader		:= U_getHeaders({"TOKEN","CONTENT"})						//Autenticacao do Servico
	Local lRet			:= .T.
	Local cStringJS		:= ""
	Local cFolSaida		:= ""
	Local cMsgSaida		:= ""
	Local nPed			:= 0

	Local cPedPalm		:= ""
	Local cStatus		:= ""
	Local cMsgErro		:= ""
	Local cPedErp		:= ""
	Local cBody			:= ""
	Local cEmpTemp		:= IIF(cEmpHost $ UPPER(GetEnvServer()),"02", "01")			//Controle empresa para teste JOB

	Private cEOL   		:= Chr(13) + Chr(10)
	Private aRetServ	:= {}
	Private nHeadPri	:= -1
	Private aLogGeo 	:= {cFilAnt,'SC5',,dDataBase,,'WSGEO01',"","",'GEOS',,,,cUserName,,'1','3',''} //CAMPNEUS 
/*
	If Select("SX2")=0		//Se for via Schedule prepara o ambiente
		RpcSetType(2)
		RpcSetEnv("02", "02010014")
	Endif
*/
	DirLog( @cFolSaida )	//Criar diretorio de LOG

	nHeadPri := MSFCreate(cFolSaida + "\LOG_WS\JSON_WSGEO01_FIL"+ cEmpAnt + cFilAnt + "_" + DToS(date()) + StrTran(time(),":","") + ".log", 0)

	Conout(" ***** WSGEO01 Preparando para consumir servico GeoSales! " + DToC(date()) + " " + time())
	
	If !LockByName("WSGEO01"+ cEmpAnt + cFilAnt,.T.,.T.)
		MsgInfo( " [WSGEO01"+ cEmpAnt + cFilAnt+"] Processamento ja iniciado por outra rotina!")
		Conout(  " [WSGEO01"+ cEmpAnt + cFilAnt+"] Processamento ja iniciado por outra rotina!")
		If nHeadPri <> -1
			FWrite(nHeadPri," [WSGEO01"+ cEmpAnt + cFilAnt+"] Processamento ja iniciado por outra rotina!" + cEOL )
			FClose(nHeadPri)
		EndIf
		Return
	EndIf

	//Adicionando o Pach para chamada do REST com retorno de lista
	oRestCli:setPath(cPathImp + cEmpAnt + cFilAnt)

	aLogGeo[10] := " URL Rest " + cHostWS + cPathImp + cEmpAnt + cFilAnt
	aLogGeo[14] := cHostWS + cPathImp + cEmpAnt + cFilAnt //URL
	aLogGeo[12] := "/sync/pedido/"

	If oRestCli:Get(aHeader) .OR. !Empty( oRestCli:GetResult() )
		cStringJS	:= oRestCli:GetResult()
		ConOut("GET SUCESSO", cStringJS)
		lRet		:= .T.

		aLogGeo[8] := "0"
		aLogGeo[11] := cStringJS

		Conout(" ***** Servico GeoSales consumido com sucesso! " + DToC(date()) + " " + time())
		If nHeadPri <> -1
			FWrite(nHeadPri," ***** Servico GeoSales consumido com sucesso! "+ DTOC(date()) + "-"+ time() +" "+ cEOL)
		EndIf
	Else
		cStringJS	:= oRestCli:GetLastError()
		ConOut("GET ERRO", cStringJS)
		lRet		:= .F.

		aLogGeo[8] := "1"
		aLogGeo[11] := cStringJS

		Conout(" ***** ERRO! Ao consumir servico GeoSales! " + DToC(date()) + " " + time())
		If nHeadPri <> -1
			FWrite(nHeadPri," ***** ERRO! Ao consumir servico GeoSales! "+ DTOC(date()) + "-"+ time() +" "+ cEOL)
		EndIf

		aLogGeo[5] := Time() //URL
		u_zzlog001( aLogGeo )
		Return lRet
	EndIf

	If nHeadPri <> -1
		FWrite(nHeadPri," **** JSON extraido pelo servico ["+ cFilAnt +"] "+ DTOC(date()) + "-"+ time() +" "+ cEOL +" JSON ORIGINAL: "+ cStringJS + cEOL + cEOL)
	EndIf

	If lRet
		cStringJS := StrTran(cStringJS, ",}", "}")
		cStringJS := StrTran(cStringJS, ",]", "]")
		cStringJS := StrTran(cStringJS, ",)", ")")
		If nHeadPri <> -1
			FWrite(nHeadPri," JSON AJUSTADO: "+ cStringJS + cEOL + cEOL)
		EndIf

		Conout(" ***** Iniciando o tratamento do Json " + DToC(date()) + " " + time())
		ParserJson(cStringJS, @cMsgSaida, cHostWS, cPathAck, aHeader)

	Else
		aLogGeo[8] := "1"
		aLogGeo[7] := 'Pedido não gravado.'
		aLogGeo[5] := Time() //URL
		u_zzlog001( aLogGeo )
	EndIf

	If lRet
		If nHeadPri <> -1
			FWrite(nHeadPri,Replicate("*",200) + cEOL + cEOL)
		EndIf

		cBody := ' { "PEDIDO": [ '

		For nPed := 1 To Len(aRetServ)
			cPedPalm	:= aRetServ[ nPed, 1] /*1-PEDPALM*/
			cStatus		:= aRetServ[ nPed, 2] /*2-STATUS*/
			cMsgErro	:= aRetServ[ nPed, 3] /*3-DESCRICAO*/
			cPedErp		:= aRetServ[ nPed, 4] /*4-PEDIDOERP*/

			If nHeadPri <> -1
				FWrite(nHeadPri,"	PEDPALM:	" + cPedPalm+ cEOL)
				FWrite(nHeadPri,"	STATUS:		" + cStatus + cEOL)
				FWrite(nHeadPri,"	DESCRICAO:	" +	StrTran(cMsgErro, "\n", CHR(13) + CHR(10) + Replicate("	",3) ) + cEOL + cEOL)
				FWrite(nHeadPri,"	PEDIDOERP:	" + cPedErp	+ cEOL + cEOL)
			EndIf

			cBody += ' { '
			cBody += '    "cd_pedido_palm": "'+	cPedPalm	+'", '
			cBody += '    "status": "'+ 		cStatus		+'", '
			cBody += '    "descricao": "'+		cMsgErro	+'", '
			cBody += '    "cd_pedido": "'+		cPedErp		+'" '
			If nPed < Len(aRetServ)
				cBody += ' }, '
			Else
				cBody += ' } '
			EndIf
		Next

		cBody += ' ] } '

		If nHeadPri <> -1
			FWrite(nHeadPri,Replicate("*",200) + cEOL + cEOL + "RETORNO:" + cEOL + cBody)
			FWrite(nHeadPri,"	Iniciando confirmacao no servico completo em " + time() + cEOL+ cEOL)
		EndIf

		//Adicionando o Pach para chamada do REST com retorno de lista
		oRestCli:setPath(cPathAck)

		//Define o conteúdo do body
		oRestCli:SetPostParams(cBody)

		//Confirmar pedidos importados
		If Len(aRetServ)>0
			If oRestCli:Post(aHeader)
				If nHeadPri <> -1
					FWrite(nHeadPri,cEOL + cEOL + "FINALIZADO POST SUCESSO " +  oRestCli:GetResult() +" "+ time() )
				EndIf

				ConOut("POST SUCESSO", oRestCli:GetResult())
			Else
				If nHeadPri <> -1
					FWrite(nHeadPri,cEOL + cEOL + "FINALIZADO POST ERRO " + oRestCli:GetLastError() +" "+ time() )
				EndIf

				ConOut("POST ERRO", oRestCli:GetLastError())
			EndIf
		EndIf
	EndIf

	If nHeadPri <> -1
		FClose(nHeadPri)
	EndIf

	UnLockByName("WSGEO01"+ cEmpAnt + cFilAnt,.T.,.T.)

	If Empty(cMsgSaida)
		Conout(" ***** WSGEO01 Nao foram encontrados informacoes para Processamento - FIL "+ cEmpAnt + cFilAnt )
	Else
		cMsgSaida	:=	Padr("Pedido GeoSales",21)+"|"+Padr("Status",12)+"|"+Padr("Observavacao/Arq log",60)+CRLF+;
		Replicate("-",93)+CRLF+;
		cMsgSaida
		cMsgSaida	:= "Log do Processamento de importacao " +CRLF+cMsgSaida+ CRLF
		MemoWrite(cFolSaida+"\LOG_"+DtoS(date())+"_"+StrTran(time(),":","")+".log", cMsgSaida)

		If !IsBlind()
			DEFINE FONT oFonte NAME "Courier New" SIZE 0,14 BOLD
			DEFINE MSDIALOG oDlg TITLE "Processamento concluido." From 3,0 to 340,700 PIXEL

			@ 5,5 GET oMemo  VAR cMsgSaida MEMO SIZE 350,145 OF oDlg PIXEL
			oMemo:bRClicked := {||AllwaysTrue()}
			oMemo:oFont:=oFonte

			DEFINE SBUTTON  FROM 153,175 TYPE 1 ACTION oDlg:End() ENABLE OF oDlg PIXEL

			ACTIVATE MSDIALOG oDlg CENTER
		EndIf
	EndIf

Return lRet

/*********************************************************************************
## Função: ParserJson(cRetJson)													##
## Autor: Miguel Franca															##
## Data: 19/03/2018																##
## Descricao: Funcao pra tratar o JSON e formata-lo para poder					##
## 			  importar para o Protheus.											##
**********************************************************************************/
Static Function ParserJson(cRetJson, cMsgSaida, cHostWS, cPathExp, aHeader)
	Local oJson := Nil
	Local aTipDat	:= {"C", "N", "D"}
	Local nI,nX,nJ,nQ,nK,nID,nIT,nPos := 0
	Local cFolSaida	:= ""
	Local cArqErr	:= ""
	Local nTimeOut	:= 120
	Local cHeadRet	:= ""
	Local sPostRet	:= ""
	Local cBody		:= ""
	//Controle Layout
	Local cArqPri	:= ""
	Local cArqChv	:= ""
	Local cTpImp	:= ""
	Local cExecAut	:= ""
	Local cCodLay	:= ""
	//Controle Arquivo
	Local cSeqArq	:= ""
	Local cTpArq	:= ""
	Local cArqOri	:= ""
	Local cArqDes	:= ""
	Local cQuery	:= ""
	//Controle Campos
	Local cSeqCpo	:= ""
	Local cCpoOri	:= ""
	Local cCpoFun	:= ""
	Local nCpoSpec	:= 0
	Local nCpoAte	:= 0
	Local nCpoTam	:= 0
	Local cCpoTip	:= ""
	Local cCpoDes	:= ""
	Local cAliasArq	:= ""
	//Controle inclusao
	Local cArqProc	:= ""
	Local aArqLay	:= {}
	Local cCtd		:= ""
	Local cChave 	:= ""
	Local cAliasProc:= ""
	Local cParExec	:= ""
	Local cVarExec	:= ""
	Local cStringEx	:= ""
	Local aArqProcAux := {}
	Local cValid	:= ""
	Local cNomVar	:= ""

	PRIVATE lMsErroAuto		:= .F.
	PRIVATE lAutoErrNoFile	:= .T.
	PRIVATE _cItem			:= ""

	If Empty(cRetJson)
		Conout(" ***** Valor JSON nao obtido. Retorno vazio do servico! " + DToC(date()) + " " + time())
		If nHeadPri <> -1
			FWrite(nHeadPri,"***** Valor JSON nao obtido. Retorno vazio do servico! " + DToC(date()) + " " + time() + cEOL)
		EndIf
		Return
	EndIf

	Conout(" ***** Serializando JSON GeoSales ... " + DToC(date()) + " " + time())

	//Criar diretorio de LOG
	DirLog( @cFolSaida )
	cMsgSaida := ""

	If FWJsonDeserialize(cRetJson,@oJson)
		&("oBJ") := oJson

		Conout(" ***** Verificando layout de importacao Filial ["+ cEmpAnt + cFilAnt +"]! " + DToC(date()) + " " + time())

		dbSelectArea("I02")
		dbSetOrder(1)
		dbSeek(xFilial("I02"))

		While I02->( !Eof() ) .AND. I02->I02_FILIAL == xFilial("I02")

			If I02->I02_STATUS <> "1" //Pedido
				I02->( DbSkip() )
				Loop
			Endif

			cCodLay	:= I02->I02_CODLAY
			cTpImp	:= I02->I02_TIPIMP
			cArqPri	:= Alltrim(I02->I02_ARQPRI)
			cArqChv	:= Alltrim(I02->I02_CHAVE)
			cExecAut:= Alltrim(I02->I02_EXECAU)
			cSeqArq	:= ""
			cValid	:= ""
			aArqLay	:= {}

			dbSelectArea("I03")
			I03->( dbSetOrder(1) )
			I03->( dbSeek(xFilial("I03") + cCodLay) )

			While I03->( !Eof() ) .AND. I03->I03_FILIAL == xFilial("I03") .AND. I03->I03_CODLAY == cCodLay

				cSeqArq				:= I03->I03_SEQARQ
				cTpArq				:= I03->I03_TPARQ
				cArqOri				:= Alltrim(I03->I03_ARQORI)
				cArqDes				:= I03->I03_ARQDES
				cQuery				:= I03->I03_QUERY
				cSeqCpo				:= ""
				cAliasArq			:= Alltrim(cArqOri)
				cValid				:= IIF(cSeqArq=="001", cQuery, cValid)

				cNomVar := "aCpo"+cAliasArq
				SetPrvt(cNomVar)

				&("aCpo"+cAliasArq)	:= {}

				dbSelectArea("I04")
				dbSetOrder(1)
				dbSeek(xFilial("I04") + cCodLay + cSeqArq)

				While I04->( !Eof() ) .AND. I04->I04_FILIAL == xFilial("I04") .AND. I04->I04_CODLAY == cCodLay .AND. I04->I04_SEQARQ == cSeqArq

					cSeqCpo := I04->I04_SEQCPO
					cCpoOri	:= I04->I04_CPOORI
					cCpoFun	:= Alltrim(I04->I04_FUNC)
					nCpoSpec:= Alltrim(I04->I04_CPODE)
					nCpoAte	:= I04->I04_CPOATE
					nCpoTam	:= I04->I04_TAMANH
					nCpoDec	:= I04->I04_DECIMA
					cCpoTip	:= aTipDat[Val(I04->I04_TIPDAT)]
					cCpoDes	:= I04->I04_CPODES

					aadd(&("aCpo"+cAliasArq),{cCpoOri, cCpoFun, cCpoDes, cCpoTip, nCpoTam, nCpoDec, nCpoSpec })

					I04->( DbSkip() )
				EndDo

				aadd(aArqLay, {cAliasArq,cArqDes,cQuery})

				I03->( DbSkip() )
			EndDo

			If !( TYPE( "oBJ:"+cArqPri ) != "U" .AND. Len( &("oBJ:"+cArqPri) ) > 0 )
				Conout( " ***** Objeto "+ cArqPri +" nao encontrado valor. "+ DToS(date()) + time() )
				If nHeadPri <> -1
					FWrite(nHeadPri," ***** Objeto "+ cArqPri +" nao encontrado valor. "+ DToS(date()) + time() + cEOL + cEOL)
				EndIf
				I02->( DbSkip() )
				Loop
			EndIf

			For nID := 1 To Len( &("oBJ:"+cArqPri) )

				If !Empty(cValid)
					If !( &(StrTran( UPPER(cValid), "#NID", cValToChar(nID) )) )	//Validar dados de acordo com campo Query
						Loop
					EndIf
				EndIf

				lMsErroAuto		:= .F.
				lAutoErrNoFile	:= .T.
				cArqProc		:= "001"
				&("a"+cArqProc)	:= {}
				cChave			:= Alltrim( &("oBJ:"+ cArqPri +"["+ cValToChar(nID) +"]"+":"+ cArqChv) )
				cMsgSaida		+= Padr(cChave,21)+"|"

				If nHeadPri <> -1
					FWrite(nHeadPri," ***** Importando "+ Lower(StrTran(cArqPri,"_"," ")) +"-"+ cChave +" "+ DToS(date()) + time() + cEOL)
				EndIf

				For nI:=1 to len(&("aCpo"+cArqPri))
					If !Empty(&("aCpo"+cArqPri)[nI,2])
						cCtd := &("aCpo"+cArqPri)[nI,2]
						cCtd := StrTran(cCtd, cArqPri +":", "oBJ:"+ cArqPri +"["+ cValToChar(nID) +"]"+":")
					Else
						cCtd := &("aCpo"+cArqPri)[nI,1]
						cCtd := "oBJ:"+ cArqPri +"["+ cValToChar(nID) +"]"+":" + cCtd
					EndIf

					If Empty(&("aCpo"+cArqPri)[nI,7])	//Verificar se "campo de" estiver vazio
						For nX := 1 To Len(cCtd)		//Analisa se existe atributos no oBJ
							cCtdTmp := SubStr(cCtd, nX, Len(cCtd))
							cObjTmp := "oBJ:"+ cArqPri +"["+ cValToChar(nID) +"]"+":"
							If at(cObjTmp, cCtdTmp) > 0
								nPos := at(cObjTmp, cCtdTmp)
								cCtdTmp := SubStr(cCtdTmp, nPos, Len(cCtdTmp) )
								for nJ := (Len(cObjTmp) + 1) To Len(cCtdTmp)
									If Empty( SubStr(cCtdTmp, nJ, 1 ) )
										exit
									ElseIf IsDigit( SubStr(cCtdTmp, nJ, 1 ) )
										loop
									ElseIf IsAlpha( SubStr(cCtdTmp, nJ, 1 ) )
										loop
									ElseIf SubStr(cCtdTmp, nJ, 1 ) == "_"
										loop
									EndIf
									exit
								next
								nX += (nJ -1)
								If !Empty( SubStr(cCtdTmp, (Len(cObjTmp) + 1), nJ - (Len(cObjTmp)+1) ) )
									If !( AttIsMemberOf( &(SubStr(cObjTmp, 1, Len(cObjTmp)-1 ) ) , SubStr(cCtdTmp, (Len(cObjTmp) + 1), nJ - (Len(cObjTmp)+1) ) ) )
										cCtd := StrTran(cCtd, SubStr(cCtdTmp, 1, nJ - 1 ), '""')
									EndIf
								EndIf
							Else
								Exit
							EndIf
						Next
					EndIf

					cCtd := &cCtd

					aadd(&("a"+cArqProc),{Alltrim(&("aCpo"+cArqPri)[nI,3]),cCtd,nil})
				Next

				For nI:=1 to len(aArqLay)
					If aArqLay[nI,1] <> cArqPri
						cArqProc		:= Soma1(cArqProc)
						&("a"+cArqProc)	:= {}
						cAliasProc		:= aArqLay[nI,1]
						_cItem			:= "00"

						If !( TYPE( "oBJ:"+cAliasProc ) != "U" .AND. Len( &("oBJ:"+cArqPri) ) > 0 )
							Conout( " ***** Objeto "+ cAliasProc +" nao encontrado valor. "+ DToS(date()) + time() )
							Loop
						EndIf

						For nIT := 1 To Len( &("oBJ:"+cAliasProc) )
							If !( Alltrim( &( "oBJ:"+ cAliasProc +"["+ cValToChar(nIT) +"]"+":" + cArqChv ) ) == cChave )
								Loop
							EndIf

							aArqProcAux := {}
							_cItem		:= Soma1(_cItem)

							For nK :=1 to len(&("aCpo"+cAliasProc))
								If !Empty(&("aCpo"+cAliasProc)[nK,2])
									cCtd := &("aCpo"+cAliasProc)[nK,2]
									cCtd := StrTran(cCtd, cAliasProc +":", "oBJ:"+ cAliasProc +"["+ cValToChar(nIT) +"]"+":")
									cCtd := StrTran(cCtd, cArqPri +":", "oBJ:"+ cArqPri +"["+ cValToChar(nID) +"]"+":")
								Else
									cCtd := &("aCpo"+cAliasProc)[nK,1]
									cCtd := "oBJ:"+ cAliasProc +"["+ cValToChar(nIT) +"]"+":" + cCtd
								EndIf

								If Empty(&("aCpo"+cAliasProc)[nK,7])	//Verificar se "campo de" estiver vazio
									For nQ := 1 To 2					//Analisa OBJ principal e secundario
										For nX := 1 To Len(cCtd)		//Analisa se existe atributos no oBJ
											cCtdTmp := SubStr(cCtd, nX, Len(cCtd))
											cObjTmp := IIF( nQ <= 1, "oBJ:"+ cAliasProc +"["+ cValToChar(nIT) +"]"+":", "oBJ:"+ cArqPri +"["+ cValToChar(nID) +"]"+":")
											If at(cObjTmp, cCtdTmp) > 0
												nPos := at(cObjTmp, cCtdTmp)
												cCtdTmp := SubStr(cCtdTmp, nPos, Len(cCtdTmp) )
												for nJ := (Len(cObjTmp) + 1) To Len(cCtdTmp)
													If Empty( SubStr(cCtdTmp, nJ, 1 ) )
														exit
													ElseIf IsDigit( SubStr(cCtdTmp, nJ, 1 ) )
														loop
													ElseIf IsAlpha( SubStr(cCtdTmp, nJ, 1 ) )
														loop
													ElseIf SubStr(cCtdTmp, nJ, 1 ) == "_"
														loop
													EndIf
													exit
												next
												nX += (nJ - 2)
												If !Empty( SubStr(cCtdTmp, (Len(cObjTmp) + 1), nJ - (Len(cObjTmp)+1) ) )
													If !( AttIsMemberOf( &(SubStr(cObjTmp, 1, Len(cObjTmp)-1 ) ) , SubStr(cCtdTmp, (Len(cObjTmp) + 1), nJ - (Len(cObjTmp)+1) ) ) )
														cCtd := StrTran(cCtd, SubStr(cCtdTmp, 1, nJ - 1 ), '""')
													EndIf
												EndIf
											Else
												Exit
											EndIf
										Next
									Next
								EndIf

								cCtd := &(cCtd)

								aadd(aArqProcAux,{Alltrim(&("aCpo"+cAliasProc)[nK,3]),cCtd,nil})
							Next

							If Len(aArqProcAux) > 0
								aadd(&("a"+cArqProc),aArqProcAux)
							EndIf

						Next
					EndIf
				Next

				If !PedDuplic( cChave, 1 )
					cVarExec := ""
					cParExec := ""
					For nI:=1 to len(aArqLay)
						cParExec += ","+"a"+StrZero(nI,3)
						If Empty(cVarExec)
							cVarExec := "a,"
						Else
							cVarExec += Soma1(SubStr(cVarExec,Len(cVarExec)-1,1))+","
						Endif
					Next

					cStringEx := "MSExecAuto({|"+cVarExec+"z| "+cExecAut+"("+cVarExec+"z)}"+cParExec+",3)"

					&(cStringEx)

					If lMsErroAuto

						aLogGeo[3] := cChave
						aLogGeo[7] := "1"
						aLogGeo[5] := Time()

						If !PedDuplic( cChave, 1 )
							RollBackSx8()
							cArqErr		:= cFolSaida+"\"+Alltrim(cChave)+"_"+DtoS(date())+".err"
							aLog		:= GetAutoGRLog()
							nHandle		:= 0
							lRetLog		:= .F.
							cMsgSaida	+= Padr("sem sucesso",12)+"|"+Padr(cArqErr,80)+CRLF

							If !File(cArqErr) //Criando arquivo LOG
								If (nHandle := MSFCreate(cArqErr,0)) <> -1
									lRetLog := .T.
								EndIf
							Else
								If (nHandle := FOpen(cArqErr,2)) <> -1
									FSeek(nHandle,0,2)
									lRetLog := .T.
								EndIf
							EndIf

							Conout(cArqErr)
							aLogGeo[7] := cArqErr

							cArqErr	:= ""
							If	lRetLog
								For nX := 1 To Len(aLog)
									FWrite(nHandle, aLog[nX] + CHR(13) + CHR(10) )
									cArqErr	+= aLog[nX] + " \n "
									cArqErr := StrTran(cArqErr,CHR(13) + CHR(10), " \n ")
								Next nX
								FClose(nHandle)
								Conout(cArqErr)
							EndIf

							/*		//Salvar LOG de importacao na tabela I07
							DbSelectArea("I07")
							I07->( DbSetOrder(1) )
							I07->( DbSeek(xFilial("I07") + cChave ) )
							If Found()
							RecLock("I07", .F. )
							Else
							RecLock("I07", .T. )
							I07->I07_FILIAL	:= xFilial("I07")
							I07->I07_CDPALM	:= cChave
							EndIf
							I07->I07_SEQUEC	:= "001"
							I07->I07_DTIMPR	:= date()
							I07->I07_LOG	:= StrTran(cArqErr, "\n", CHR(13) + CHR(10) )
							I07->I07_VEND	:= " "
							I07->I07_CLIENT	:= " "
							MsUnLock() //Confirma e finaliza a operação       */   


							//Salvar dados em objeto para retorno ao Geosales
							AADD(aRetServ,{	cChave 	/*1-PEDPALM*/		,;
							"FALHA" /*2-STATUS*/		,;
							NoAcento(cArqErr) /*3-DESCRICAO*/	,;
							Space(6)/*4-PEDIDOERP*/	})

						Else//Salvar dados em objeto para retorno ao Geosales
							cArqErr := "PEDIDO JA IMPORTADO PARA ERP"
							aLogGeo[7] := cArqErr + cChave 
							AADD(aRetServ,{	cChave					/*1-PEDPALM*/	,;
							"OK"					/*2-STATUS*/	,;
							NoAcento(cArqErr)		/*3-DESCRICAO*/	,;
							PedDuplic( cChave, 2 )	/*4-PEDIDOERP*/	})

							cMsgSaida += Padr("com sucesso",12)+"|"+Padr("Pedido UPD: "+ aRetServ[Len(aRetServ), 4] ,60)+CRLF
						EndIf

						u_zzlog001(aLogGeo)

					Else//Salvar dados em objeto para retorno ao Geosales						
						cArqErr := "PEDIDO IMPORTADO COM SUCESSO"
						AADD(aRetServ,{	cChave					/*1-PEDPALM*/	,;
						"OK"					/*2-STATUS*/	,;
						NoAcento(cArqErr)		/*3-DESCRICAO*/	,;
						Alltrim(SC5->C5_NUM)	/*4-PEDIDOERP*/	})

						cBody := '{ "PEDIDO": [ '
						cBody += ' { '
						cBody += '    "cd_pedido_palm": "'+	cChave					+'", '
						cBody += '    "status": "'+ 		"OK"					+'", '
						cBody += '    "descricao": "'+		NoAcento(cArqErr)		+'", '
						cBody += '    "cd_pedido": "'+		Alltrim(SC5->C5_NUM)	+'" '
						cBody += ' } '
						cBody += '] } '

						If nHeadPri <> -1
							FWrite(nHeadPri,Replicate("*",200) + cEOL + cBody+ cEOL)
							FWrite(nHeadPri,"	Iniciando confirmacao no servico parcial em " + time() + cEOL+ cEOL)
						EndIf

						aLogGeo[3] := cChave
						aLogGeo[8] := "0"
						aLogGeo[5] := Time()
						aLogGeo[7] := cArqErr + Alltrim(SC5->C5_NUM)

						u_zzlog001(aLogGeo)

						sPostRet := HttpPost(cHostWS+cPathExp,"",cBody,nTimeOut,aHeader,@cHeadRet)
						If !Empty(sPostRet)
							Conout("HttpPost Ok ["+ cHeadRet +"]-> " + time())
							If nHeadPri <> -1
								FWrite(nHeadPri,"	Finalizado HttpPost Ok ["+ cHeadRet +"]-> " + time() + cEOL+ cEOL)
							EndIf
						Else
							conout("HttpPost Failed. ["+ cHeadRet +"]-> " + time())
							If nHeadPri <> -1
								FWrite(nHeadPri,"	Finalizado HttpPost Failed ["+ StrTran(cHeadRet,cEOL," ") +"]-> " + time() + cEOL+ cEOL)
							EndIf
						Endif

						cMsgSaida += Padr("com sucesso",12)+"|"+Padr("Pedido "+Alltrim(SC5->C5_NUM),60)+CRLF
					EndIf
				Else//Salvar dados em objeto para retorno ao Geosales
					cArqErr := "PEDIDO JA IMPORTADO PARA ERP"
					AADD(aRetServ,{	cChave					/*1-PEDPALM*/	,;
					"OK"					/*2-STATUS*/	,;
					NoAcento(cArqErr)		/*3-DESCRICAO*/	,;
					PedDuplic( cChave, 2 )	/*4-PEDIDOERP*/	})

					cMsgSaida += Padr("com sucesso",12)+"|"+Padr("Pedido UPD: "+ aRetServ[Len(aRetServ), 4] ,60)+CRLF

					aLogGeo[3] := cChave
					aLogGeo[8] := "0"
					aLogGeo[5] := Time()
					aLogGeo[7] := cMsgSaida

				Endif
			Next

			I02->( DbSkip() )
		EndDo

	Else
		aLogGeo[8] := "1"
		aLogGeo[5] := Time()
		aLogGeo[7] := "Nao foi possivel realizar a deserializacao do JSON."

		Conout(" ***** Nao foi possivel realizar a deserializacao do JSON. " + DToC(date()) + " " + time())
		If nHeadPri <> -1
			FWrite(nHeadPri," ***** Nao foi possivel realizar a deserializacao do JSON." + DToC(date()) + " " + time())
		EndIf
	EndIf

	aLogGeo[5] := Time()
	u_zzlog001(aLogGeo)
	
	Conout(" ***** Fim da importacao dos pedidos - FIL "+ cEmpAnt + cFilAnt +" ! "+DTOC(date())+" - "+time())
	If nHeadPri <> -1
		FWrite(nHeadPri," ***** Fim da importacao dos pedidos - FIL "+ cEmpAnt + cFilAnt +" ! "+ DToS(date()) + time() + cEOL)
	EndIf

Return

/*********************************************************************************
## Função: verObjIT(oBJ, aPesq, cCampo, lSomar)									##
## Autor: Miguel Franca															##
## Data: 19/03/2018																##
## Descricao: Localizar valor do atributo de outro objeto no mesmo JSON			##
## Exemplo 1: verObjIT(Objeto, {{Campo,pesquisa}} , Campo /*Retorno/)			##
## Exemplo 2: verObjIT(oBJ:ITEM_PEDIDO_DESCONTO, 								##
##  			 			{ { "CD_PEDIDO_PALM", PEDIDO->CD_PEDIDO_PALM},		##
##  			 			  { "NR_ITEM_PEDIDO", ITEM_PEDIDO->NR_ITEM_PEDIDO},	##
##  			 			  { "DS_DESCONTO", "abatimento_frete_kg"}	},		##
##  			 			"VR_DESCONTO" /*RETORNO/)							##
**********************************************************************************/
Static Function verObjIT(oBJ, aPesq, cCampo, lSomar)
	Local xRet := 0
	Local lRet := .F.
	Local nX,nY
	Default lSomar := .F.

	for nX := 1 to len(oBJ)
		&("oOB1")	:= oBJ[nX]
		lRet		:= .T.

		for nY := 1 to len(aPesq)
			If !( Alltrim( UPPER( &("oOB1:" + aPesq[nY][1]) ) ) == Alltrim( UPPER( aPesq[nY][2] ) ) )
				lRet := .F.
				Exit
			EndIf
		next

		If lRet
			If AttIsMemberOf( &("oOB1"), cCampo )
				If lSomar
					xRet +=  &("oOB1:" + cCampo )
				Else
					xRet :=  &("oOB1:" + cCampo )
					Exit
				EndIf
			Else
				If lSomar
					xRet += 0
				Else
					xRet := 0
					Exit
				EndIf
			EndIf
		EndIf

	next

Return xRet


/*********************************************************************************
## Função: verObjX(oBJ, cValorVld, cCampoVld, cCampoRet)						##
## Autor: Miguel Franca															##
## Data: 19/03/2018																##
## Descricao: Localizar valor do atributo de outro objeto no mesmo JSON			##
## Exemplo 1: verOrgVenda(oBJ:CLIENTE_ORGANIZACAO_APROVACAO_PROSPECT,			##
##  			 			oBJ:CLIENTE_APROVACAO_PROSPECT[1]:CD_APROVACAO,		##
##  			 			"CD_APROVACAO"										##
##  			 			"CD_ORG_VENDA")										##
**********************************************************************************/
Static Function verObjX(oBJ, cValorVld, cCampoVld, cCampoRet)
	Local xRet :=""
	Local nX
	Local nY

	&("verObjX")	:= oBJ

	for nX := 1 to len( &("verObjX") )
		If &("verObjX["+cValToChar(nX)+"]:"+cCampoVld) == cValorVld
			xRet := &("verObjX["+cValToChar(nX)+"]:"+cCampoRet)
		EndIf
	next

Return xRet

/*********************************************************************************
## Função: GPedDuplic( cPedPalm, nTipoRet )										##
## Autor: Miguel Franca															##
## Data: 26/05/2015																##
## Descricao: PedDuplic - Rotina para verificar se pedido GeoSales ja existe	##
## Parametro: nTipoRet- 1:So verificar / 2:Retorna no numero do ERP				##
**********************************************************************************/
Static Function PedDuplic( cPedPalm, nTipoRet )
	Local cQuery	:= ""
	Local cAliasTRB
	Local xRet

	cQuery		:= " SELECT MAX(C5_NUM) TPPED "
	cQuery		+= " FROM " + RetSqlName("SC5") + " "
	cQuery		+= " WHERE C5_YCDPALM = '"+ cPedPalm +"' "
	cAliasTRB	:= MPSysOpenQuery(cQuery)

	If !(cAliasTRB)->( EOF() ) .AND. !Empty( (cAliasTRB)->TPPED )
		xRet := IIF( nTipoRet == 1, .T., (cAliasTRB)->TPPED )
	Else
		xRet := IIF( nTipoRet == 1, .F., Space(6) ) //Caso nao exista o pedido
	EndIf

Return xRet

/*********************************************************************************
## Função: GetHash(oBj,xKey,xDefault)											##
## Autor: Miguel Franca															##
## Data: 19/03/2018																##
## Descricao: Localizar valor do atributo do objeto								##
**********************************************************************************/
Static function GetHash(oBj,xKey,xDefault)
	Local xValor	:= nil
	If !oBj:Get(xKey,@xValor)
		return xDefault
	EndIf
return xValor

/*********************************************************************************
## Função: DirLog( cFolSaida )													##
## Autor: Miguel Franca															##
## Data: 19/03/2018																##
## Descricao: Criar diretorio especiico para salvar o log de precessamento		##
**********************************************************************************/
Static function DirLog( cFolSaida )
	cFolSaida := "\log_softsite"

	If !ExistDir(cFolSaida)
		Makedir(cFolSaida)
	EndIf

	cFolSaida += "\pedido_venda_ws"

	If !ExistDir(cFolSaida)
		Makedir(cFolSaida)
	EndIf

	cFolSaida += "\"+StrZero(month(date()),2)+Alltrim(Str(year(date())))

	If !ExistDir(cFolSaida)
		Makedir(cFolSaida)
	EndIf

	cFolSaida += "\"+StrZero(day(date()),2)

	If !ExistDir(cFolSaida)
		Makedir(cFolSaida)
	EndIf

	cFolSaida += "\"+ cEmpAnt + cFilAnt

	If !ExistDir(cFolSaida)
		Makedir(cFolSaida)
	EndIf

	If !ExistDir(cFolSaida + "\log_ws")
		Makedir(cFolSaida + "\log_ws")
	EndIf

Return


/*
Autor: David de Oliveira Sobrinho
Data: 21/07/2013
Descrição: WSGEO01B - Rotina de importação de dados de acordo layout cadastrados
*/
User Function WSGEO01B(aParSch)
	//Variáveis auxiliares da tela de processamento
	Local bProcess	:= {|oSelf| U_WSGEO01(oSelf)  }
	Local cNomFun	:= "Integração Pedido Protheus x GeoSales [IMPORTAÇÃO]"
	Local cObjetivo	:= "Esta rotina tem o objetivo de importar dados do sistema GeoSales via Web Services Rest."
	Local lLog		:= .F.
	Local _lJob 	:= (Select('SX6')==0)
	Local aPar		:= {}
	Local nI		:= 0
	Local nPos		:= 0

	Private oTProces

	Default aParSch	:= {}

	If Len(aParSch) >= 1
		aPar	:= aParSch //aClone(aParSch[1])
		aUsers	:= GetUserInfoArray()
		nPos	:= 0

		aEval(aUsers,{|x| iif("U_SFTIMPWS" $ x[11] .and. x[3] <> ThreadID(),nPos++,nil)  })

		If nPos <= 0
			For nI := 1 to Len(aPar)
				conout(" Inicio Processamento Imp "+aPar[nI,1]+"/"+aPar[nI,2]+"-"+Time())

				RpcSetType(2)
				RpcSetEnv(aPar[nI,1],aPar[nI,2])

				U_WSGEO01()

				RpcClearEnv()
				conout(" Fim Processamento Imp "+aPar[nI,1]+"/"+aPar[nI,2]+"-"+Time())
			Next
		Endif
	Else
		//tela de processamento
		oTProces := 	tNewProcess():New(	"WSGEO01B",;
		cNomFun,;
		bProcess,;
		cObjetivo,;
		nil,;
		nil,;
		nil,;
		nil,;
		nil,;
		nil,;
		.T.)
		oTProces:SaveLog("Resultado de Processamento")
	EndIf

Return .T.
