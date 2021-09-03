#include 'Protheus.ch'

//-------------------------------------------------------------
/*/{Protheus.doc} prefTb

Qual o prefixo dos campos da tabela informada?

@type function
@author Jeff Quesado
@since 13/11/2018
@version 1.0
@param cTabela, character, Tabela do Sistema Protheus
@return cPrefix, prefixo do campo da tabela
@example
u_prefTb('SA1') ==> 'A1'
u_prefTb('MA0') ==> 'MA0'
/*/
//-------------------------------------------------------------
User Function prefTb(cTabela)
Return IIF(SUBS(cTabela,1,1)=='S', SUBS(cTabela,2,2), cTabela)

/*/{Protheus.doc} geraGsEnv

Cria string da tabela com final _YGSENV

@type  Function
@author Sam Barros
@since 14/11/2018
@version 1.0
@return cRet, Campo da tabela
@example
/*/
User Function geraGsEnv(cTabela)
Return u_prefTb(cTabela) + "_YGSENV"
