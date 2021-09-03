#Include 'Protheus.ch'
//-------------------------------------------------------------------
/*/{Protheus.doc} SGEOA002

Rotina de configuração do Integrador

@type function
@author Sam
@since 05/11/2018
@version 1.0
/*/
//-------------------------------------------------------------------
User Function SGEOA006()
	//---------------------------------------------------------//
	//Declaração de variáveis
	//---------------------------------------------------------//
	Private cPerg   	:= "A"
	Private cCadastro 	:= "Configuração de Pontos de Entrada"
	Private cDelFunc 	:= ".T." // Validacao para a exclusao. Pode-se utilizar ExecBlock
	Private cTabela 	:= "ZX4"
	Private cFiltro		:= ""
	Private	aIndexZX4	:= {}
	Private aIndex		:= {}
	Private cCodUse		:= RetCodUsr()
	Private bFiltraBrw 	:= { || FilBrowse( "ZX4" , @aIndex , @cFiltro ) } //Determina a Expressao do Filtro
	Private aRotina 	:= {}
	Private aRotAprov 	:= {}
	Private aRotStts 	:= {}
	Private aCores		:= { }
		
	AADD(aRotina, {"Pesquisar"		,"AxPesqui"		,0,1})
	AADD(aRotina, {"Visualizar"		,"AxVisual"		,0,2})
	AADD(aRotina, {"Alterar"		,"AxAltera"		,0,4})
	
	dbSelectArea("ZX4")
	dbSetOrder(1)

	cPerg   := "A"

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
@author Sam
@since 13/07/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static function montaDadosTab()
	Local _cAlias := GetNextAlias()
	Local cSQL := "SELECT COUNT(*) QTD FROM " + RetSqlName("ZX4")
	Local aDados := ""
	Local i	:= 0
	
	cSql := changeQuery(cSQL)
	
	DBUseArea(.T.,'TOPCONN',TCGENQRY(,,cSql),_cAlias,.F.,.T.)
	
	if (_cAlias)->QTD == 0
		aDados := montaResDados()
		
		For i := 1 to len(aDados)
			RecLock("ZX4", .T.)
				ZX4->ZX4_COD 	:= aDados[i][1]
				ZX4->ZX4_PE 	:= aDados[i][2]
				ZX4->ZX4_STATUS	:= aDados[i][3]
				ZX4->ZX4_LINK 	:= aDados[i][4]
			ZX4->(MsUnLock()) 
		Next i
	EndIf
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} montaResDados

Inclui os dados com código, alias e definição

@type function
@author Sam
@since 05/11/2018
@version 1.0
@return aDados, Dados da tabella
/*/
//-------------------------------------------------------------------
Static Function montaResDados()
	Local aDados := {}

	AADD(aDados, {"000001", "M030EXC" , "D", "https://goo.gl/LyLNMh"})
	AADD(aDados, {"000002", "M030INC" , "D", "https://goo.gl/8Wp4FD"})
	AADD(aDados, {"000003", "M030PALT" , "D", "https://goo.gl/qTbkWW"})
	AADD(aDados, {"000004", "MA035ALT" , "D", "https://goo.gl/5AvjNJ"})
	AADD(aDados, {"000005", "MA035DEL" , "D", "https://goo.gl/4CGXuo"})
	AADD(aDados, {"000006", "MA035INC" , "D", "https://goo.gl/QnPVk7"})
	AADD(aDados, {"000007", "MA040DAL" , "D", "https://goo.gl/4j5ieH"})
	AADD(aDados, {"000008", "MA040DIN" , "D", "https://goo.gl/CBGZkd"})
	AADD(aDados, {"000009", "MT040DEL" , "D", "https://goo.gl/3oLifY"})
	AADD(aDados, {"000010", "MA050TTS" , "D", "https://goo.gl/89cv3F"})
	AADD(aDados, {"000011", "MT010ALT" , "D", "https://goo.gl/aG1U79"})
	AADD(aDados, {"000012", "MT010EXC" , "D", "https://goo.gl/vkUygX"})
	AADD(aDados, {"000013", "MT010INC" , "D", "https://goo.gl/z5NA9d"})
	AADD(aDados, {"000014", "MT360GRV" , "D", "https://goo.gl/QzCVup"})
	AADD(aDados, {"000015", "OS010GRV" , "D", "https://goo.gl/uwYseV"})
	AADD(aDados, {"000016", "OS010EXT" , "D", "https://goo.gl/fv1TVV"})
	AADD(aDados, {"000017", "FA60BDE" , "D", "https://goo.gl/VsHckV"})
	AADD(aDados, {"000018", "MSD2460" , "D", "https://goo.gl/hfP5EC"})
	AADD(aDados, {"000019", "MSD2520" , "D", "https://goo.gl/nuQCCh"})
Return aDados