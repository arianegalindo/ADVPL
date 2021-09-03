#Include 'Protheus.ch'

//-------------------------------------------------------------
/*/{Protheus.doc} getCurrentDate

Pega a data atuale formata de acordo com o recebimento das
tabelas do Geosales
Formato: AAAA-MM-DD HH:mm:SS.l
Ex.:     1900-01-01 00:00:00.0

@type function
@author Sam
@since 10/07/2018
@version 1.0
@return cFormat, Data Formatada
/*/
//-------------------------------------------------------------
Static Function getCurrentDate()
	Local cDataAtu := DtoS(Date())
	Local cHora := Time()

	Local cAno := SUBS(cDataAtu, 1, 4)
	Local cMes := SUBS(cDataAtu, 5, 2)
	Local cDia := SUBS(cDataAtu, 7, 2)

	Local cFormat := cAno + "-" + cMes + "-" + cDia + " " + cHora + ".0"
Return cFormat


//-------------------------------------------------------------------
/*/{Protheus.doc} ESCENVST()

Escapa adequadamente uma string de envio

Aspas e contrabarras so escapadas com contrabarra
Caracteres fora do ASCII ou de controle se tornam '?'

Por exemplo, se for entrada a seguinte string via ADVPL:
	"\fornecedor \   " + '+"+' + " marmota" + chr(1)
Que se transforma em
	\fornecedor \   +"+ marmota
(seguido de um caracter de controle)
Se transforma em:
	\\fornecedor \\   +\"+ marmota?

@type  Function
@author Jeff
@since 08/11/2018
@version version
/*/
//-------------------------------------------------------------------
Static Function ESCENVST(cText)
	local cClean := ""
	Local nLen
	local nFim
	local nDelta
	local i
	local nIdx := 1
	local cChar
	local nCharAsc

	cText := StrTran(cText, '\', '\\')
	cText := StrTran(cText, '"', '\"')

	nLen := Len(cText)
	For i := 1 To nLen
		cChar := Substr(cText, i, 1)
		nCharAsc := Asc(cChar)
		If nCharAsc < 32 .OR. nCharAsc >= 127
			nDelta := i - nIdx
			If nDelta != 0
				cClean += Substr(cText, nIdx, nDelta)
			EndIf
			cClean += "?"
			nIdx := i + 1
		EndIf
	Next
	If nLen != nIdx
		cClean += Substr(cText, nIdx, nLen - nIdx + 1)
	ElseIf nLen = 1
		cClean := cText
	EndIf
Return cClean

//-------------------------------------------------------------
/*/{Protheus.doc} Conv2Json

Converte a varivel cCpo num estrutura que ir receber os
dados do Protheus para montagem do JSON

@type function
@author Sam
@since 10/07/2018
@version 1.0
@param cLHS, character, String com o lado esquerdo da operao '->' a ser criado
@param cCpo, character, String contendo o campo/a expresso a ser resolvido(a) no result set da consulta
@return cLHS + "->(" + cCpo + ")", retorna o valor a ser resolvido(a) no result set da consulta.
/*/
//-------------------------------------------------------------
Static Function Conv2Json(cCpo, cLHS)
return cLHS + "->(" + cCpo + ")"

//-------------------------------------------------------------
/*/{Protheus.doc} getZX1Stuff

Pega o contedo da ZX1 e o prepara nessa ordem (por linha da consulta):

1. ZX1_TIPO
2. ZX1_CP_PRO
3. ZX1_CP_GEO
4. ZX1_TAM

Aqui a ZX1  manipulada para leitura, no espere que ela mantenha
o ponteiro onde voc deixou da ltima vez.

@type function
@author Jefferson Quesado
@since 12/11/2018
@version 1.0
@param cChave, character, chave misteriosa
@return aZX1Stuff, array array de strings, contm as coisas da ZX1 nessa ordem (por linha da consulta): [1] ZX1_TIPO [2] ZX1_CP_PRO [3] ZX1_CP_GEO [4] ZX1_TAM
/*/
//-------------------------------------------------------------
Static Function getZX1Stuff(cChave)
	local aZX1Stuff := {}

	dbSelectArea("ZX1")
	ZX1->(dbSetOrder(1))
	ZX1->(dbGoTop())
	ZX1->(dbSeek(cChave))

	While !(ZX1->(EOF())) .AND. cChave == ZX1->(ZX1_FILIAL + ZX1_COD)
		aadd(aZX1Stuff, { ZX1->ZX1_TIPO, alltrim(ZX1->ZX1_CP_PRO), alltrim(ZX1->ZX1_CP_GEO), ZX1->ZX1_TAM })
		ZX1->(dbSkip())
	EndDo
	ZX1->(dbCloseArea())
return aZX1Stuff

//-------------------------------------------------------------
/*/{Protheus.doc} linhaJson

Cria um objeto JSON representando uma linha de consulta.

@type function
@author Jefferson Quesado
@since 12/11/2018
@version 1.0
@param cTabela, character, nome da tabela/alias sendo usado para resgate das informaes
@param aZX1Stuff, array de strings, contm as coisas da ZX1 nessa ordem (por linha da consulta): [1] ZX1_TIPO [2] ZX1_CP_PRO [3] ZX1_CP_GEO [4] ZX1_TAM
@param lVerificaExclusao, booleano, houve excluso da linha especfica
@param lRecno, booleano, possui a coluna RECNO em cTabela
@return aJson, posio [1] consiste do JSON, posio [2] consiste do RECNO (ou nulo, se no existir a coluna RECNO)
/*/
//-------------------------------------------------------------
Static Function linhaJson(cTabela, aZX1Stuff, lVerificaExclusao, lRecno)
	local cTipo
	local xResult
	local cJson := "{"
	local nRecno := nil
	local aZX1Linha
	local i

	If lRecno
		nRecno := (cTabela)->RECNO
	EndIf

	For i := 1 to len(aZX1Stuff)
		aLinha = aZX1Stuff[i]

		If aLinha[1] == 'B'
			xResult := &(conv2Json(aLinha[2], cTabela))
			cTipo := ValType(xResult)
			If cTipo == 'C'
				if xResult != ""
					cJson += '"' + AllTrim(Lower(aLinha[3])) + '":"' + ESCENVST(SUBS(AllTrim(xResult),1,aLinha[4])) + '",'
				EndIf
			ElseIf cTipo == 'N'
				cJson += '"' + AllTrim(Lower(aLinha[3])) + '":"' + cValToChar(xResult) + '",'
			ElseIf cTipo == 'D'
				cData := DtoS(xResult)
				cData := SUBS(cData, 1, 4) + '-' + SUBS(cData, 5, 2) + '-' + SUBS(cData, 7, 2)
				cJson += '"' + AllTrim(Lower(aLinha[3])) + '":"' + cData + '",'
			EndIf
		ElseIf aLinha[1] == 'S'
			cJson += '"' + AllTrim(Lower(aLinha[3])) + '":"' + AllTrim(aLinha[2]) + '",'
		ElseIf aLinha[1] == 'V'
			cJson += '"' + AllTrim(Lower(aLinha[3])) + '":"",'
		Else //ZX1->ZX1_TIPO == 'N'
			cJson += ""
		EndIf
	Next i

	If lVerificaExclusao //Se for excluso
		cJson += '"data_delete":"' + getCurrentDate() + '"'
	EndIf
	cJson += "}"
Return { cJson, nRecno }

//-------------------------------------------------------------
/*/{Protheus.doc} makeUniJson

Funo que monta o JSON segundo os dados informados nas
tabelas ZX0 e ZX1

@type function
@author Sam
@since 10/07/2018
@version 1.0
@param cTabela, character, Tabela do Sistema Protheus
@param cOp, character, Tipo de Operaoo (I-Incluir/A-Alterar/E-Excluir)
@param cTabGeo, character, Tabela do Sistema GeoSales
@param bTratativaEventos, bloco de cdigo, chamada que
			envia um bloco de informaes ao GeoSales,
			deve retornar um booleano sobre o sucesso
			ou falha da operao
@return se houve sucesso no envio
@example

static funcion marmota(cStuff)
  conout(cStuff)
return len(cStuff) <= 10
...

U_makeUniJson('SA1', 'I', 'CLIENTE', {|cJson| marmota(cJson)})
/*/
//-------------------------------------------------------------
User Function makeUniJson(cTabela, cOp, cTabgeo, bTratativaEventos)
	Local cJson := ""

	Local cCodTab		:= ""
	Local cTabProtheus 	:= ""
	Local cTabGeosales 	:= ""
	Local cStatus 		:= ""
	Local aJson

	Local xResult		:= ""

	Default cTabGeo		:= ""

	dbSelectArea("ZX0")
	ZX0->(dbSetOrder(4)) //ZX0_FILIAL + ZX0_TB_PRO
	ZX0->(dbGoTop())
	ZX0->(dbSeek(xFilial("ZX0") + cTabela + cTabGeo))

	cChave 		 := ZX0->(ZX0_FILIAL + ZX0_COD)
	cTabProtheus := ZX0->ZX0_TB_PRO
	cTabGeosales := ZX0->ZX0_TB_GEO
	cStatus 	 := ZX0->ZX0_STATUS

	ZX0->(dbCloseArea())

	If cStatus == 'I'
		cJson := "INATIVO"
		Return cJson
	EndIf

	cJson += Alltrim(' {   ')
	cJson += Alltrim('     "' + Alltrim(Lower(cTabGeosales)) + '":[   ')

	aJson := linhaJson(cTabela, getZX1Stuff(cChave), cOp == 'E', .F.)
	cJson += aJson[1]
	//cTabela, cChave, cVerificaExclusao

	cJson += Alltrim('     ] ')
	cJson += Alltrim(' } '	)
Return eval(bTratativaEventos, cJson)


//-------------------------------------------------------------
/*/{Protheus.doc} hasRecno

Tem recno nessa tabela?

@type function
@author JeffQue
@since 06/12/2018
@version 1.0
@param cTabela, character, Tabela para verificar se tem existe a coluna RECNO
@return
@example
hasRecno("TABSQL")

// ou ento

local cTabela := "SA1"
hasRecno(cTabela)
/*/
//-------------------------------------------------------------
Static Function hasRecno(cTabela)
	local i
	local aEstrutura := DBStruct(cTabela)

	For i := 1 to len(aEstrutura)
		If aEstrutura[i][1] == 'RECNO'
			Return .T.
		EndIf
	Next i
Return .F.

//-------------------------------------------------------------
/*/{Protheus.doc} eventoMAJs

Funo que monta o JSON segundo os dados informados nas
tabelas ZX0 e ZX1 para todos os dados que no foram
enviado para o Geosales

@type function
@author JeffQue
@since 06/12/2018
@version 1.0
@param bTratativaEventos, bloco de cdigo, chamada que
			envia um bloco de informaes ao GeoSales,
			deve retornar um booleano sobre o sucesso
			ou falha da operao
@param cJson, character, Payload de envio
@param aRecnosCandidatos, vetor de nmeros, recnos a serem inseridos
@param aRecnosCandidatos, vetor de nmeros, recnos j inseridos, se envio sucesso deve concatenar
@return se houve sucesso em no envio
/*/
//-------------------------------------------------------------
Static function eventoMAJs(bTratativaEventos, cJson, aRecnosCandidatos, aRecnosSucesso)
	// cortesia do @Maniero https://pt.stackoverflow.com/a/348514/64969
	local tamanhoAtual
	If eval(bTratativaEventos, cJson)
		if len(aRecnosCandidatos) > 0
			makeRecnosSucesso(aRecnosCandidatos, aRecnosSucesso)
			aRecnosCandidatos := {}
		EndIf
		Return .T.
	EndIf

	aRecnosCandidatos := {}
Return .F.

Static Function makeRecnosSucesso(aRecnosCandidatos, aRecnosSucesso)
Local i	:= 0

	For i:= 1 to Len(aRecnosCandidatos)
		nTam := Len(aRecnosSucesso)
		if nTam != 0 .AND. aRecnosCandidatos[i] = ATail(aRecnosSucesso)[1]
			aRecnosSucesso[nTam][2] += 1
		Else
			AADD(aRecnosSucesso, { aRecnosCandidatos[i], 1 })
		EndIf
	Next

Return aRecnosSucesso

//-------------------------------------------------------------
/*/{Protheus.doc} makeAllJson

Funo que monta o JSON segundo os dados informados nas
tabelas ZX0 e ZX1 para todos os dados que no foram
enviado para o Geosales

@type function
@author Sam
@since 12/07/2018
@version 1.0
@param cTabela, character, Tabela do Sistea Protheus
@param cTabGeo, character, Tabela do Sistema GeoSales
@param lParcUpd, booleano, executa atualizao parcial
@param bTratativaEventos, bloco de cdigo, chamada que
			envia um bloco de informaes ao GeoSales,
			deve retornar um booleano sobre o sucesso
			ou falha da operao
@return lSucessoEnvio, se houve sucesso em TODOS os envios
@example

static funcion marmota(cStuff)
  conout(cStuff)
return len(cStuff) <= 10
...
U_sendAllJson('SA1', 'CLIENTE', {|cJson| marmota(cJson)})

/*/
//-------------------------------------------------------------
User Function makeAllJson(cTabela, cTabGeo, lParcUpd, bTratativaEventos)
	Local cJson := ""
	local lHouveLeitura := .T.
	local lPrimeiraLeitura := .T.

	Local nCnt := 0
	local nSize := 0

	Local cCodTab		:= ""
	Local cTabProtheus 	:= ""
	Local cTabGeosales 	:= ""
	Local cStatus 		:= ""
	local cLinha
	local aLinha
	local aRecnosCandidatos
	local aRecnosSucesso
	local lSucessoEnvio := .T.
	local cTabAlias

	Local cSQL := ""
	Local aCpo := {}
	Local cValor := ""
	local aZX1Stuff

	Local _cAlias := "TABSQL"//GetNextAlias()
	local lHasRecno
	local cColunaCtxt := ""
	Local nLimitSql := 1000
	Local nPayload := 190000
	Local aRecnosJson := {}

	Local aLastRecno := {}
	Local aRecnosEnvio := {}

	Default cTabGeo		:= ""

	dbSelectArea("ZX0")
	ZX0->(dbSetOrder(4)) //ZX0_FILIAL + ZX0_TB_PRO
	ZX0->(dbGoTop())
	ZX0->(dbSeek(xFilial("ZX0") + cTabela + cTabGeo))

	cChave 		 := ZX0->(ZX0_FILIAL + ZX0_COD)
	cTabProtheus := ZX0->ZX0_TB_PRO
	cTabGeosales := ZX0->ZX0_TB_GEO
	cStatus 	 := ZX0->ZX0_STATUS
	cChangQ		 := Alltrim(ZX0->ZX0_CHANGQ)
	cSQL 		 := Alltrim(ZX0->ZX0_SQL)
	cColunaCtxt  := AllTrim(ZX0->ZX0_CCTX)

	if cColunaCtxt = nil .OR. cColunaCtxt = ""
		cColunaCtxt := "YGSENV"
	endif

	ZX0->(dbCloseArea())

	cRescue := POSICIONE("ZX2",2,xFilial("ZX2") + "RESCUE", "ZX2->ZX2_DESC")
	If cRescue != nil .AND. cRescue != ""
		nLimitSql := Val(cRescue)
	EndIf

	cPayload := POSICIONE("ZX2",2,xFilial("ZX2") + "PAYLOAD", "ZX2->ZX2_DESC")
	If cPayload != nil .AND. cPayload != ""
		nPayload := Val(cPayload)
	EndIf

	If cStatus == 'I'
		cJson := "INATIVO"
		Return cJson
	EndIf

	cTabAlias := cTabProtheus

	aCampo := verifyCampo(cSQL,cTabela,cColunaCtxt)
	cSql := aCampo[2]

	If aCampo[1]
		cTabAlias := 'X'
	EndIf

	If lParcUpd
		cSql := verifySQL(cSQL, nLimitSql, cTabAlias)
	EndIf

	IF cChangQ = 'A'
		cSql := changeQuery(cSQL)
	endIf

	while lHouveLeitura .AND. lSucessoEnvio .AND. (lParcUpd .OR. lPrimeiraLeitura )
		DBUseArea(.T.,'TOPCONN',TCGENQRY(,,cSql),_cAlias,.F.,.T.)

		If lPrimeiraLeitura
			lHasRecno := hasRecno(_cAlias)
			aZX1Stuff := getZX1Stuff(cChave)
			lPrimeiraLeitura := .F.
		EndIf

		lHouveLeitura := .F.
		nCnt := 0
		IncProc("Atualizando da tabela Protheus " + AllTrim(cTabProtheus) + " para a tabela GeoSales " + AllTrim(cTabGeosales))

		cJson := AllTrim(' {   ')
		cJson += AllTrim('     "' + Alltrim(Lower(cTabGeosales)) + '":[   ')
		nSize := len(cJson)
		aRecnosSucesso := {}
		aRecnosCandidatos := {}

		If Len(aLastRecno) != 0
			AADD(aRecnosSucesso, aLastRecno)
		EndIf

		While !(_cAlias)->(EOF())
			lHouveLeitura = .T.

			aLinha := linhaJson(_cAlias, aZX1Stuff, (_cAlias)->DELETED == 'T', lHasRecno)
			cLinha := aLinha[1]
			If lHasRecno .AND. aLinha[2] != nil
				AADD(aRecnosCandidatos, aLinha[2])
			EndIf
			cJson += cLinha
		
			If lHasRecno
				aadd( aRecnosJson, (_cAlias)->RECNO)
			EndIf
			//cTabela, cChave, cVerificaExclusao

			cJson += ","

			(_cAlias)->(dbSkip())

			nCnt++
			nSize += len(cLinha) + 1
			if (nSize > nPayload)

				cJson += AllTrim('     ] ')
				cJson += AllTrim(' } ')	

				lSucessoEnvio := eventoMAJs(bTratativaEventos, cJson, aRecnosCandidatos, aRecnosSucesso) .AND. lSucessoEnvio
				
				If lSucessoEnvio
					U_updEnvio(cTabela, cColunaCtxt, aRecnosJson)	
				EndIf
			
				nCnt := 0

				cJson := ""
				aRecnosJson := {}

				cJson += AllTrim(' {   ')
				cJson += AllTrim('     "' + Alltrim(Lower(cTabGeosales)) + '":[   ')
				nSize := len(cJson)
			EndIf
		EndDo

		(_cAlias)->(dbCloseArea())

		cJson += AllTrim('     ] ')
		cJson += AllTrim(' } ')	

		If nCnt > 0
			lSucessoEnvio := eventoMAJs(bTratativaEventos, cJson, aRecnosCandidatos, aRecnosSucesso) .AND. lSucessoEnvio
			
			If lSucessoEnvio
				U_updEnvio(cTabela, cColunaCtxt, aRecnosJson)			 
			EndIf
			
		EndIf
/*
		If lParcUpd .AND. len(aRecnosSucesso) > 0
			aLastRecno := ATail(aRecnosSucesso)
			cSqlQTD := "Select COUNT(*) QTD FROM ( " + cSql + " ) TB_QTD WHERE RECNO = '" + cValToChar(aLastRecno[1]) + "'"

			DBUseArea(.T.,'TOPCONN',TCGENQRY(,,cSqlQTD),_cAlias,.F.,.T.)
			nQTD := (_cAlias)->QTD
			(_cAlias)->(dbCloseArea())

			aRecnosEnvio := aRecnosSucesso
			If aLastRecno[2] != nQTD
				ASize(aRecnosEnvio, Len(aRecnosEnvio) - 1)
			Else
				aLastRecno := {}
			EndIf

			U_updEnvio(cTabela, cColunaCtxt, aRecnosEnvio)
		EndIf
*/
	EndDo
Return lSucessoEnvio

//-------------------------------------------------------------
/*/{Protheus.doc} getSql

Retorna o resultado do SQL que busca os dados que ainda no foram
enviados para o Geosales

@type function
@author Sam
@since 13/07/2018
@version 1.0
@param cTabela, character, Tabela Protheus
@return cSQL, Consulta SQL
@example
getSql('SA1', 'YGSENV')
/*/
//-------------------------------------------------------------
Static Function getSql(cTabela,cColunaCtxt)
	Local cSQL := ""
	Local cCampo := u_prefTb(cTabela)

	cSQL += " SELECT * FROM ( "
	cSQL += " SELECT "
	cSQL += "  ( CASE WHEN X.D_E_L_E_T_ = '*' THEN 'T' ELSE 'F' END ) AS DELETED, "
	cSQL += "  X.R_E_C_N_O_ AS RECNO, "
	cSQL += "  '" + cEmpAnt + cFilANt + "' AS EMPFIL, "
	cSQL += "  X.* "
	cSQL += " FROM " + RetSqlName(cTabela) + " X "
	cSQL += " WHERE 1=1 "
	cSQL += " AND X." + cCampo + "_"+ cColunaCtxt + " <> 'S' "
	cSQL += " ) X "

Return cSQL

//--------------------------------------------------------------
/*/{Protheus.doc} verifySql/
Funo usada para verificar e padronizar o SQL recebido
@type function
@author William V. Bastos
@since 24/01/2019
@version 1.0
@param cSql, character, consulta SQL a ser verificada
@param nLimit, numeric, quantidade a ser passada no TOP
@param cTabAlias, character, alias da tabela
@return cSqlFinal, character, consulta SQL resultante da 
verificao.
@example
verifySql("SELECT * FROM SA1", 10, "SA1")
/*/
//--------------------------------------------------------------
Static Function verifySql(cSql, nLimit)
	Local cSqlFinal := ""
	Local aSqlFinal := {}
	Local i	:= 0

	aSqlFinal := applyLimit(sqlToArr(cSql), nLimit)

	pushInArray(aSqlFinal,Len(aSqlFinal)+1,"ORDER BY RECNO")

	For i := 1 to Len(aSqlFinal)
		cSqlFinal += aSqlFinal[i] + " "
	Next i
Return cSqlFinal

//--------------------------------------------------------------
/*/{Protheus.doc} sqlToArr/
Funo usada para transformar uma string com o SQL em um array 
de palavras tratadas ( sem caracteres especiais )
@type function
@author William V. Bastos
@since 31/01/2019
@version 1.0
@param cSql, character, Consulta SQL a ser tratada
@return aSql, array, Array de palavras que compe o SQL
@example
sqlToArr("SELECT * FROM SA1")
/*/
//--------------------------------------------------------------
Static Function sqlToArr(cSql)
	Local aSql := StrtoKArr(cSql,' ')
	Local i := 1
	Local x, z	:= 1

	While i <= len(aSql)
		cWord := ""
		For x := 1 to len (aSql[i])
			cChar := Substr(aSql[i], x, 1)
			nCharAsc := Asc(cChar)
			If nCharAsc < 32 .OR. nCharAsc >= 127
				cWord += " "
			Else
				cWord += cChar
			EndIf
		Next x
		aAux := StrTokArr( cWord, " " )
		If len(aAux) > 1 
			aSql[i] := aAux[1]
			For z := 2 to Len(aAux)
				pushInArray(aSql, i+z-1, aAux[z])
			Next z
		Else
			aSql[i] := AllTrim(cWord)
		EndIf
		i += 1
	Enddo
return aSql

//--------------------------------------------------------------
/*/{Protheus.doc} applyLimit/
Funo usada para adicionar o cabealho nas querys
@type function
@author William V. Bastos
@since 24/01/2019
@version 1.0
@param aSql, array, Array contendo o SQL dividido em palavras
@param nLimit, numeric, O numero para limitar a quantidade de
retorno do SQL
@param cTabAlias, character, Alias da tabela tratada
@return aSql, array, Array contendo o SQL com o Cabealho dividido
em palavras e com o limite de retorno aplicado
@example
applyLimit(aSql, 1000, "SA1")
/*/
//--------------------------------------------------------------
Static Function applyLimit(aSql, nLimit)
	Local lHasLimit := .F.
	Local nPosInsert := 1
	Local cDB := TCGetDB()
	Local i := Len(aSql)

	If (cDB = "ORACLE")
		While ( i > 1 )
			If Upper(aSql[i]) = "FROM"
				exit
			EndIf

			If Upper(aSql[i]) = "WHERE"
				nPosInsert := i + 1
				lHasLimit := .T.
				exit
			EndIf

			i -= 1
		EndDo

		If lHasLimit
			pushInArray(aSql,nPosInsert," ROWNUM < " + cValToChar(nLimit+1) + " AND ")
		Else
			nPosInsert := Len(aSql) + 1
			pushInArray(aSql,nPosInsert," WHERE ROWNUM < " + cValToChar(nLimit+1))
		EndIf
		
	Else//(cDB = "MSSQL")
		nPosInsert := 2
		pushInArray(aSql,nPosInsert,"TOP " + cValToChar(nLimit))
	EndIf
Return aSql

//--------------------------------------------------------------
/*/{Protheus.doc} pushInArray/
Funo usada para adicionar uma informao na posio passada
incrementando o tamanho do array
@type function
@author William V. Bastos
@since 24/01/2019
@version 1.0
@param aArray, array, Array onde ser inserido os dados
@param nPosInsert, numeric, A posio onde ser inserido a 
informao
@param xInsert, variable, Informao a ser inserida no array
@return aArray, array, Array com a informao inserida na 
posio passada.
@example
pushInArray(aInfos, 3, "new info")
/*/
//--------------------------------------------------------------
Static Function pushInArray(aArray,nPosInsert,xInsert)
	ASize(aArray,Len(aArray) + 1)
	AIns(aArray,nPosInsert)
	aArray[nPosInsert] := xInsert
return aArray

/*/{Protheus.doc} verifyCampo
Funo responsvel por verificar o conteudo do campo SQL e,
a partir do tipo de informao, definir qual fluxo deve ser tomado.
@type  Function
@author William
@since 10/04/2019
@version 1.0
@param cCampo, character, conteudo do campo SQL no Layout
@param cTabela, character, nome da tabela utilizada
@return Array, posio [1] informao sobre a necessidade de definir
o Alias, posio [2] o campo SQL aps tratamento referente a seu tipo;
/*/
Static Function verifyCampo(cCampo,cTabela,cColunaCtxt)
	Local cSQL := ""
	Local lNeedAlias

	if Empty(cCampo)
		lNeedAlias := .T.
		cSQL := AllTrim(getSql(cTabela,cColunaCtxt))
	ElseIf Upper(Left(cCampo,6)) = "SELECT"
		lNeedAlias := .F.
		cSQL := execFunc(cCampo)
	Else
		lNeedAlias := .T.
		cSql := AllTrim(getSql(cTabela,cColunaCtxt))
		cCampo := execFunc(cCampo)
		cSql += " WHERE ( " + cCampo + " ) "
	EndIf
Return { lNeedAlias , cSQL }

/*/{Protheus.doc} execFunc
Funo responsvel por substituir os codigos
executaveis por seus resultados.
@type Function
@author William
@since 11/04/2019
@version 1.0
@param cCampo, character, campo no qual ser substituido
os codigos executveis
@return cCampo, character, campo composto pelo resultado
dos codigos executados
/*/
Static Function execFunc(cCampo)
	Local cChave := "${"
	Local nCount := 1
	Local cExp := ""
	Local lEscape := .F.
	Local aBusca := Array(2,"")
	Local i	:= 0

	While At(cChave,cCampo) != 0
		nInit := nAux := At(cChave,cCampo) + 2
		nCount := 1
		aBusca[1] := aBusca[2] := ""

		For i := nAux to Len(cCampo)
			aBusca[1] := aBusca[2]
			aBusca[2] := SubStr(cCampo,i,1)

			If (aBusca[2] = "}") .AND. !(aBusca[1] = "\")
				nCount -= 1
				nEnd := i
				exit
			EndIf
		Next

		cExp := &(SubStr( cCampo, nInit, nEnd-nInit ))
		cCampo := stuff(cCampo, nInit-2, (nEnd-nInit)+3, cExp)
	End
Return cCampo