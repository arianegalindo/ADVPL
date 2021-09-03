#include 'Protheus.ch'

//-----------------------------------------------------------------------------
/*/{Protheus.doc} jsonSM0

Esta função foi criada especificamente para o caso de buscar as informações da 
tabela SM0. A tabela SM0 é a tabela de empresas e filiais do Protheus só
podendo ser acessada a partir do arquivo sigamat.emp, devido a isso, 
não é possível utilizar queries, mas somente as funções relacionadas
ao dbSelectArea().

@type  Function
@author Sam
@since 26/07/2018
@version 1.0
/*/
//-----------------------------------------------------------------------------
User Function jsonSM0()
    Local cJSON := ""
    Local cResult := ""
    Local cFiliais := SUPERGETMV("MV_X_FIL", .F., "01")

    cJSON += '{'
    cJSON += '"organizacao_venda":['

    dbSelectArea("SM0")
    SM0->(dbGoTop())
    While !(SM0->(EOF()))
        If !(SM0->M0_CODFIL $ cFiliais)
            SM0->(dbSkip())
            loop
        EndIf

        cJSON += '{'
        cJSON += '"cd_org_venda":"'             + SUBS(AllTrim(SM0->(M0_CODIGO + M0_CODFIL)),1,20)  + '",'
        cJSON += '"nm_organizacao":"'           + SUBS(AllTrim(SM0->M0_FILIAL),1,70)                + '",'
        cJSON += '"end_organizacao":"'          + SUBS(AllTrim(SM0->M0_ENDCOB),1,64)                + '",'
        cJSON += '"bairro_organizacao":"'       + SUBS(AllTrim(SM0->M0_BAIRCOB),1,20)               + '",'
        cJSON += '"cidade_organizacao":"'       + SUBS(AllTrim(SM0->M0_CIDCOB),1,30)                + '",'
        cJSON += '"uf_organizacao":"'           + SUBS(AllTrim(SM0->M0_ESTCOB),1,2)                 + '",'
        cJSON += '"cnpj_organizacao":"'         + SUBS(AllTrim(SM0->M0_CGC),1,14)                   + '",'
        cJSON += '"cd_estoque":"'               + SUBS(AllTrim(SM0->(M0_CODIGO + M0_CODFIL)),1,20)  + '",'
        cJSON += '"cep_organizacao":"'          + SUBS(AllTrim(SM0->M0_CEPCOB),1,15)                + '",'
        cJSON += '"insc_estadual_organizacao":"'+ SUBS(AllTrim(SM0->M0_INSC),1,18)                  + '",'
        cJSON += '"fone_organizacao":"'         + SUBS(AllTrim(SM0->M0_TEL),1,30)                   + '"'
        cJSON += '},'    

        SM0->(dbSkip())
    End
    SM0->(dbCloseArea())

    cJSON += ']'
    cJSON += '}'
    
Return u_envJsonAplic(cJSON, 'J', , .F.) 