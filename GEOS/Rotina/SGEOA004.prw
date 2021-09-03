#Include 'Protheus.ch'
//-------------------------------------------------------------------
/*/{Protheus.doc} SGEOA004

Rotina de cadastros do Header HTTPPOST

@type function
@author Sam
@since 27/07/2018
@version 1.0
/*/
//-------------------------------------------------------------------
User Function SGEOA004()
	//---------------------------------------------------------//
	//Declaração de variáveis
	//---------------------------------------------------------//
	Private cPerg   	:= "1"
	Private cCadastro 	:= "Header da ROTINA"
	Private cDelFunc 	:= ".T." // Validacao para a exclusao. Pode-se utilizar ExecBlock
	Private cTabela 	:= "ZX3"
	Private cFiltro		:= ""
	Private	aIndexZX3	:= {}
	Private aIndex		:= {}
	Private cCodUse		:= RetCodUsr()
	Private bFiltraBrw 	:= { || FilBrowse( "ZX3" , @aIndex , @cFiltro ) } //Determina a Expressao do Filtro
	Private aRotina 	:= {}
	Private aRotAprov 	:= {}
	Private aRotStts 	:= {}
	Private aCores		:= { }
		
	AADD(aRotina, {"Pesquisar"		,"AxPesqui"		,0,1})
	AADD(aRotina, {"Visualizar"		,"AxVisual"		,0,2})
    AADD(aRotina, {"Incluir"		,"AxInclui"		,0,3})
	AADD(aRotina, {"Alterar"		,"AxAltera"		,0,4})
    AADD(aRotina, {"Excluir"		,"AxDeleta"		,0,5})
	
	dbSelectArea("ZX3")
	dbSetOrder(1)

	cPerg   := "1"

	Pergunte(cPerg,.F.)

	dbSelectArea(cTabela)
	
	montaDadosTab()
	
	mBrowse( 6,1,22,75,cTabela,,,,,6,)

	Set Key 123 To // Desativa a tecla F12 do acionamento dos parametros

	(cTabela)->(dbCloseArea())
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} montaDadosTab

Função para montar os itens da tabela que são padrões 

@type function
@author Sam
@since 27/07/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static function montaDadosTab()
	Local _cAlias := GetNextAlias()
	Local cSQL := "SELECT COUNT(*) QTD FROM " + RetSqlName("ZX3")
	Local aDados := montaResDados()
	Local lMatch := .F.
	Local i		:= 0
	
	cSql := changeQuery(cSQL)
	
	DBUseArea(.T.,'TOPCONN',TCGENQRY(,,cSql),_cAlias,.F.,.T.)
	nCount = (_cAlias)->QTD

	if nCount == 0
		For i := 1 to len(aDados)
			RecLock("ZX3", .T.)
				ZX3->ZX3_COD 		:= aDados[i][1]
				ZX3->ZX3_PARAM 		:= aDados[i][2]
				ZX3->ZX3_DESC 		:= aDados[i][3]
				ZX3->ZX3_CONTEU 	:= aDados[i][4]
			ZX3->(MsUnLock())
		Next i
	ElseIf nCount < len(aDados)
		dbSelectArea("ZX3")

		For i := 1 to len(aDados)
			ZX3->(dbGoTop())
			lMatch := .F.

			While .Not. (ZX3->(EOF()))
				If AllTrim(ZX3_PARAM) = aDados[i][2]
					lMatch := .T.
					EXIT
				EndIf
				ZX3->(dbSkip())
			EndDo

			If .Not. lMatch
				RecLock("ZX3", .T.)
					ZX3->ZX3_COD 		:= aDados[i][1]
					ZX3->ZX3_PARAM 		:= aDados[i][2]
					ZX3->ZX3_DESC 		:= aDados[i][3]
					ZX3->ZX3_CONTEU 	:= aDados[i][4]
				ZX3->(MsUnLock())
			EndIf
		Next i

		ZX3->(dbCloseArea())
	EndIf
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} montaResDados

Inclui os dados com código, Descricao do Header e Conteúdo do Header

@type function
@author Sam
@since 13/07/2018
@version 1.0
@return aDados, Dados da tabella
/*/
//-------------------------------------------------------------------
Static Function montaResDados()
	Local aDados := {}
	
	AADD(aDados, {"001" ,"TOKEN","SSAUTH_TOKEN",""})
	AADD(aDados, {"002", "CONTENT","Content-type","application/json"})
Return aDados