#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"   
#INCLUDE "TBICONN.CH" 


User Function SFTJOB1()
Local nI	:= 0
Local aInfo := GetUserInfoArray()

Conout(" ***** INICIANDO IMPORTACAO DE PEDIDOS DA EMPRESA CAMPNEUS !! ***** "+DTOC(DATE())+" - "+TIME())
   
For nI := 1 To Len(aInfo)

	If (	(aInfo[nI][1] == "SFTJOB1" .AND. aInfo[nI][3] <> Threadid()) .OR. ("U_SFTJOB1" $ aInfo[nI][11] .AND. aInfo[nI][3] <> ThreadID())	)
			CONOUT(" ********** Processamento SFTJOB1 ja esta sendo executado!")     
			CONOUT(" ********** Importacao dos pedidos Finalizada!")			
		    alert(" ********** Processamento SFTJOB1 ja esta sendo executado!")    
		    alert(" ********** Importacao dos pedidos Finalizada!")    
			Return    
	Endif

Next nI
	U_SFTIMP01() 

Conout(" ***** FIM DA IMPORTACAO DE PEDIDOS DA EMPRESA CAMPNEUS !! ***** "+DTOC(DATE())+" - "+TIME())    
   
Return


/*
Data: 13/06/2018
Descrição: SFTIMP01 - Rotina para importa pedido por Filial
*/

//---------------------FILIAL - 01 ---------------------------------------------------

User Function SFTIMP01()
	
	Local cOrgEmp := "02" // Codigo da Empresa
	Local cNumEmp := "02010014" // Codigo da Filial
	
	RpcSetType(3)
	RpcSetEnv( cOrgEmp, cNumEmp )   
	
	Conout(" ")
	Conout("Inicio da importação dos pedidos (Empr: "+cOrgEmp+" / Filial: "+ cNumEmp +"! "+DTOC(DATE())+" - "+TIME())
	 
	U_WSGEO01(cNumEmp)     
	
	Conout("Fim da importação dos pedidos (Empr: "+cOrgEmp+" / Filial: "+ cNumEmp +"! "+DTOC(DATE())+" - "+TIME())
	Conout(" ")
	
	RpcClearEnv()
	
Return(.T.)
