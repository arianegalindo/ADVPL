#Include 'Protheus.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} SGEOA005

Envio de dados da tabela SM0/ORGANIZACAO_VENDA

@type function
@author Sam
@since 27/07/2018
@version 1.0
/*/
//-------------------------------------------------------------------
User Function SGEOA005()
    Local cFiliais := SUPERGETMV("MV_X_FIL", .F., "01")
    If msgYesNo("Deseja incluir a(s) filial(is) " + cFiliais + " na tabela ORGANIZACAO_VENDA?")
        Processa( {|| u_jsonSM0() }, "Gerando ORGANIZACAO_VENDA", "Processando...", .F.)

        MsgInfo("Tabela atualizada com sucesso")
    EndIf
Return