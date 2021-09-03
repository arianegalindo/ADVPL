#Include 'Protheus.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} SGEOA003

Rotina para envio dos dados do Protheus que, por algum motivo,
não foram enviados ao GeoSales.

@type function
@author Sam
@since 13/07/2018
@version 1.0
/*/
//-------------------------------------------------------------------
User Function SGEOA003()
	Local cTitulo := "Carregando dados para atualização"
	Local cDialog := "Aguarde processamento..."
	
	Processa( {|| U_execAtu('M') }, cTitulo, cDialog, .F.)
Return