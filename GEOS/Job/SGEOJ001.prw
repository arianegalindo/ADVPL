#Include 'Protheus.ch'
#Include 'apwebex.ch'
#Include 'apwebsrv.ch'
#include 'rwmake.ch'

/*/{Protheus.doc} SGEOOJ001

Job para envio dos dados no enviados para o Geosales

@type  Function
@author Sam
@since 18/07/2018
@version version
/*/
User Function SGEOJ001()
	Local aArea		:= GetArea()
	Local aEmpFil	:= {}
	Local cCodEmp	:= ""
	Local cCodFil	:= ""
	Local cError	:= ""
	Local _cFunction := ""
	Local nI		:= 0
	Local  oError	:= ErrorBlock({|e| conout("[GEOSALES] PROBLEMA NA EXECUCAO DO JOB ENVIO GEOSALES: EMPRESA [" + cCodEmp + "] FILIAL [" + cCodFil + "] METODO [EXECATU] ------------")})

	RPCSetType(3)
	RpcSetEnv( "02", "02010001" )

	aEmpFil	:= ZSGEOJ1A()

	For ni := 1 to Len(aEmpFil)
		cCodEmp := aEmpFil[ni][1]
		cCodFil := aEmpFil[ni][2]
		cError	:= ""

		conout("[GEOSALES] CONFIGURANDO AMBIENTE " + alltrim(cCodEmp) + " " + alltrim(cCodFil) + " ------------")
		RPCSetType(3)
		RpcSetEnv( cCodEmp, cCodFil )
		conout("[GEOSALES] INICIO EXECUCAO JOB ENVIO GEOSALES " + DTOC(DATE()) + " " + Time() + " ------------")

		BEGIN SEQUENCE

			//INICIO CUSTOMIZACAO CAMPNEUS - ARIANE - evitar execução multipla.
			_cFunction := "U_SGEOJ001_" + cCodEmp + cCodFil
			If LockByName(_cFunction,.F.,.F.)	
				U_execAtu('J')
				UnLockByName(_cFunction)
			Else
				conout("[GEOSALES] - FUNÇÃO " + _cFunction + " JÁ ESTÁ EM EXECUÇÃO " + DTOC(DATE()) + " " + Time() + " ------------") 
			EndIf
			//FIM CUSTOMIZACAO CAMPNEUS - ARIANE - evitar execução multipla.

		END SEQUENCE

		conout("[GEOSALES] FIM EXECUCAO JOB ENVIO GEOSALES " + DTOC(DATE()) + " " + Time() + " ------------")
		RestArea(aArea)
	Next

	ErrorBlock(oError)
Return

/*
Função para retornar lista de empresas ativas
Ariane Galindo
02/09/2019
*/

Static Function ZSGEOJ1A()
	Local cQuery 	:= ""
	Local cXAlias	:= GetNextAlias()
	Local aRet		:= {}

	cQuery := " SELECT ZZV.ZZV_DESCRI FILIAL "
	cQuery += " FROM " + RetSQLName('ZZV') + " ZZV "
	cQuery += " WHERE ZZV.ZZV_TABELA = 'FIL' " 
	cQuery += " AND ZZV.ZZV_CAMPNE <> '' "
	cQuery += " AND ZZV.ZZV_DESCRI <> '' "
	cQuery += " AND ZZV.D_E_L_E_T_ = ' ' "
	cQuery += " ORDER BY FILIAL "
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cXAlias, .T., .F. )

	While (cXAlias)->(!Eof())
		aadd(aRet,{"02",AllTrim((cXAlias)->FILIAL)})

		(cXAlias)->(DbSkip())
	EndDo

	(cXAlias)->(DbCloseArea())
Return aRet