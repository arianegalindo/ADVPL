#Include 'Protheus.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} envJsonAplic

Envia os dados contidos no Json gerados pelo Protheus para a aplicação
Geosales. Caso o arquivo exista, porém esteja INATIVO a função
continua sem enviar os dados.

@type function
@author Sam
@since 10/07/2018
@version 1.0
@param cTabela, character, Tabela Protheus
@param cOp, character, Operação (I-INC/A-ALT/E-EXC/T-TODOS)
@param cTabGeo, character, Tabela  GeoSales
@param lParcUpd, booleano, executa atualização parcial (quando for T)
@return um vetor de duas posições: [1] false se deu algum erro, true se deu tudo certo, [2] vetor com as mensagens de erro
/*/
//-------------------------------------------------------------------
User function envJsonAplic(cTabela, cOp, cTabGeo, lParcUpd)
	Local cHost		:= U_getHost()							//"http://sync.geosalesmobile.com:8185"
	Local cPath		:= U_getPath()							//"erp-importer"
	Local cEmpHost	:= U_getEmpHost()						//"auster"
	Local aHeaderStr:= U_getHeaders({"TOKEN","CONTENT"})	//SSAUTH_TOKEN: 123 | Content-type: application/json

	Local cUrl     	:= cHost + '/' + cPath + '/' + cEmpHost + '/import'
	Local lEnvioOk 	:= .T.
	Local nTimeOut  := 240 //Segundos
	Local cHeaderRet:= ""
	Local cResponse := ""
	Local aResponse := {}

	Local cMsgHttp	:= "[GeoSales] Prévia HttpPost: "

	Default cTabGeo	:= ""
	Private aLogGeo	:= {'',cTabela,,dDataBase,Time(),'envJsonAplic',"","",'GEOS',,,cTabGeo,cUserName,,'1','3',''} //CAMPNEUS

	//------------------------------------------------------------
	//Validações da existencia das variáveis da URL
	//------------------------------------------------------------
	If Empty(cHost)
		cResponse := "HOST não configurado"
		conout(cMsgHttp + cResponse)
		Return {.F., {cResponse}}
	EndIf

	If Empty(cPath)
		cResponse := "PATH não configurado"
		conout(cMsgHttp + cResponse)
		Return {.F., {cResponse}}
	EndIf

	If Empty(cEmpHost)
		cResponse := "EMPHOST não configurado"
		conout(cMsgHttp + cResponse)
		Return {.F., {cResponse}}
	EndIf

	If Empty(aHeaderStr)
		cResponse := "HEADERS não configurados"
		conout(cMsgHttp + cResponse)
		Return {.F., {cResponse}}
	EndIf
	//------------------------------------------------------------

	//----------------------------------------------------
	//Verifica qual o tipo de operação
	//I - Incluir
	//A - Alterar
	//E - Excluir
	//T - Todos
	//J - JSON (Tabela é o próprio JSON)
	//----------------------------------------------------

	if cOP == 'T'
		lEnvioOk := U_makeAllJson(cTabela, cTabGeo, lParcUpd, {|cJsonStuff|, sendJs(cUrl, cJsonStuff, nTimeOut, aHeaderStr, aResponse)})
		//xPostPar := U_makeFileJson(cTabela, cTabGeo)
	ElseIf cOP $ 'A;E;I'
		lEnvioOk := U_makeUniJson(cTabela, cOP, {|cJsonStuff|, sendJs(cUrl, cJsonStuff, nTimeOut, aHeaderStr, aResponse)})
	Else //cOp == 'J'
		lEnvioOk := sendJs(cUrl, cTabela, nTimeOut, aHeaderStr, aResponse)
	EndIf
Return { lEnvioOk, aResponse }

static function sendJs(cUrl, cPostPar, nTimeOut, aHeaderStr, aResponse)
	Local cMsgHttp	:= "[GeoSales] Resposta HttpPost: "
	Local cResponse := nil
	Local cHeaderRet
	Local i
	Local cXmlEnv	:= ""
	Local cRestResponse	:= ""

	Local cTic := ""
	Local cTac := ""
	Local cElapsed := ""
	Local nElapsed := 0
	Local lExpired := .F.

	conout("[GeoSales] Preparando para HttpPost, tamanho do payload " + alltrim(str(len(cPostPar))))
	If cPostPar <> "INATIVO"
		cTic := Time()
		While .Not. lExpired
			cResponse := HttpPost( cUrl, "", cPostPar, nTimeOut, aHeaderStr, @cHeaderRet)
			cTac := Time()
			//add ACCESS
			//u_setAccess("SendJS")

			//INICIO CAMPNEUS
			
			cXmlEnv := " URL Envio: " + cUrl + CRLF
			cXmlEnv += " Body Post: " + cPostPar + CRLF
			
			cRestResponse := " Header: " + cHeaderRet + CRLF
			cRestResponse += " Body: " + cResponse + CRLF
			
			//aLogGeo[1] := FILIAL
			//aLogGeo[3] := "ARIANE"
			aLogGeo[5]	:= Time()
			aLogGeo[10] := cXmlEnv
			aLogGeo[11] := cRestResponse
			aLogGeo[14] := cUrl
			 
			U_ZZLOG001(aLogGeo)
			
			//FINAL CAMPNEUS

			If cResponse != nil
				exit
			EndIf

			cElapsed := ElapTime(cTic, cTac)
			nElapsed := VAL(SUBSTR(cElapsed, 1, 2))*(3600) + VAL(SUBSTR(cElapsed, 4, 2))*(60) + VAL(SUBSTR(cElapsed, 7, 2))

			lExpired := nElapsed > nTimeOut
		End

		If cResponse == nil
			cResponse := "Resultado nulo"
		EndIf

		conout(cMsgHttp + cResponse)
	Else
		cResponse := "INATIVO"
	EndIf

	If cResponse != "OK" .AND. cResponse != "INATIVO"
		aadd(aResponse, cResponse)
	EndIf
Return cResponse == "OK"