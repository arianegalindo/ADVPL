#INCLUDE "PROTHEUS.CH" 
#INCLUDE "TOTVS.CH"
#include "TBICONN.ch"

/*
Executa Funcao em JOB
Ariane Galindo
18/10/2016
*/
User Function ZZEXGEOJ()

	RpcSetEnv("02", "02010001","GEOS01","GEOS01")
	u_ZExecGEO()
	RpcClearEnv()

Return
/*
Criado funcao automatica para chamar um unico job de todas as filiais.
Ariane Galindo
19/10/2016
*/

User Function ZExecGEO()
	Local cQuery 	:= ""
	Local cXAlias	:= GetNextAlias()
	Local aExec		:= {}

	cQuery := " SELECT ZZV.ZZV_DESCRI FILIAL "
	cQuery += " FROM " + RetSQLName('ZZV') + " ZZV "
	cQuery += " WHERE ZZV.ZZV_TABELA = 'FIL' " 
	cQuery += " AND ZZV.ZZV_CAMPNE <> '' "
	cQuery += " AND ZZV.D_E_L_E_T_ = ' ' "
	cQuery += " ORDER BY FILIAL "
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cXAlias, .T., .F. )

	While (cXAlias)->(!Eof())
		aAdd(aExec,{'02', AllTrim((cXAlias)->FILIAL) })

		(cXAlias)->(DbSkip())
	EndDo

	u_SFTIMP(aExec)

	(cXAlias)->(DbCloseArea())
Return 


/*
Autor: David de Oliveira Sobrinho
Data: 21/07/2013
Descrição: SFTIMP - Rotina de importação de dados de acordo layout cadastrados
*/

User Function SftImp(aParSch)
	//Variáveis auxiliares da tela de processamento  
	Local bProcess	:= {|oSelf| U_SFTA020(oSelf,lLog,.f.)  }
	Local cNomFun	:= "Integração Protheus x SoftSite [IMPORTAÇÃO]"
	Local cObjetivo	:= "Esta rotina tem o objetivo de importar dados do sistema SoftSite."
	Local lLog		:= .F.
	Local _lJob 	:= (Select('SX6')==0)
	Local aPar		:= {}
	Local nI		:= 0
	Local nPos		:= 0
	Local cFunction	:= ""

	Private oTProces

	Default aParSch	:= {}

	If Select("SX2")=0   //Se for via Schedule prepara o ambiente
		aParSch := {{"02","02010019"}}
	Endif	

	If Len(aParSch) >= 1
		aPar := aClone(aParSch)

		aUsers := GetUserInfoArray()

		nPos		:= 0

		aEval(aUsers,{|x| iif("U_SFTIMP" $ x[11] .and. x[3] <> ThreadID(),nPos++,nil)  })

		If nPos <= 0
			For nI := 1 to Len(aPar)
				conout(" Inicio Processamento Imp "+aPar[nI,1]+"/"+aPar[nI,2]+"-"+Time())

				//RpcSetType(2)
				//RpcSetEnv(aPar[nI,1],aPar[nI,2])  			

				//INICIO CAMPNEUS - ARIANE - 27/04
				cFilAnt := aPar[nI,2]
				_cFunction := 'U_WSGEO01' + cEmpAnt + cFilAnt
				
				If LockByName(_cFunction,.F.,.F.)	
					U_WSGEO01(nil,lLog,.t.)
					UnLockByName(_cFunction)
				EndIf
				//FIM CAMPNEUS - ARIANE - 27/04
				
				//RpcClearEnv()
				conout(" Fim Processamento Imp "+aPar[nI,1]+"/"+aPar[nI,2]+"-"+Time())
			Next	
		Endif

	Else	
		//tela de processamento
		oTProces := 	tNewProcess():New(	"SFTIMP",;
		cNomFun,;
		bProcess,;
		cObjetivo,;
		nil,;
		nil,;
		nil,;
		nil,;
		nil,;
		nil,;
		.T.)
		oTProces:SaveLog("Resultado de Processamento")

	EndIf

Return(.T.)    

/*
Autor: David de Oliveira Sobrinho
Data: 21/07/2013
Descrição: SFTIMP - Rotina de importação de dados de acordo layout cadastrados
*/

User Function SftPst(aParSch)
	//Variáveis auxiliares da tela de processamento  
	Local bProcess	:= {|oSelf| U_SFTA050(oSelf,lLog,.f.)  }
	Local cNomFun	:= "Integração Protheus x SoftSite [IMPORTAÇÃO]"
	Local cObjetivo	:= "Esta rotina tem o objetivo de importar dados do sistema SoftSite."
	Local lLog		:= .F.
	Local _lJob 	:= (Select('SX6')==0)
	Local aPar		:= {}
	Local nI		:= 0
	Local nPos		:= 0

	Private oTProces

	Default aParSch	:= {}

	If Select("SX2")=0   //Se for via Schedule prepara o ambiente
		aParSch := {{"01","0101"}}
	Endif	

	If Len(aParSch) >= 1
		//aPar := aClone(aParSch[1])
		aPar := {{"01","0101"}}

		aUsers := GetUserInfoArray()

		nPos		:= 0

		aEval(aUsers,{|x| iif("U_SFTPST" $ x[11] .and. x[3] <> ThreadID(),nPos++,nil)  })

		If nPos <= 0
			For nI := 1 to Len(aPar)
				conout(" Inicio Processamento Imp "+aPar[nI,1]+"/"+aPar[nI,2]+"-"+Time())

				RpcSetType(2)
				cFilAnt := aPar[nI,2]
				//RpcSetEnv(aPar[nI,1],aPar[nI,2])  			
				//			RPCSETTYPE(3)
				//			PREPARE ENVIRONMENT EMPRESA aPar[nI,1] FILIAL aPar[nI,2] TABLES "SB1","SA1","SA3","SB0","SE1","SC5","SC6","I02","I03","I04" MODULO "SIGAFAT"			

				U_WSGEO01(nil,lLog,.t.)

				//RpcClearEnv()
				conout(" Fim Processamento Imp "+aPar[nI,1]+"/"+aPar[nI,2]+"-"+Time())
			Next	
		Endif

	Else	
		//tela de processamento
		oTProces := 	tNewProcess():New(	"SFTPST",;
		cNomFun,;
		bProcess,;
		cObjetivo,;
		nil,;
		nil,;
		nil,;
		nil,;
		nil,;
		nil,;
		.T.)
		oTProces:SaveLog("Resultado de Processamento")

	EndIf

Return(.T.)    

/*
Autor: David de Oliveira Sobrinho
Data: 21/07/2013
Descrição: SFTVEN - Rotina para retorno de código do vendedor
*/

User Function SftVen(nVend)
	Local cVend 	:= ""
	Local cVendPar  := "" 
	Local nRecVen	:= 0
	/*
	cVendPar	:= Alltrim(Str(nVend))
	//cVendPar	:= Left(cVendPar,Len(cVendPar)-1)
	nRecVen		:= Val(cVendPar)		
	*/

	SA3->(DbGoTo(nVend))
	cVend := SA3->A3_COD

Return(cVend)

/*
Autor: Miguel França
Data: 13/09/2014
Descrição: (NEW) SFTIMP - Rotina para importa código do vendedor
*/

User Function SftJobImp()

	If Select("SX2")=0   //Se for via Schedule prepara o ambiente
		WFPrepEnv("01","010050")    
		lProcess := .F.
	Endif	

	Conout("Inicio da importação dos pedidos (Empr: 01 / Filial: 010050! "+DTOC(DATE())+" - "+TIME())

	U_SFTA020()     

	Conout("Fim da importação dos pedidos (Empr: 01 / Filial: 010050! "+DTOC(DATE())+" - "+TIME())

Return(.T.)


/*
Autor: Miguel França
Data: 13/03/2015
Descrição: SFTREC - Função desenvolvida para retorna qualquer campo de qualquer tabela apartir do valor RECNO.
*/
User Function SftREC(cTab, cValor, cCampo)

	Local cChaveRet 	:= ""
	Local cRetorno 	:= ""

	(cTab)->(DbGoTo(VAL(cValor)))
	cChaveRet := (cTab)->&(cCampo)            

	cRetorno := IIF(EMPTY(cChaveRet), "REGISTRO NAO ENCONTRADO",cChaveRet)

Return(cRetorno) 