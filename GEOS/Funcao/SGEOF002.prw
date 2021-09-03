#Include 'Protheus.ch'
#include "fileio.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} gerarIntegPadrao

Gerar dados padro das tabelas ZX0 e ZX1

@type  Function
@author Sam
@since 19/07/2018
@version 1.0
/*/
//-------------------------------------------------------------------
User Function gerarIntegPadrao()
	Local cMsg := ""

	cMsg += "Deseja limpar os dados do Integrador Protheus Geosales "
	cMsg += "para gerar novo resultado?" + CRLF + CRLF
	cMsg += "Esta operao ir remover todos os dados atuais e incluir novos dados"

	If MsgYesNo(cMsg)
		Processa( {|| FgeraPadrao() }, "Gerar Padro", "Processando...", .F.)
	EndIf
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} FgeraPadrao()

FunÁ„o auxiliar de gerarIntegPadrao

@type  Function
@author Sam
@since 19/07/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function FgeraPadrao()
	Local aDados := montaZXDados()
	Local nZX0 := 1
	Local nZX1 := 2

	limpaZX0ZX1()

	insertZX0(aDados[nZX0])
	insertZX1(aDados[nZX1])
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} gerarImportPadrao

Gerar dados padr„o das tabelas I02, I03, I04

@type  Function
@author William
@since 07/05/2019
@version 1.0
/*/
//-------------------------------------------------------------------
User Function gerarImportPadrao()
	Local cMsg := ""

	cMsg += "Deseja limpar os dados do Integrador Protheus Geosales "
	cMsg += "para gerar novo resultado?" + CRLF + CRLF
	cMsg += "Esta operaÁ„o ir· remover todos os dados atuais e incluir novos dados"

	If MsgYesNo(cMsg)
		Processa( {|| padraoImport() }, "Gerar Padr„o", "Processando...", .F.)
	EndIf
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} padraoImport()

FunÁ„o auxiliar de gerarImportPadrao

@type  Function
@author Sam
@since 19/07/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function padraoImport()
	Local aDados := montaI0Dados()
	Local nI02 := 1
	Local nI03 := 2
	Local nI04 := 3

	limpaI0()

	insertI02(aDados[nI02])
	insertI03(aDados[nI03])
	insertI04(aDados[nI04])
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AtivaIntegra

Funo responsvel por Ativar/Desativar o WebService de envio de
dados do protheus para o geosales. Mesmo que as tabelas estejam
preenchidas, a rotina sÛ ser· utilizada caso o Status esteja
setado como ATIVO.

@type function
@author Sam
@since 11/07/2018
@version 1.0
/*/
//-------------------------------------------------------------------
User Function AtivaIntegra()
	If ZX0->ZX0_STATUS == 'I'
		If MsgYesNo("Deseja ativar a integraÁ„o selecionada?","GeoSales")
			RecLock("ZX0", .F.)
				ZX0->ZX0_STATUS := 'A'
			ZX0->(MsUnLock())
		EndIf
	Else
		If MsgYesNo("Deseja desativar a integrao selecionada?","GeoSales")
			RecLock("ZX0", .F.)
				ZX0->ZX0_STATUS := 'I'
			ZX0->(MsUnLock())
		EndIf
	EndIf
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} atvTodos

FunÁ„o respons·vel por Ativar todos so WebService de
envio dedados do protheus para o geosales. Mesmo que as tabelas
estejam preenchidas, a rotina sÛ ser· utilizada caso o Status esteja
setado como ATIVO.

@type function
@author Sam
@since 26/07/2018
@version 1.0
/*/
//-------------------------------------------------------------------
User Function atvTodos()
	If MsgYesNo("Deseja ativar todas as integraes da lista?","GeoSales")
		ZX0->(dbGoTop())
		While !ZX0->(EOF())
			RecLock("ZX0", .F.)
				ZX0->ZX0_STATUS := 'A'
			ZX0->(MsUnLock())

			ZX0->(dbSkip())
		EndDo

		MsgInfo("GeoSales", "Integradores atualizados com sucesso!")
	EndIf
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} desTodos

FunÁ„o respons·vel por Desativar todos so WebService de
envio dedados do protheus para o geosales. Mesmo que as tabelas
estejam preenchidas, a rotina sÛ ser· utilizada caso o Status esteja
setado como INATIVO.

@type function
@author Sam
@since 26/07/2018
@version 1.0
/*/
//-------------------------------------------------------------------
User Function desTodos()
	If MsgYesNo("Deseja desativar todas as integraes da lista?","GeoSales")
		ZX0->(dbGoTop())
		While !ZX0->(EOF())
			RecLock("ZX0", .F.)
				ZX0->ZX0_STATUS := 'I'
			ZX0->(MsUnLock())

			ZX0->(dbSkip())
		EndDo

		MsgInfo("GeoSales", "Integradores atualizados com sucesso!")
	EndIf
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} getHost

Pega o host contido na tabela ZX2

@type function
@author Sam
@since 12/07/2018
@version 1.0
@return cRet, Descrio do Host
/*/
//-------------------------------------------------------------------
User Function getHost()
	Local cRet := Alltrim(POSICIONE("ZX2",2,xFilial("ZX2") + "HOST", "ZX2->ZX2_DESC"))
Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} getPath

Pega o caminho contido na tabela ZX2

@type function
@author Sam
@since 12/07/2018
@version 1.0
@return cRet, Descrio do caminho
/*/
//-------------------------------------------------------------------
User Function getPath()
	Local cRet := Alltrim(POSICIONE("ZX2",2,xFilial("ZX2") + "PATH", "ZX2->ZX2_DESC"))
Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} getEmpHost

Pega o nome da empresa contido na tabela ZX2

@type function
@author Sam
@since 12/07/2018
@version 1.0
@return cRet, Descrio do nome da empresa
/*/
//-------------------------------------------------------------------
User Function getEmpHost()
	Local cRet := Alltrim(POSICIONE("ZX2",2,xFilial("ZX2") + "EMPHOST", "ZX2->ZX2_DESC"))
Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} getHeaders

Pega os Headers contido na tabela ZX3

@type function
@author Sam
@since 27/07/2018
@version 1.0
@return aRet, Array com os Headers
/*/
//-------------------------------------------------------------------
User Function getHeaders(aOptions)
	Local aRet := {}
	Local i	:= 0

	If Len(aOptions) = 0
		return aRet
	EndIf

	dbSelectArea('ZX3')
	dbSetOrder( 4 )

	For i := 1 to Len(aOptions)
		ZX3->( dbGoTop() )
		ZX3->( dbSeek( xFilial() + aOptions[i]) )
		IF (Alltrim(ZX3->ZX3_PARAM) == aOptions[i]) .AND. (ZX3->ZX3_CONTEU != "")
			AADD(aRet, ZX3->(Alltrim(ZX3_DESC) + ': ' + Alltrim(ZX3_CONTEU)))
		EndIf
	Next
Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} limpaZX0ZX1

Limpa os dados da tabela

@type  Static Function
@author Sam
@since 19/07/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function limpaZX0ZX1()
	Local cSql := ""

	incproc("Limpando dados")

	cSQL := " DELETE FROM " + RetSqlName("ZX0")
	TcSqlExec(cSQL)

	cSql := " DELETE FROM " + RetSqlName("ZX1")
	TcSqlExec(cSQL)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} limpaI0

Limpa os dados das tabelas I02, I03, I04

@type  Static Function
@author William
@since 07/05/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function limpaI0()
	Local cSql := ""

	incproc("Limpando dados")

	cSQL := " DELETE FROM " + RetSqlName("I02")
	TcSqlExec(cSQL)

	cSql := " DELETE FROM " + RetSqlName("I03")
	TcSqlExec(cSQL)

	cSql := " DELETE FROM " + RetSqlName("I04")
	TcSqlExec(cSQL)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} insertZX0

Insere dados na tabela ZX0

@type  Static Function
@author Sam
@since 19/07/2018
@version 1.0
@param aZX0, array, Dados da Tabela ZX0
@see (links_or_references)
/*/
//-------------------------------------------------------------------
Static Function insertZX0(aZX0)
	Local i := 0
	Local nZX0 := len(aZX0)
	procregua(nZX0)

	For i := 1 to nZX0
		incproc("Incluindo Dados ZX0 [" + aZX0[i][2] + "]")
		RecLock("ZX0", .T.)
			ZX0->ZX0_FILIAL := aZX0[i][1]
			ZX0->ZX0_COD 	:= aZX0[i][2]
			ZX0->ZX0_TB_PRO := aZX0[i][3]
			ZX0->ZX0_TB_GEO := aZX0[i][4]
			ZX0->ZX0_DESC 	:= aZX0[i][5]
			ZX0->ZX0_STATUS := aZX0[i][6]
			ZX0->ZX0_SQL 	:= aZX0[i][7]
		ZX0->(MsUnLock())
	Next	
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} insertZX1

Insere dados na tabela ZX1

@type  Static Function
@author Sam
@since 19/07/2018
@version 1.0
@param aZX1, array, Dados da Tabela ZX1
@see (links_or_references)
/*/
//-------------------------------------------------------------------
Static Function insertZX1(aZX1)
	Local nZX1 := len(aZX1)
	Local i	:= 0
	procregua(nZX1)

	For i := 1 to nZX1
		RecLock("ZX1", .T.)
			incproc("Incluindo Dados ZX1 [" + aZX1[i][2] + "]")
			ZX1->ZX1_FILIAL := aZX1[i][1]
			ZX1->ZX1_COD 	:= aZX1[i][2]
			ZX1->ZX1_ITEM 	:= aZX1[i][3]
			ZX1->ZX1_CP_GEO := aZX1[i][4]
			ZX1->ZX1_TIPO	:= aZX1[i][5]
			ZX1->ZX1_CP_PRO := aZX1[i][6]
			ZX1->ZX1_TAM	:= VAL(aZX1[i][7])
			ZX1->ZX1_DECIMA	:= VAL(aZX1[i][8])
			ZX1->ZX1_OBS 	:= aZX1[i][9]
		ZX1->(MsUnLock())
	Next	
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} insertI02

Insere dados na tabela I02

@type Static Function
@author William
@since 07/05/2019
@version 1.0
@param aI02, array, Dados da Tabela I02
/*/
//-------------------------------------------------------------------
Static Function insertI02(aI02)
	Local i	:= 0
	Local nI02 := len(aI02)
	procregua(nI02)

	For i := 1 to nI02
		RecLock("I02", .T.)
			incproc("Incluindo Dados I02 [" + aI02[i][2] + "]")
			I02->I02_FILIAL	:= aI02[i][1]
			I02->I02_CODLAY	:= aI02[i][2]
			I02->I02_DESLAY	:= aI02[i][3]
			I02->I02_STATUS	:= aI02[i][4]
			I02->I02_TIPIMP	:= aI02[i][5]
			I02->I02_EXECAU	:= aI02[i][6]
			I02->I02_ARQPRI	:= aI02[i][7]
			I02->I02_CHAVE	:= aI02[i][8]
		I02->(MsUnLock())
	Next	
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} insertI03

Insere dados na tabela I03

@type Static Function
@author William
@since 07/05/2019
@version 1.0
@param aI03, array, Dados da Tabela I03
/*/
//-------------------------------------------------------------------
Static Function insertI03(aI03)
	Local nI03 := len(aI03)
	Local i	:= 0
	procregua(nI03)

	For i := 1 to nI03
		RecLock("I03", .T.)
			incproc("Incluindo Dados I03 [" + aI03[i][2] + "]")
			I03->I03_FILIAL	:= aI03[i][1]
			I03->I03_CODLAY	:= aI03[i][2]
			I03->I03_SEQARQ	:= aI03[i][3]
			I03->I03_NOME	:= aI03[i][4]
			I03->I03_TPARQ	:= aI03[i][5]
			I03->I03_ARQORI	:= aI03[i][6]
			I03->I03_ARQDES	:= aI03[i][7]
			I03->I03_query	:= aI03[i][8]
		I03->(MsUnLock())
	Next	
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} insertI04

Insere dados na tabela I04

@type Static Function
@author William
@since 07/05/2019
@version 1.0
@param aI04, array, Dados da Tabela I04
/*/
//-------------------------------------------------------------------
Static Function insertI04(aI04)
	Local i := 0	
	Local nI04 := len(aI04)
	procregua(nI04)

	For i := 1 to nI04
		RecLock("I04", .T.)
			incproc("Incluindo Dados I04 [" + aI04[i][2] + "]")
			I04->I04_FILIAL	:= aI04[i][1]
			I04->I04_CODLAY	:= aI04[i][2]
			I04->I04_SEQARQ	:= aI04[i][3]
			I04->I04_SEQCPO	:= aI04[i][4]
			I04->I04_CPOORI	:= aI04[i][5]
			I04->I04_FUNC	:= aI04[i][6]
			I04->I04_CPODE	:= aI04[i][7]
			I04->I04_CPOATE	:= aI04[i][8]
			I04->I04_TAMANH	:= Val(aI04[i][9])
			I04->I04_DECIMA	:= Val(aI04[i][10])
			I04->I04_TIPDAT	:= aI04[i][11]
			I04->I04_CPODES	:= aI04[i][12]
		I04->(MsUnLock())
	Next	
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} insertZX0

Insere dados na tabela ZZZ

@type  Static Function
@author Sam
@since 14/09/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function insertZZZ()
	RecLock("ZZZ", .T.)
		ZZZ->ZZZ_FILIAL := '01'
	ZZZ->(MsUnLock())
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} montaZXDados

Monta os dados da tabela ZX0 e ZX1

@type  Static Function
@author Sam
@since 19/07/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function montaZXDados()
	Local aDados := {}
	Local aDadosZX0 := {}
	Local aDadosZX1 := {}

	Local cTabela := ""

	Local cFileZX := ""

	cFileZX := u_pathVerify("\IPG\ZX\ZX0.TXT")
	cTabela := "ZX0"
	aDadosZX0 := getDadosTabela(cFileZX, cTabela)

	cFileZX := u_pathVerify("\IPG\ZX\ZX1.TXT")
	cTabela := "ZX1"
	aDadosZX1 := getDadosTabela(cFileZX, cTabela)

	AADD(aDados, aDadosZX0)
	AADD(aDados, aDadosZX1)
Return aDados

//-------------------------------------------------------------------
/*/{Protheus.doc} montaI0Dados

Monta os dados da tabela I02, I03, I04

@type Static Function
@author William
@since 07/05/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function montaI0Dados()
	Local aDados	:= {}
	Local aDadosI02	:= {}
	Local aDadosI03	:= {}
	Local aDadosI04	:= {}
	Local cTabela	:= ""
	Local cFile		:= ""

	cFile := u_pathVerify("\IPG\I0\I02.TXT" )
	cTabela := "I02"
	aDadosI02 := getDadosTabela(cFile, cTabela)

	cFile := u_pathVerify("\IPG\I0\I03.TXT" )
	cTabela := "I03"
	aDadosI03 := getDadosTabela(cFile, cTabela)

	cFile := u_pathVerify("\IPG\I0\I04.TXT" )
	cTabela := "I04"
	aDadosI04 := getDadosTabela(cFile, cTabela)

	AADD(aDados, aDadosI02)
	AADD(aDados, aDadosI03)
	AADD(aDados, aDadosI04)
Return aDados

//-------------------------------------------------------------------
/*/{Protheus.doc} makeFile

Funo para gerar o arquivo com os dados das tabelas ZX0 e ZX1

@type  Static Function
@author Sam
@since 01/08/2018
@version 1.0
@param cTabela, character, Tabela Protheus
/*/
//-------------------------------------------------------------------
Static Function makeFile(cTabela)
	Local cConteudo := ""
	Local nHandle := 0

	Local cHost		:= U_getHost()
	Local cPath		:= U_getPath()
	Local cSB		:= "__sandbox/ipg"
	Local cUrl     	:= cHost + '/' + cPath + '/' + cSB + '/' + lower(cTabela) + ".txt"

	Local cFileZX := "\IPG\ZX\" + cTabela + ".TXT"

	if ExistDir( "\IPG" )
		if !ExistDir( "\IPG\ZX" )
			MakeDir("\IPG\ZX")
		Endif
	Else
		MakeDir("\IPG")
		MakeDir("\IPG\ZX")
	EndIf

	cConteudo := HttpGet(cUrl)
	If !Empty(cConteudo)
		nHandle := fCreate(cFileZX)
		FWrite(nHandle, cConteudo)
		FClose(nHandle)
	EndIf
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} makeTxtFile

Funo responsvel por gerar o arquivo texto a
partir do banco de dados.

Essa funo no  para uso de usurio

@type Function
@author Sam
@since 01/08/2018
@version version
@param cTabela, character, Tabela Protheus
/*/
//-------------------------------------------------------------------
User Function makeTxtFile(cTabela)
	Local cConteudo := ""
	Local cFileZX := ""
	Local cCampo := ""
	Local cTipo := ""
	Local cMemo := ""
	Local nCnt := 0
	Local i := 0
	Local xArea := getArea()

	dbSelectArea(cTabela)
	(cTabela)->(dbGoTop())
	While !((cTabela)->(Eof()))
		dbSelectArea('SX3')
		SX3->( dbSetOrder(1) )
		SX3->( dbGoTop() )
		SX3->( dbSeek( cTabela ) )
		While !(SX3->(Eof())) .AND. SX3->X3_ARQUIVO == cTabela
			cCampo := SX3->X3_CAMPO
			cTipo  := SX3->X3_TIPO
			Do Case
				Case cTipo == 'C'
					cConteudo += (cTabela)->(&cCampo) + ';'
				Case cTipo == 'N'
					cConteudo += AllTrim(Str((cTabela)->(&cCampo))) + ';'
				Case cTipo == 'D'
					cConteudo += DtoS((cTabela)->(&cCampo)) + ';'
				Case cTipo == 'M'
					cMemo := AllTrim((cTabela)->(&cCampo))
					nCnt := MLCount(cMemo)

					For i := 1 to nCnt
						cConteudo += AllTrim(MemoLine(cMemo,,i)) + " "
					Next i
					cConteudo += ' ;'
			EndCase

			SX3->(dbSkip())
		EndDo
		cConteudo += CRLF

		(cTabela)->(dbSkip())
	EndDo

	cConteudo := SUBS(cConteudo, 1, len(cConteudo) - 1)

	cFileZX := "\IPG\ZX\" + cTabela + ".TXT"
	nHandle := fCreate(cFileZX)
	FWrite(nHandle, cConteudo)
	FClose(nHandle)

	RestArea(xArea)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} getDadosTabela

Funo responsvel por pegar os dados da tabela montados em um vetor

@type Function
@author Sam
@since 01/08/2018
@version 1.0
@param cFile, character, Path do arquivo
@param cTabela, character, Tabela Protheus
@return aRet, vetor com os dados da tabela
/*/
//-------------------------------------------------------------------
Static function getDadosTabela(cFile, cTabela)
	Local cLinha := ""
	Local aArray := {}
	Local aRet := {}
	Local nCnt := 0
	Local nPosSQL := Val(getSX3Cache("ZX0_SQL", "X3_ORDEM"))

	makeFile(cTabela)

	FT_FUSE(cFile) //ABRIR
	FT_FGOTOP()    //PONTO NO TOPO

	While !FT_FEOF()
		cLinha := FT_FREADLN()
		aArray := Strtokarr( cLinha, ';')
		if len(aArray) > 1
			nCnt++
			AADD(aRet, aArray)
		Else
			aRet[nCnt][nPosSQL] += aArray[1]
		EndIf

		aRet[nCnt][nPosSQL] := StrTran(aRet[nCnt][nPosSQL], "990", cEmpAnt + '0')

		FT_FSKIP()
	EndDo
Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} getPathImp

Pega a URL de consumo do servio na tabela ZX2

@type function
@author William - @vbastos
@since 08/03/2019
@version 1.0
@return cRet, Descrio da URL
/*/
//-------------------------------------------------------------------
User Function getPathImp()
	Local cRet := Alltrim(POSICIONE("ZX2",2,xFilial("ZX2") + "PATHIMP", "ZX2->ZX2_DESC"))
Return cRet

//-----------------------------------------------------------------------
/*/{Protheus.doc} getConfJob

Funo responsavel por ler o arquivo jobCong.txt e retornar a primeira
empresa e filial

@type function
@author William - @vbastos
@since 03/05/2019
@version 1.0
@return Array, 1 posio, Codigo da empresa, 2 posio Codigo da filial
/*/
//-----------------------------------------------------------------------
User Function getConfJob()
	Local cFile := u_pathVerify("IPG\CONF\jobConf.txt")
	Local cAux := ""
	Local aRet := {}
	Local oFile

	oFile := FWFileReader():New(cFile)
	if (oFile:Open())
		oFile:GetLine() // ignorando linha de cabe√ßalho
		while (oFile:hasLine())
			cAux := oFile:GetLine()
			AADD(aRet,StrtoKArr(cAux,';'))
		end
		oFile:Close()
	endif
Return aRet