#include 'Protheus.ch'

//-----------------------------------------------------------------------------
/*/{Protheus.doc} ipgSend

Função responsável por enviar os dados para
o GeoSales. Caso a resposta seja positiva, ou seja,
o serviço retorne 'OK' o campo <CAMPO>_YGSENV
será flagado como SIM

@type  Function
@author Sam
@since 20/07/2018
@version 1.0
@param cTabela, character, Descrição da tabela
@param cOP, character, Tipo de operação (I-Incluir/A-Alterar/E-Excluir)
@example
U_ipgSend('SA1', 'I')
/*/
//-----------------------------------------------------------------------------
User Function ipgSend(cTabela, cOP)
    Local cCampo := u_prefTb(cTabela)
    Local lEnvioSucesso := U_envJsonAplic(cTabela, cOP, ,.F.)[1]
    Local bTipoLock := .F.
	
    RecLock(cTabela, bTipoLock)
        &(cTabela + "->" + cCampo + "_YGSENV := '" + IIF(lEnvioSucesso,'S','N') + "'")
	MsUnLock()
Return 

//-----------------------------------------------------------------------------
/*/{Protheus.doc} ipgRel

Função responsável por enviar multiplos dados para
o GeoSales. Caso a resposta seja positiva, ou seja,
o serviço retorne 'OK' o campo <CAMPO>_YGSENV
será flagado como SIM

@type  Function
@author Sam
@since 26/07/2018
@version version
@param cTabela, character, Descrição da tabela Protheu
@param cTabGeo, character, Descrição da tabela Gesales
/*/
//-----------------------------------------------------------------------------
User Function ipgRel(cTabela, cTabGeo)
    Local lEnvioSucesso := .F.
    Local cOP := 'T'  
    Local bTipoLock := .F.
    Local cCampo := u_prefTb(cTabela)
        
    RecLock(cTabela, bTipoLock)
        &(cTabela + "->" + cCampo + "_YGSENV := 'N'")
	MsUnLock()         
    
    lEnvioSucesso := U_envJsonAplic(cTabela, cOp, cTabGeo, .F.)[1]
				
    if lEnvioSucesso
        U_updEnvio(cTabela)
    EndIf
Return 

//-----------------------------------------------------------------------------
/*/{Protheus.doc} execPeMVC

Função para executar pontos de entrada no modelo MVC, que são os pontos
de entrada para a versão 12 do Protheus

@type  Function
@author Sam
@since 23/07/2018
@version 1.0
@param cTabela, Character, Tabela do Banco de Dados
/*/
//-----------------------------------------------------------------------------
User Function execPeMVC(cTabela, aParam)
    Local xRet := .T.
    Local oObj := ""
    Local cIdPonto := ""
    Local cIdModel := ""
    Local nOper := 0

    If aParam <> NIL
        oObj := aParam[1]
        cIdPonto := aParam[2]
        cIdModel := aParam[3]

        If cIdPonto == "FORMCOMMITTTSPOS"
            nOper := oObj:oEventHandler:aEvents[1]:nOpc

            If nOper == 3 //Inclui
                U_ipgSend(cTabela, 'I')
            ElseIf nOper == 4 //Altera
                U_ipgSend(cTabela, 'A')
            ElseIf nOper == 5 //Exclui
                U_ipgSend(cTabela, 'E')
            EndIf
        EndIf
    EndIf
Return xRet

//-----------------------------------------------------------------------------
/*/{Protheus.doc} limpaFlagGS

Função para limpar a flag do _YGSENV

@type  Function
@author Sam
@since 26/07/2018
@version version
@param ctabela, character, Nome tabela Protheus
/*/
//-----------------------------------------------------------------------------
User Function limpaFlagGS(cTabela, cTabPai)
    Local cCampo := u_prefTb(cTabela)
    Local bTipoLock := .F.
    Local cChave := ""
    Local cRes := ""
    Local cBusca := ""

    Local _cTab := ""
    Local _cChvPadrao := ""

    Local xArea := getArea()

    Default cTabPai := ""

    if Empty(cTabPai)
        cBusca := cTabela + '1'
        _cTab  := cTabela
    Else 
        cBusca := cTabPai + '1'
        _cTab  := cTabPai
    EndIf

    dbSelectArea("SIX")
    SIX->(dbSeek(cBusca))

    cChave := AllTrim(SIX->CHAVE)
    cRes := (_cTab)->(&cChave)
	
    dbSelectArea(cTabela)
    (cTabela)->(dbSetorder(1))
    (cTabela)->(dbGoTop())
    (cTabela)->(dbSeek(cRes))

    if Empty(cTabPai)
        _cChvPadrao := cChave
    Else 
        _cChvPadrao := convChave(cChave, cTabela, cTabPai)
    EndIf

    While !(EOF()) .AND. Alltrim((cTabela)->(&_cChvPadrao)) == AllTrim(cRes)
        RecLock(cTabela, bTipoLock)
            &(cTabela + "->" + cCampo + "_YGSENV := 'N'")
        MsUnLock()

        (cTabela)->(dbSkip())
    End

    (cTabela)->(dbGoTop())
    (cTabela)->(dbSeek(cRes))

    RestArea(xArea)
Return 

//-----------------------------------------------------------------------------
/*/{Protheus.doc} convChave

Monta a chave da tabela filha a partir da tabela pai

@type  Static Function
@author Sam
@since 31/07/2018
@version 1.0
@param cChaveFilha, character, Chave filha
@param cTabFilha, character, Tabela filha
@param cTabPai, character, Tabela Pai
@return cRet, character, Nova chave
@example
convChave('C6_FILIAL+C6_NUM', 'SC6', 'SC5')
/*/
//-----------------------------------------------------------------------------
Static Function convChave(cChaveFilha, cTabFilha, cTabPai)
    Local cRet := cChaveFilha
    Local cCampoPai := ""
    Local cCampoFilho := ""

    cCampoPai := u_prefTb(cTabPai)
    cCampoFilho := u_prefTb(cTabFilha)

    cRet := StrTran(cRet, cTabPai, cTabFilha)
    cRet := StrTran(cRet, cCampoPai, cCampoFilho)
Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} delaySend

Função chamada para adiar o envio de dados na tabela.
É atribuido o valor N para a coluna de contexto da tabela para que,
no proximo envio, os dados sejam sincronizados com a GeoSales.

@type function
@author William - @vbastos
@since 01/04/2019
@version 1.0
@param cTabela, character, Tabela Protheus
//-------------------------------------------------------------------
/*/
User Function delaySend(cTabela)
	Local cCampo := u_prefTb(cTabela)
	Local aCtxt := {}
	Local x		:= 0

	aCtxt := u_findCtxt(cTabela)
	
	For x := 1 to Len(aCtxt)
		RecLock(cTabela, .F.)
		&(cTabela + "->" + cCampo + "_" + aCtxt[x] + " := 'N'")
		MsUnLock()
	Next

Return