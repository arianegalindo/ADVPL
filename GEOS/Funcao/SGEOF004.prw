#Include 'Protheus.ch'

static function concatFalha(aVetorFalhas, aNovasFalhas)
	// cortesia do @Maniero https://pt.stackoverflow.com/a/348514/64969
	local tamanhoAtual 
	If len(aNovasFalhas) > 0
		tamanhoAtual = len(aVetorFalhas)
		asize(aVetorFalhas, tamanhoAtual + len(aNovasFalhas))
		acopy(aNovasFalhas, aVetorFalhas, 1, len(aNovasFalhas), tamanhoAtual + 1)
	EndIf
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} execAtu

Função responsável para executar a rotina. Caso o parâmetro cExec seja
informado a rotina será executada segundo o parâmetro.
M - Menu, a rotina será executada via Menu e irá mostrar todos os
alerts
J - Job,  a rotina será executada via Job e não mostrará alerts,
o log será mostrado no AppServer.

@type function
@author Sam
@since 13/07/2018
@version 1.0
@param cExec, character, Execução da rotina (M - Menu / J - Job)
/*/
//-------------------------------------------------------------------

User Function execAtu(cExec)
	Local lResult := .T.
	Local aResult
	local aFalhas := {}

	Local i := 0
	Local limite := 3

	Local cTabela := ""
	Local aTabPro := {}
	Local aTabGeo := {}

	Local nRegistros := 0
	Local nCnt 		 := 0
	Local aRegistros := {}

	Local cMsgYN := ""
	Local cMsgExec := ""
	Local cMsgErro := ""
	Local cMsgAtu := ""

	Local cTic := ""
	Local cTac := ""
	Local cElapsed := ""

	Local cTabProt := ""
	Local cTabGeo := ""
	Local cColunaCtxt := ""
	Local cSql := ""

	dbSelectArea("ZX0")
	ZX0->(dbSetOrder(2))
	ZX0->(dbGoTop())

	While !(ZX0->(EOF()))
		If ZX0->ZX0_STATUS == 'A'
			cTabProt := ZX0->ZX0_TB_PRO
			cTabGeo := ZX0->ZX0_TB_GEO
			cColunaCtxt := alltrim(ZX0->ZX0_CCTX)

			if cColunaCtxt = nil .OR. cColunaCtxt = ""
				cColunaCtxt := "YGSENV"
			endif
			cSql := ZX0->ZX0_SQL

			nCnt := IIF(TCCanOpen(RetSqlName(cTabProt)),1, 1)

			IncProc("Calculando Qtd Registro [" + cTabProt + "]: " + Alltrim(STR(nCnt)))

			AADD(aTabPro, cTabProt)
			AADD(aTabGeo, cTabGeo)
			AADD(aRegistros, nCnt)

			nRegistros += nCnt
		EndIf

		ZX0->(dbSkip())
	EndDo
	ZX0->(dbCloseArea())

	if nRegistros == 0
		cMsgAtu := "Não será necessária atualização, pois todos os registros já se encontram atualizados!"
		If cExec == 'M'
			MsgInfo(cMsgAtu, "Atualização")
		Else //cExec == 'J'
			Conout("[GeoSales] " + cMsgAtu)
		EndIf

		Return
	EndIf

	cMsgYN += "Deseja realizar a atualização dos dados do Protheus para o GeoSales?" + CRLF + CRLF
	cMsgYN += "Esta Operação não poderá ser cancelada."

	If cExec == 'M'
		If MsgYesNo(cMsgYN,"Atualização GeoSales")
			bExecRot := .T.
			ProcRegua(nRegistros)
		Else
			bExecRot := .F.
		EndIf
	Else //cExec == 'J'
		bExecRot := .T.
	EndIf

	If bExecRot
		cTic := Time()
		For i := 1 to len(aTabPro)
			if aRegistros[i] > 0
				aResult := U_envJsonAplic(aTabPro[i], 'T', aTabGeo[i], !(aTabPro[i] $ 'SM0;SX5;XXX'))
				lResult := aResult[1] .AND. lResult
				concatFalha(aFalhas, aResult[2])
			EndIf
		Next i
		cTac := Time()

		cElapsed := ElapTime(cTic, cTac)

		if lResult
			cMsgExec := ""
			cMsgExec += "Dados atualizados com Sucesso!" + CRLF + CRLF
			cMsgExec += "Estatísticas" + CRLF
			cMsgExec += "Registros: " + Alltrim(STR(nRegistros)) + CRLF
			cMsgExec += "Tempo:" + cElapsed + CRLF

			If cExec == 'M' 
				MsgInfo(cMsgExec)
			Else //cExec == 'J'
				Conout("[GeoSales] " + cMsgExec)
			EndIf
		Else
			cMsgErro := ""
			cMsgErro += "Ocorreram erros na atualização do Geosales, verifique com a equipe de TI!" + CRLF + CRLF

			If cExec == 'M' .AND. len(aFalhas) > 3
				limite := 3
			Else
				limite := len(aFalhas)
			EndIf

			For i := 1 to limite
				cMsgErro += "Resposta WS: " + aFalhas[i] + CRLF
			Next i

			If limite < len(aFalhas)
				cMsgErro += "E mais " + AllTrim(str(len(aFalhas) - limite)) + " erros" + CRLF
			EndIf

			If cExec == 'M' 
				MsgAlert(cMsgErro)
			Else //cExec == 'J'
				Conout("[GeoSales] " + cMsgErro)
			EndIf
		EndIf
	EndIf
Return

//-------------------------------------------------------------------------
/*/{Protheus.doc} updEnvio

Atualiza os dados da tabela informando que od dados foram enviados

@type function
@author Sam
@since 13/07/2018
@version 1.0
@param cTabela, character, Tabela Protheus
@param aRecnos, vetor de pares, cada par composto por [1] o RECNO
e [2] quantas vezes esse RECNO apareceu
/*/
//------------------------------------------------------------------------
User Function updEnvio(cTabela, cColunaCtxt, aRecnos)
	Local cSQL := ""
	Local cCampo := u_prefTb(cTabela)
	Local nStatus := 0
	Local cDB := TCGetDB()
	Local i	:= 0

	Default aRecnos := {}
	Default cColunaCtxt := "YGSENV"

	If Alltrim(cTabela) <> "XXX"
		cSQL := ""
		cSQL += " UPDATE " + RetSqlName(cTabela)
		cSQL += " SET " + cCampo + "_" + cColunaCtxt + " = 'S' "
		cSQL += " WHERE 1=1 "
		cSQL += " AND " + cCampo + "_" + cColunaCtxt + " <> 'S' "

		If LEN(aRecnos) > 0
			cSql += " AND R_E_C_N_O_ IN ("
			cSql += AllTrim(STR(aRecnos[1]))
			For i := 2 to len(aRecnos)
				cSql += "," + AllTrim(STR(aRecnos[i]))
			Next i
			cSql += ")"
		Endif

		nStatus := TcSqlExec(cSQL)

		If (cDB = "ORACLE") .and. !(nStatus < 0)
			TcSqlExec("COMMIT")
		Endif

		If (nStatus < 0)
			conout("[GeoSales] TCSQLError: " + TCSQLError())
		Endif
	EndIf
Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} CountRegSql

Contador de registros que não foram enviados ao Geosales de acordo
com a tabela informada no parâmero.

@type function
@author Sam
@since 13/07/2018
@version 1.0
@param cTabela, character, Tabela Protheus
@param cQuery, character, consulta específica cadastrada
@param cColunaCtxt, character, coluna com o contexto da atualização; padrão é YGSENV
@return nRet, 1 se houver registro a enviar, ou 0 na ausência
/*/
//-------------------------------------------------------------------
Static Function CountRegSql(cTabela, cQuery, cColunaCtxt)
	Local cSQL := ""
	Local cCampo := u_prefTb(cTabela)
	Local _cAlias := getNextAlias()
	Local nRet := 0

	Default cColunaCtxt := 'YGSENV'
	Default cQuery := ""

	If Empty(cQuery)
		cSQL += " SELECT "
		cSQL += "  TOP 1 1 QTD "
		cSQL += " FROM " + RetSqlName(cTabela) + " X "
		cSQL += " WHERE 1=1 "
		if !(cTabela $ 'SX5;XXX')
			cSQL += " AND X." + cCampo + "_" + cColunaCtxt + " <> 'S' "
		EndIf
	Else 
		cSQL += " SELECT "
		cSQL += "  TOP 1 1 QTD "
		cSQL += " FROM ( "
		cSQL += cQuery
		cSQL += " ) AS X "
	EndIf

	cSql := changeQuery(cSQL)

	DBUseArea(.T.,'TOPCONN',TCGENQRY(,,cSql),_cAlias,.F.,.T.)

	nRet := (_cAlias)->QTD

	(_cAlias)->(dbCloseArea())
Return nRet

//--------------------------------------------------------------------------
/*/{Protheus.doc} findCtxt

Função responsvel por buscar os campos de contexto referente a tabela alvo.

@type  Function
@author William - @vbastos
@since 02/04/2019
@version 1.0
@param cTabela, character, Tabela Protheus
@return aCtxt, array, Array com os campos contextos da tabela
/*/
//--------------------------------------------------------------------------
User Function findCtxt(cTabela)
	Local aCtxt := {}

	dbSelectArea("ZX0")
	ZX0->(dbSetOrder(4))
	ZX0->(dbGoTop())

	AADD(aCtxt, "YGSENV")

	While !(ZX0->(EOF()))
		If (AllTrim(ZX0->ZX0_TB_PRO) = cTabela) .and. (AllTrim(ZX0->ZX0_CCTX) != "" .and. AllTrim(ZX0->ZX0_CCTX) != nil)
			AADD(aCtxt,AllTrim(ZX0->ZX0_CCTX))
		EndIf
		ZX0->(dbSkip())
	EndDo
	ZX0->(dbCloseArea())
Return aCtxt