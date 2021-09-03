#include "totvs.ch"
#include "protheus.ch"

/*/{Protheus.doc} WSGEO02 - CLIENTE PROSPECT
//TODO Descrição auto-gerada.
@author Miguel Franca
@since 19/03/2018
@version 1.0

@type function Servico para consumir o Web Services REST do GeoSales com padrao JSON e
		em seguida importar o dados para o Protheus
/*/
User Function WSGEO02()
Local cHostWS		:= U_getHost()												//HOST do servico
Local cEmpHost		:= U_getEmpHost()
Local cPath			:= U_getPathImp()
Local cPathImp		:= "/" + cPath + "/" + cEmpHost + "/sync/cliente-prospect/"	//URL consumiro servico
Local cPathAck		:= "/" + cPath + "/" + cEmpHost + "/ack/cliente-prospect/"	//URL confirmacao do servico
Local oRestCli		:= FWRest():New(cHostWS)
Local aHeader		:= U_getHeaders({"TOKEN","CONTENT"})						//Autenticacao do Servico
Local cTabImp		:= "SUS" 													//Entidade para vincular cliente x contato na AC8
Local lRet			:= .T.
Local cStringJS		:= ""
Local cFolSaida		:= ""
Local cMsgSaida		:= ""
Local nTemp, nCli	:= 0

Local cCliAprov		:= ""
Local cStatus		:= ""
Local cMsgErro		:= ""
Local cCliErp		:= ""
Local aRefErp		:= {}
Local aSocErp		:= {}
Local cBody			:= ""
Local cEmpTemp		:= IIF(cEmpHost $ UPPER(GetEnvServer()),"02", "01")			//Controle empresa para teste JOB
Local lServFil		:= IIF(cEmpTemp=="02",.F., .T. )							//Controle empresa para teste JOB

Private cEOL   		:= Chr(13) + Chr(10)
Private aRetServ	:= {}
Private nHeadPri	:= -1

If Select("SX2")=0   //Se for via Schedule prepara o ambiente
	RpcSetType(2)
	RpcSetEnv(cEmpTemp, "02")
Endif

//Criar diretorio de LOG
DirLog( @cFolSaida )

nHeadPri := MSFCreate(cFolSaida + "\LOG_WS\JSON_WSGEO02_FIL"+ cEmpAnt + cFilAnt + "_" + DToS(date()) + StrTran(time(),":","") + ".log", 0)

Conout(" ***** WSGEO02 Preparando para consumir servico GeoSales! " + DToC(date()) + " " + time())

If !LockByName("WSGEO02"+ cEmpAnt + cFilAnt,.T.,.T.)
	MsgInfo("  [WSGEO02"+ cEmpAnt + cFilAnt+"] Processamento ja iniciado por outra rotina!")
	Conout("   [WSGEO02"+ cEmpAnt + cFilAnt+"] Processamento ja iniciado por outra rotina!")
	If nHeadPri <> -1
		FWrite(nHeadPri," [WSGEO02"+ cEmpAnt + cFilAnt+"] Processamento ja iniciado por outra rotina!" + cEOL )
		FClose(nHeadPri)
	EndIf
	Return
EndIf

//Adicionando o Pach para chamada do REST com retorno de lista
oRestCli:setPath(cPathImp + IIF(lServFil, cEmpAnt + cFilAnt, "") )

If oRestCli:Get(aHeader) .OR. !Empty( oRestCli:GetResult() )
	cStringJS	:= oRestCli:GetResult()
	ConOut("GET SUCESSO", cStringJS)
	lRet		:= .T.

	Conout(" ***** Servico GeoSales consumido com sucesso! " + DToC(date()) + " " + time())
	If nHeadPri <> -1
		FWrite(nHeadPri," ***** Servico GeoSales consumido com sucesso! "+ DTOC(date()) + "-"+ time() +" "+ cEOL)
	EndIf
Else
	cStringJS	:= oRestCli:GetLastError()
	ConOut("GET ERRO", cStringJS)
	lRet		:= .F.
	Conout(" ***** ERRO! Ao consumir servico GeoSales! " + DToC(date()) + " " + time())
	If nHeadPri <> -1
		FWrite(nHeadPri," ***** ERRO! Ao consumir servico GeoSales! "+ DTOC(date()) + "-"+ time() +" "+ cEOL)
	EndIf
	Return lRet
EndIf

//add ACCESS
//u_setAccess("WSGEO02")

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
EndIf

If lRet
	If nHeadPri <> -1
		FWrite(nHeadPri,Replicate("*",200) + cEOL + cEOL)
	EndIf

	cBody := ' { "CLIENTE_APROVACAO_PROSPECT": [ '

	For nCli := 1 To Len(aRetServ)
		cCliAprov	:= aRetServ[ nCli, 1] /*1-CLIAPRV*/
		cStatus		:= aRetServ[ nCli, 2] /*2-STATUS*/
		cMsgErro	:= aRetServ[ nCli, 3] /*3-DESCRICAO*/
		cCliErp		:= aRetServ[ nCli, 4] /*4-CODIGO ERP*/
		aRefErp		:= aRetServ[ nCli, 5] /*5-REFERENCIA ERP*/
		aSocErp		:= aRetServ[ nCli, 6] /*6-SOCIO ERP*/

		If nHeadPri <> -1
			FWrite(nHeadPri,Replicate("=",100)+ cEOL)
			FWrite(nHeadPri,Replicate("<",25) +" CHAVE: "+ cCliAprov +" "+ Replicate(">",25)+ cEOL)
			FWrite(nHeadPri,"	CLIAPRV:	" +		cCliAprov+ cEOL)
			FWrite(nHeadPri,"	STATUS:		" +		cStatus  + cEOL)
			FWrite(nHeadPri,"	CLIENTE ERP:	" +	cCliErp	 + cEOL)
		EndIf

		If .NOT. Empty(cCliErp)
			For nTemp := 1 To Len(aRefErp)
				If nHeadPri <> -1
					FWrite(nHeadPri,"		REFERENCIA ERP:	" + aRefErp[ nTemp, 2 ]	+"/"+ aRefErp[ nTemp, 1 ] 	+"/"+ aRefErp[ nTemp, 3 ] + cEOL)
					FWrite(nHeadPri,"			( Vincular cliente X contato ["+ cCliErp +"] X ["+ aRefErp[ nTemp, 1 ] +"] / ["+ cTabImp +"] " + DToC(date()) +" "+ time() +" ) " + cEOL)
				EndIf

				If aRefErp[ nTemp, 3 ] == "OK"
					Conout(" **** Vincular cliente X contato ["+ cCliErp +"] X ["+ aRefErp[ nTemp, 1 ] +"] / ["+ cTabImp +"] " + DToC(date()) +" "+ time() )
					CliXCont(cCliErp, aRefErp[ nTemp, 1 ], cTabImp, nHeadPri)
				EndIf
			Next
			For nTemp := 1 To Len(aSocErp)
				If nHeadPri <> -1
					FWrite(nHeadPri,"		SOCIO ERP:	" + aSocErp[ nTemp, 2 ]	+"/"+ aSocErp[ nTemp, 1 ] 	+"/"+ aSocErp[ nTemp, 3 ] + cEOL)
					FWrite(nHeadPri,"			( Vincular cliente X contato ["+ cCliErp +"] X ["+ aSocErp[ nTemp, 1 ] +"] / ["+ cTabImp +"] " + DToC(date()) +" "+ time() +" ) " + cEOL)
				EndIf

				If aSocErp[ nTemp, 3 ] == "OK"
					Conout(" **** Vincular cliente X contato ["+ cCliErp +"] X ["+ aSocErp[ nTemp, 1 ] +"] / ["+ cTabImp +"] " + DToC(date()) +" "+ time() )
					CliXCont(cCliErp, aSocErp[ nTemp, 1 ], cTabImp, nHeadPri)
				EndIf
			Next
		EndIf

		If nHeadPri <> -1
			FWrite(nHeadPri,"	DESCRICAO:	" +	StrTran(cMsgErro, "\n", CHR(13) + CHR(10) + Replicate("	",3) ) + cEOL + cEOL)
			FWrite(nHeadPri,cEOL)
		EndIf

		cBody += ' { '
		cBody += '    "cd_aprovacao": "'+	cCliAprov	+'", '
		cBody += '    "status": "'+ 		cStatus		+'", '
		cBody += '    "descricao": "'+		cMsgErro	+'", '
		cBody += '    "cd_cliente": "'+		cCliErp		+'" '
		If nCli < Len(aRetServ)
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

	//define o conteúdo do body
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

	//add ACCESS
	u_setAccess("WSGEO01")
EndIf

If nHeadPri <> -1
	FClose(nHeadPri)
EndIf

UnLockByName("WSGEO02"+ cEmpAnt + cFilAnt,.T.,.T.)

If Empty(cMsgSaida)
	Conout(" ***** WSGEO02 Nao foram encontrados informacoes para Processamento - FIL "+ cEmpAnt + cFilAnt )
Else
	cMsgSaida	:=	Padr("Cliente Prospect GeoSales",21)+"|"+Padr("Status",12)+"|"+Padr("Observavacao/Arq log",60)+CRLF+;
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
Static Function ParserJson(cRetJson, cMsgSaida, cHostWS, cPathAck, aHeader)
Local oJson := Nil
Local aTipDat	:= {"C", "N", "D"}
Local nI,nX,nJ,nQ,nK,nID,nIT,nPos := 0
Local cFolSaida	:= ""
Local cArqErr	:= ""
Local cCodTemp	:= ""
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
Local cDescrLay	:= ""
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
Local cChave2 	:= ""
Local cChvTemp 	:= ""
Local cAliasProc:= ""
Local cParExec	:= ""
Local cVarExec	:= ""
Local cStringEx	:= ""
Local aArqProcAux := {}
Local cValid	:= ""
Local nRetServ

PRIVATE lMsErroAuto		:= .F.
PRIVATE lAutoErrNoFile	:= .T.
PRIVATE _cItem			:= ""
PRIVATE cTabCli			:= ""

If Empty(cRetJson)
	Conout(" ***** Valor JSON nao obtido. Retorno vazio do servico! " + DToC(date()) + " " + time() + cEOL)
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

		If I02->I02_STATUS <> "4" //Cliente Prospect
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
		dbSetOrder(1)
		dbSeek(xFilial("I03") + cCodLay)

		While I03->( !Eof() ) .AND. I03->I03_FILIAL == xFilial("I03") .AND. I03->I03_CODLAY == cCodLay

			cSeqArq				:= I03->I03_SEQARQ
			cTpArq				:= I03->I03_TPARQ
			cArqOri				:= Alltrim(I03->I03_ARQORI)
			cArqDes				:= I03->I03_ARQDES
			cQuery				:= I03->I03_QUERY
			cDescrLay			:= Alltrim(I03->I03_NOME)
			cSeqCpo				:= ""
			cAliasArq			:= Alltrim(cArqOri)
			cValid				:= IIF(cSeqArq=="001", cQuery, cValid)
			cTabCli				:= cArqDes

			&("aCpo"+	cAliasArq)	:= {}

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
			cChave			:= IIF( AT(";",cArqChv)>0, SubStr(Alltrim( cArqChv ),1,AT(";",cArqChv)-1), Alltrim( cArqChv ) )
			cChave			:= Alltrim( &("oBJ:"+ cArqPri +"["+ cValToChar(nID) +"]"+":"+ cChave) )
			cChave2			:= IIF( AT(";",cArqChv)>0, SubStr(Alltrim( cArqChv ),AT(";",cArqChv)+1,40), "" )
			cChave2			:= IIF(Empty(cChave2), "", IIF("REF" $ cChave2,"R","S") + Alltrim( &("oBJ:"+ cArqPri +"["+ cValToChar(nID) +"]"+":"+ cChave2) ) )
			cMsgSaida		+= Padr(cChave+ IIF(!Empty(cChave2),"-"+cChave2,"") ,31)+"|"
			nRetServ		:= 0
			cCodTemp		:= ""

			If nHeadPri <> -1
				FWrite(nHeadPri," ***** Importando "+ Lower(StrTran(cArqPri,"_"," ")) +"-"+ cChave +"/"+ cChave2 +" "+ DToS(date()) + time() + cEOL)
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
						cChvTemp	:= IIF( AT(";",cArqChv)>0, SubStr(Alltrim( cArqChv ),1,AT(";",cArqChv)-1), Alltrim( cArqChv ) )
						cChvTemp	:= Alltrim( &( "oBJ:"+ cAliasProc +"["+ cValToChar(nIT) +"]"+":" + cChvTemp ) )
						If !( cChvTemp == cChave )
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

			If !CliDuplic( cChave, 1, cTabCli, cChave2 )
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
					If !CliDuplic( cChave, 1, cTabCli, cChave2 )
						RollBackSx8()
						cArqErr		:= cFolSaida +"\"+ cDescrLay +"_"+ Alltrim(cChave) + IIF(!Empty(cChave2),"-"+cChave2,"") +"_"+DtoS(date())+".err"
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

						//Salvar LOG de importacao na tabela I07
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
						MsUnLock() //Confirma e finaliza a operação

						nRetServ	:= 0
						If !Empty(aRetServ)
							nRetServ := AScan( aRetServ, {|x| Alltrim(x[1]) == cChave} )
						EndIf

						If nRetServ > 0
							aRetServ[nRetServ][2] := "FALHA"										/*2-STATUS*/
							aRetServ[nRetServ][3] += "\n\n" + cArqPri + "\n" + NoAcento(cArqErr)	/*3-DESCRICAO*/

							//Atualizar codigo do ERP em CLIENTE-PROSPECT-SOCIO-REFERENCIA
							If "CLIENTE_SOCIO_APROVACAO_PROSPECT" $ cArqPri
								Aadd(aRetServ[nRetServ][6], {"", cChave2, "FALHA"} )	/*6-SOCIO CLI ERP*/
							ElseIf "CLIENTE_REFERENCIAS_PROSPECT" $ cArqPri
								Aadd(aRetServ[nRetServ][5], {"", cChave2, "FALHA"} )	/*5-REFERENIA CLI ERP*/
							Else														/*4-CODIGO CLI ERP*/
								aRetServ[nRetServ][4] := Space(8)
							EndIf
						Else
							//Salvar dados em objeto para retorno ao Geosales
							AADD(aRetServ,{	cChave 										/*1-CLIAPRV*/			,;
											"FALHA"										/*2-STATUS*/			,;
											cArqPri + "\n" + NoAcento(cArqErr)			/*3-DESCRICAO*/			,;
											Space(8)									/*4-CODIGO CLI ERP*/	,;
											{}											/*5-REFERENIA CLI ERP*/	,;
											{}											/*6-SOCIO CLI ERP*/		})

							//Atualizar codigo do ERP em CLIENTE-PROSPECT-SOCIO-REFERENCIA
							nRetServ := Len(aRetServ)
							If "CLIENTE_SOCIO_APROVACAO_PROSPECT" $ cArqPri
								Aadd(aRetServ[nRetServ][6], {"", cChave2, "FALHA"} )	/*6-SOCIO CLI ERP*/
							ElseIf "CLIENTE_REFERENCIAS_PROSPECT" $ cArqPri
								Aadd(aRetServ[nRetServ][5], {"", cChave2, "FALHA"} )	/*5-REFERENIA CLI ERP*/
							Else														/*4-CODIGO CLI ERP*/
								aRetServ[nRetServ][4] := Space(8)
							EndIf
						EndIf

					Else//Salvar dados em objeto para retorno ao Geosales
						salvarDados(.F., @cChave, @cChave2, @cArqPri, @cTabCli, @cArqErr, @cCodTemp, @nRetServ)

						cMsgSaida += Padr("com sucesso",12)+"|"+Padr(Lower(StrTran(cArqPri,"_"," "))+" UPD: "+ cCodTemp ,60)+CRLF
					EndIf
				Else //Salvar dados em objeto para retorno ao Geosales, apos retorno com sucesso do ExecAuto
					salvarDados(.T., @cChave, @cChave2, @cArqPri, @cTabCli, @cArqErr, @cCodTemp, @nRetServ)

					cMsgSaida += Padr("com sucesso",12)+"|"+Padr(Lower(StrTran(cArqPri,"_"," "))+" "+cCodTemp,60)+CRLF
				EndIf
			Else//Salvar dados em objeto para retorno ao Geosales
				salvarDados(.F., @cChave, @cChave2, @cArqPri, @cTabCli, @cArqErr, @cCodTemp, @nRetServ)

				cMsgSaida += Padr("com sucesso",12)+"|"+Padr(Lower(StrTran(cArqPri,"_"," "))+" UPD: "+ cCodTemp ,60)+CRLF
	   		Endif
		Next

		I02->( DbSkip() )
	EndDo

Else
	Conout(" ***** Nao foi possivel realizar a deserializacao do JSON. " + DToC(date()) + " " + time())
	If nHeadPri <> -1
		FWrite(nHeadPri," ***** Nao foi possivel realizar a deserializacao do JSON." + DToC(date()) + " " + time())
	EndIf
EndIf

Conout(" ***** Fim da importacao dos Cliente Prospects - FIL "+ cEmpAnt + cFilAnt +" ! "+DTOC(date())+" - "+time())
If nHeadPri <> -1
	FWrite(nHeadPri," ***** Fim da importacao dos Cliente Prospects - FIL "+ cEmpAnt + cFilAnt +" ! "+ DToS(date()) + time() + cEOL)
EndIf

Return

/*********************************************************************************
## Função: CliXCont( cCodCli, cContCod, cEntidade, nHeadPri )					##
## Autor: Miguel Franca															##
## Data: 04/04/2018																##
## Descricao: vincular cliente x contato na AC8									##
**********************************************************************************/
Static Function CliXCont( cCodCli, cContCod, cEntidade, nHeadPri )
Local lRet := .T.

DbSelectArea("AC8")
DbSetOrder(1)
If !( dbSeek( xFilial("AC8") + cContCod + cEntidade + xFilial("AC8") + cCodCli ) )
	If nHeadPri <> -1
		FWrite(nHeadPri,"			( Vinculado com sucesso ["+ cCodCli +"] X ["+ cContCod +"] / ["+ cEntidade +"] " + DToC(date()) +" "+ time() +" ) " + cEOL)
	EndIf

	RecLock("AC8",.T.)
		AC8_FILIAL := xFilial("AC8")
		AC8_FILENT := xFilial("AC8")
		AC8_ENTIDA := cEntidade
		AC8_CODENT := Alltrim(cCodCli)
		AC8_CODCON := Alltrim(cContCod)
	MsUnLock()
Else
	If nHeadPri <> -1
		FWrite(nHeadPri,"			( Vinculacao ja realizada ["+ cCodCli +"] X ["+ cContCod +"] / ["+ cEntidade +"] " + DToC(date()) +" "+ time() +" ) " + cEOL)
	EndIf
EndIf

Return lRet

/*********************************************************************************
## Função: verObjIT(oBJ, aPesq, cCampo, lSomar)									##
## Autor: Miguel Franca															##
## Data: 19/03/2018																##
## Descricao: Localizar valor do atributo de outro objeto no mesmo JSON			##
## Exemplo 1: verObjIT(Objeto, {{Campo,pesquisa}} , Campo /*Retorno/)			##
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
## Função: verObjX(oBJ, cValorVld, cCampoVld, cCampoRet)								##
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
## Função: CliDuplic( cCliAprov, nTipoRet, cTab )								##
## Autor: Miguel Franca															##
## Data: 26/05/2015																##
## Descricao: CliDuplic - Rotina para verificar se Cliente Prospect ja existe	##
## Parametro: nTipoRet- 1:So verificar / 2:Retorna no numero do ERP				##
**********************************************************************************/
Static Function CliDuplic( cCliAprov, nTipoRet, cTab, cChvItem )
Local cQuery	:= ""
Local cAliasTRB
Local xRet

If Empty(cTab)
	cTab := "SA1"
EndIf

If cTab == "SUS"
	cQuery	:= " SELECT MAX(US_COD) COD, MAX(US_LOJA) LOJA	FROM " + RetSqlName( cTab ) + " WHERE US_YSSCLIE = '"+ cCliAprov +"' "
ElseIf cTab == "SU5"
	cQuery	:= " SELECT MAX(U5_CODCONT) COD, '' LOJA		FROM " + RetSqlName( cTab ) + " WHERE U5_XSSCLIE = '"+ cCliAprov +"' AND U5_XSSREFE = '"+ cChvItem +"' "
Else //SA1
	cQuery	:= " SELECT MAX(A1_COD) COD, MAX(A1_LOJA) LOJA	FROM " + RetSqlName( cTab ) + " WHERE A1_XSSCLIE = '"+ cCliAprov +"' "
EndIf

cAliasTRB	:= MPSysOpenQuery(cQuery)

If !(cAliasTRB)->( EOF() ) .AND. !Empty( (cAliasTRB)->COD )
	xRet := IIF( nTipoRet == 1, .T., (cAliasTRB)->COD + (cAliasTRB)->LOJA )
Else
	xRet := IIF( nTipoRet == 1, .F., Space(8) ) //Caso nao exista o Cliente Prospect
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

	cFolSaida += "\cliente_prospect_venda_ws"

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

/*****************************************************************************************************
## Função: salvarDados( lPosOk, cChave, cChave2, cArqPri, cTabCli, cArqErr, cCodTemp, nRetServ )	##
## Autor: Miguel Franca																				##
## Data: 04/04/2018																					##
## Descricao: Salvar dados de importacao em array nRetServ para controle de importacao				##
******************************************************************************************************/
Static Function salvarDados(lPosOk, cChave, cChave2, cArqPri, cTabCli, cArqErr, cCodTemp, nRetServ)
Local lRet := .T.

cArqErr		:= StrTran(cArqPri,"_"," ") + " JA IMPORTADO PARA ERP"
cCodTemp	:= ""
nRetServ	:= 0

If !Empty(aRetServ)
	nRetServ := AScan( aRetServ, {|x| Alltrim(x[1]) == cChave} )
EndIf

If nRetServ > 0
	aRetServ[nRetServ][3] += "\n\n" + NoAcento(cArqErr)			/*3-DESCRICAO*/
Else
	AADD(aRetServ,{	cChave 										/*1-CLIAPRV*/			,;
					"OK"										/*2-STATUS*/			,;
					NoAcento(cArqErr)							/*3-DESCRICAO*/			,;
					Space(9)									/*4-CODIGO CLI ERP*/	,;
					{}											/*5-REFERENIA CLI ERP*/	,;
					{}											/*6-SOCIO CLI ERP*/		})
	nRetServ := Len(aRetServ)
EndIf

//Atualizar codigo do ERP em CLIENTE-PROSPECT-SOCIO-REFERENCIA
If "CLIENTE_SOCIO_APROVACAO_PROSPECT" $ cArqPri
	cCodTemp	:= IIF(lPosOk, SU5->U5_CODCONT, CliDuplic( cChave, 2, cTabCli, cChave2 ) )
	Aadd(aRetServ[nRetServ][6], {cCodTemp, cChave2, "OK"} )		/*6-SOCIO CLI ERP*/
ElseIf "CLIENTE_REFERENCIAS_PROSPECT" $ cArqPri
	cCodTemp	:= IIF(lPosOk, SU5->U5_CODCONT, CliDuplic( cChave, 2, cTabCli, cChave2 ) )
	Aadd(aRetServ[nRetServ][5], {cCodTemp, cChave2, "OK"} )		/*5-REFERENIA CLI ERP*/
Else															/*4-CODIGO CLI ERP*/
	aRetServ[nRetServ][2]	:= "OK"								/*2-STATUS*/
	If lPosOk
		cCodTemp				:= IIF(cTabCli == "SUS", SUS->US_COD + SUS->US_LOJA, SA1->A1_COD + SA1->A1_LOJA)
	Else
		cCodTemp				:= CliDuplic( cChave, 2, cTabCli, cChave2 )
	EndIf
	aRetServ[nRetServ][4]	:= cCodTemp
EndIf

Return lRet