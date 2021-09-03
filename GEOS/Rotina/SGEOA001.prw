#Include "Protheus.ch"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} SGEOA001

Rotina para a geração do integrador Protheus x Geosales. 

@type function
@author Sam
@since 09/07/2018
@version 1.0
/*/
//-------------------------------------------------------------------
User Function SGEOA001()
	Local oBrowse
	
	Private cFSWRotina	:= "SGEOA001"
	Private cTabela 	:= "ZX0" //Integrador Geosales - Cabec
	Private cIniCampo 	:= u_prefTb(cTabela)
	
	Private cGrid 		:= "ZX1" //Integrador Geosales - Itens
	Private cIniGrid 	:= u_prefTb(cGrid)
	
	Private cDescRot 	:= "Integrador Geosales"
	
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias(cTabela)
	oBrowse:SetDescription(cDescRot)
	oBrowse:SetMenuDef( 'SGEOA001' )
	
	oBrowse:AddLegend( "ZX0->ZX0_STATUS == 'A'", "GREEN", "Ativo")
	oBrowse:AddLegend( "ZX0->ZX0_STATUS == 'I'", "RED", "Inativo")
	
	oBrowse:Activate()
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef

Monta o menu
	
@type function
@author Sam Barros
@since 09/07/2018
@version 1.0	
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
	Local cCodUsr := RetCodUsr()
	Private aRotina := {}
	
	ADD OPTION aRotina TITLE "Pesquisar"				ACTION "VIEWDEF.SGEOA001"		OPERATION 1 ACCESS 0	//DISABLE MENU
	ADD OPTION aRotina TITLE "Visualizar"				ACTION "VIEWDEF.SGEOA001"		OPERATION 2 ACCESS 0
	ADD OPTION aRotina TITLE "Incluir"					ACTION "VIEWDEF.SGEOA001"		OPERATION 3 ACCESS 0
	ADD OPTION aRotina TITLE "Alterar"					ACTION "VIEWDEF.SGEOA001"		OPERATION 4 ACCESS 143
	ADD OPTION aRotina TITLE "Excluir"					ACTION "VIEWDEF.SGEOA001"		OPERATION 5 ACCESS 144
	ADD OPTION aRotina TITLE "Copiar"					ACTION "VIEWDEF.SGEOA001"		OPERATION 9 ACCESS 0
	ADD OPTION aRotina TITLE "Imprimir"					ACTION "VIEWDEF.SGEOA001"		OPERATION 8 ACCESS 0
	ADD OPTION aRotina TITLE "(Des)Ativar"				ACTION "U_AtivaIntegra()"		OPERATION 8 ACCESS 0
	ADD OPTION aRotina TITLE "Ativar Todos"				ACTION "U_atvTodos()"			OPERATION 8 ACCESS 0
	ADD OPTION aRotina TITLE "Desativar Todos"			ACTION "U_desTodos()"			OPERATION 8 ACCESS 0
	ADD OPTION aRotina TITLE "Gerar Padrão Integrator"	ACTION "U_gerarIntegPadrao()"	OPERATION 3 ACCESS 0
	ADD OPTION aRotina TITLE "Gerar Padrão Importer"	ACTION "U_gerarImportPadrao()"	OPERATION 3 ACCESS 0
	If FWIsAdmin(cCodUsr)																						//Admin
		ADD OPTION aRotina TITLE "Gerar ZX0"			ACTION "U_makeTxtFile('ZX0')"	OPERATION 8 ACCESS 0
		ADD OPTION aRotina TITLE "Gerar ZX1"			ACTION "U_makeTxtFile('ZX1')"	OPERATION 8 ACCESS 0
	EndIf
Return aRotina
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

Gera as definições do modelo

@type function	
@author Sam Barros
@since 09/07/2018
@version 1.0		
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
	Local oStructHead	:= Nil
	Local oStructBody	:= Nil
	Local oModel    	:= Nil
	Local cDefCampos	:= ""

	cDefCampos		:= cIniCampo+"_COD|" + cIniCampo+"_TB_PRO|" + cIniCampo+"_TB_GEO|" + cIniCampo+"_DESC|" + cIniCampo+"_STATUS|" + cIniCampo+"_CHANGQ|" + cIniCampo+"_CCTX|" + cIniCampo+"_SQL|
	cDefGrid		:= cIniGrid+"_ITEM|" + cIniGrid+"_CP_PRO|" + cIniGrid+"_TIPO|" + cIniGrid + "_CP_GEO|" + cIniGrid + "_OBS|" + cIniGrid + "_TAM|"  + cIniGrid + "_DECIMA|"
	
	oStructHead 	:= FWFormStruct(1,cTabela,	{|cCampo|  AllTrim(cCampo)+"|" $ cDefCampos})
	oStructBody 	:= FWFormStruct(1,cGrid,	{|cGrid |  AllTrim(cGrid )+"|" $ cDefGrid})

	oModel:= MPFormModel():New("SGEO01", /*Pre-Validacao*/,/*Pos-Validacao*/,/*Commit*/,/*Cancel*/)

	oModel:AddFields("SGEO01_HEAD", /*cOwner*/, oStructHead ,/*Pre-Validacao*/,/*Pos-Validacao*/,/*Carga*/)
	oModel:GetModel("SGEO01_HEAD"):SetDescription(cDescRot)
	
	oModel:AddGrid("SGEO01_BODY", "SGEO01_HEAD", oStructBody , ,{ |oModelGrid, nLine, cAction, cField| .T. },/*bPre*/,/*bPost*/,/*Carga*/)
	oModel:GetModel("SGEO01_BODY"):SetUseOldGrid()
	oModel:GetModel("SGEO01_BODY"):SetUniqueLine({cIniGrid+"_CP_PRO", cIniGrid+"_CP_GEO"})
	
	oModel:SetPrimaryKey({cIniCampo+"_FILIAL",cIniCampo+"_COD"})
	oModel:SetRelation("SGEO01_BODY",{{cIniGrid+"_FILIAL",'xFilial("'+cTabela+'")'},{cIniGrid+"_COD",cIniCampo+"_COD"}},(cGrid)->(IndexKey()))	
Return(oModel)

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

Gera as definições de visualização
	
@type function
@author Sam Barros
@since 09/07/2018
@version 1.0		
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
	Local oView			:= Nil
	Local oStructHead	:= Nil
	Local oStructBody	:= Nil
	Local oModel		:= FWLoadModel("SGEOA001")
	Local cDefCampos	:= ""

	cDefCampos		:= cIniCampo+"_COD|" + cIniCampo+"_TB_PRO|" + cIniCampo+"_TB_GEO|" + cIniCampo+"_DESC|" + cIniCampo+"_STATUS|" + cIniCampo+"_CHANGQ|" + cIniCampo+"_CCTX|" + cIniCampo+"_SQL|"
	cDefGrid		:= cIniGrid+"_ITEM|" + cIniGrid+"_CP_PRO|" + cIniGrid+"_TIPO|" + cIniGrid + "_CP_GEO|" + cIniGrid + "_OBS|" + cIniGrid + "_TAM|"  + cIniGrid + "_DECIMA|"
	
	oStructHead 	:= FWFormStruct(2,cTabela,	{|cCampo|  AllTrim(cCampo)+"|" $ cDefCampos})
	oStructBody 	:= FWFormStruct(2,cGrid,	{|cGrid |  AllTrim(cGrid )+"|" $ cDefGrid})

	oStructHead:RemoveField( cIniCampo+"_FILIAL" )
	oStructBody:RemoveField( cIniGrid+"_FILIAL" )

	oView := FWFormView():New()

	oView:SetModel(oModel)

	oView:AddField( "SGEO01_HEAD",oStructHead)
	oView:CreateHorizontalBox("CABEC",40)
	oView:SetOwnerView( "SGEO01_HEAD","CABEC")
	oView:EnableControlBar(.T.)

	oView:AddGrid("SGEO01_BODY",oStructBody)
	oView:AddIncrementField("SGEO01_BODY",cIniGrid+"_ITEM")
	oView:CreateHorizontalBox("GRID",60)
	oView:SetOwnerView( "SGEO01_BODY","GRID")
Return oView