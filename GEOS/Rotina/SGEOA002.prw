#Include 'Protheus.ch'
//-------------------------------------------------------------------
/*/{Protheus.doc} SGEOA002

Rotina de configuração do Integrador
- HOST
- PATH
- EMPHOST

@type function
@author Sam
@since 11/07/2018
@version 1.0
/*/
//-------------------------------------------------------------------
User Function SGEOA002()
	//---------------------------------------------------------//
	//Declaração de variáveis
	//---------------------------------------------------------//
	Private cPerg		:= "1"
	Private cCadastro	:= "Configuração da Rotina"
	Private cDelFunc	:= ".T." // Validacao para a exclusao. Pode-se utilizar ExecBlock
	Private cTabela		:= "ZX2"
	Private cFiltro		:= ""
	Private	aIndexZX2	:= {}
	Private aIndex		:= {}
	Private cCodUse		:= RetCodUsr()
	Private bFiltraBrw	:= { || FilBrowse( "ZX2" , @aIndex , @cFiltro ) } //Determina a Expressao do Filtro
	Private aRotina		:= {}
	Private aRotAprov	:= {}
	Private aRotStts	:= {}
	Private aCores		:= { }

	AADD(aRotina, {"Pesquisar"		,"AxPesqui"		,0,1})
	AADD(aRotina, {"Visualizar"		,"AxVisual"		,0,2})
	AADD(aRotina, {"Alterar"		,"AxAltera"		,0,4})

	dbSelectArea("ZX2")
	dbSetOrder(1)

	cPerg	:= "1"

	Pergunte(cPerg,.F.)

	dbSelectArea(cTabela)

	montaDadosTab()

	mBrowse( 6,1,22,75,cTabela,,,,,6,)

	Set Key 123 To // Desativa a tecla F12 do acionamento dos parametros

	(cTabela)->(dbCloseArea())
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} montaDadosTab

Função para montar os itens da tabela que são padrões e não podem
ser incluídos, apenas alterados ou visualizados

@type function
@author Sam / William - @vbastos
@since 13/07/2018
@version 1.0.190311
/*/
//-------------------------------------------------------------------
Static function montaDadosTab()
	Local _cAlias := GetNextAlias()
	Local cSQL := "SELECT COUNT(*) QTD FROM " + RetSqlName("ZX2")
	Local aDados := montaResDados()
	Local lMatch := .F.
	Local i := 0

	cSql := changeQuery(cSQL)

	DBUseArea(.T.,'TOPCONN',TCGENQRY(,,cSql),_cAlias,.F.,.T.)
	nCount = (_cAlias)->QTD

	if nCount == 0
		For i := 1 to len(aDados)
			RecLock("ZX2", .T.)
				ZX2->ZX2_COD 	:= aDados[i][1]
				ZX2->ZX2_PARAM 	:= aDados[i][2]
				ZX2->ZX2_DEF 	:= aDados[i][3]
				ZX2->ZX2_DESC	:= aDados[i][4]
			ZX2->(MsUnLock())
		Next i
	ElseIf nCount < len(aDados)
		dbSelectArea("ZX2")

		For i := 1 to len(aDados)
			ZX2->(dbGoTop())
			lMatch := .F.

			While .Not. (ZX2->(EOF()))
				If AllTrim(ZX2_PARAM) = aDados[i][2]
					lMatch := .T.
					EXIT
				EndIf
				ZX2->(dbSkip())
			EndDo

			If .Not. lMatch
				RecLock("ZX2", .T.)
					ZX2->ZX2_COD 	:= aDados[i][1]
					ZX2->ZX2_PARAM 	:= aDados[i][2]
					ZX2->ZX2_DEF 	:= aDados[i][3]
					ZX2->ZX2_DESC	:= aDados[i][4]
				ZX2->(MsUnLock())
			EndIf
		Next i

		ZX2->(dbCloseArea())
	EndIf
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} montaResDados

Inclui os dados com código, alias e definição

@type function
@author Sam
@since 13/07/2018
@version 1.0
@return aDados, Dados da tabella
/*/
//-------------------------------------------------------------------
Static Function montaResDados()
	Local aDados := {}

	AADD(aDados, {"01" ,"HOST","URL base do serviço de comunicação GeoSales","http://sfa.geosales.com.br:8185"})
	AADD(aDados, {"02", "PATH","Caminho para o servico de importação de dados","erp-importer"})
	AADD(aDados, {"03", "EMPHOST","Nome da empresa",""})
	AADD(aDados, {"04", "PAYLOAD","Tamanho máximo do pacote a ser enviado em bytes","190000"})
	AADD(aDados, {"05", "RESCUE","Quantidade de linhas para retorno no TOP do SQL passado (Não ultrapassar o valor indicado: 1000)","1000"})
	AADD(aDados, {"06", "PATHIMP","Caminho para o servico de integração de dados","erp-integrator"})
Return aDados