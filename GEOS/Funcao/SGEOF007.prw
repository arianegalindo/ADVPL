#include "protheus.ch"
#include "fileio.ch"

user function criatxt()
	Local cFile := "\ZX\JSON\arquivo.txt"
	Local nH

	nHandle := fCreate(cFile)
	If nHandle == -1
		MsgStop("Falha ao criar arquivo - erro "+str(ferror()))
		Return
	Endif

	// Escreve o texto mais a quebra de linha CRLF
	fWrite(nHandle,"Primeira Linha" + chr(13)+chr(10) )

	fWrite(nHandle,"Segunda linha"+chr(13)+chr(10))

	fClose(nHandle)

	Msginfo("Arquivo criado :" + cFile)
Return

//-------------------------------------------------------------
/*/{Protheus.doc} makeFileJson

Funo que monta o JSON segundo os dados informados nas
tabelas ZX0 e ZX1 para todos os dados que no foram
enviado para o Geosales

@type function
@author Sam
@since 12/07/2018
@version 1.0
@param cTabela, character, Tabela do Sistea Protheus
@param cTabGeo, character, Tabela do Sistema GeoSales
@return cFile, Arquivo JSON segundo tabela informada
@example
U_sendAllJson('SA1', 'CLIENTE')
/*/
//-------------------------------------------------------------
User Function makeFileJson(cTabela, cTabGeo)

	Local cFile := "ZX\JSON\arquivo.json"
	Local nHandle := ""
	Local bCriandoArquivo := {}
	Local lCreated := .F.
	Local lResult := .F.
	Local cDate := DTOC(DATE())
	Local cTime := TIME()

	cFile := u_pathVerify(cFile)

	nHandle := fOpen(cFile, FO_READWRITE + FO_SHARED)

	if nHandle = -1
		nHandle := fCreate(cFile)
		if nHandle = -1
			MsgStop("Falha ao criar arquivo - erro: " + str(ferror()))
			Return
		EndIf
		lCreated := .T.
		fSeek(nHandle, 0)
		fWrite(nHandle, Alltrim('{'))
	Else
		fSeek(nHandle, -1, FS_END)
		fWrite(nHandle, Alltrim(','))
	EndIf

	//INFO - Identificador desta entrada no Json (atualmente Data+Time)
	fWrite(nHandle, Alltrim(' " ' + cDate + ' - ' + cTime + ' ":[ '))

	bCriandoArquivo := {|JSON| writeJson(nHandle, Alltrim(JSON))}

	//INFO - Atualmente passamos TRUE no lParcUpd
	lResult := u_makeAllJson(cTabela, cTabGeo, .T., bCriandoArquivo)

	fSeek(nHandle, -1, FS_END)
	fWrite(nHandle, Alltrim(' ]} '))

	fClose(nHandle)

	If !lResult
		MsgStop("Ocorreu um problema ao coletar informaes")
	EndIf

Return cFile

//--------------------------------------------------------------
/*/{Protheus.doc} pathVerify/
Funo usada para verificar se o caminho informado no cFile existe,
caso contrario ir criar os diretrios.
@type function
@author William V. Bastos
@since 18/01/2019
@version 1.0
@param cFile, character, caminho desejado
@return cFullPath, character, caminho completo, existente/criado, 
partindo do diretrio atual do servidor
@example
u_pathVerify('ZX\JSON\arquivo.json')
/*/
//--------------------------------------------------------------
User Function pathVerify(cFile)
	Local i	:= 0
	Local cFullPath := "\" + CurDir()
	Local aDir := StrtoKArr(cFile,'\')

	If len(aDir) > 0
		For i := 1 to len(aDir) - 1 
			If .Not. ExistDir(cFullPath + aDir[i])
				MakeDir(cFullPath + aDir[i])
			EndIf
			cFullPath := cFullPath + aDir[i] + "\"
		Next i
		cFullPath := cFullPath + aDir[len(aDir)]
	EndIf

Return cFullPath

//--------------------------------------------------------------
/*/{Protheus.doc} writeJson/
Funo usada para unir o Json que esta sendo escrito com o
arquivo passado.
@type function
@author William V. Bastos
@since 08/01/2019
@version 1.0
@param nHandle, numeric, handler do arquivo alvo
@param cJson, character, Json a ser escrivo no arquivo
@return lRes, booleano, A escrita no arquivo ocorreu com sucesso
@example
writeJson(nHandler, '{}')
/*/
//--------------------------------------------------------------
Static Function writeJson(nHandle, cJson)
	Local lRes := .F.
	Local cFinalJson := ''
	cFinalJson += Alltrim(' ' + Alltrim(cJson) + ' ')
	cFinalJson += Alltrim(',')

	lRes := fWrite(nHandle, cFinalJson) = len(cFinalJson)
Return lRes

//-------------------------------------------------------------
/*/{Protheus.doc} makeConfFile

Funo responsavel por criar o arquivo usado na configurao
do JOB a partir da SMO

@type function
@author William V B
@since 03/05/2019
@version 1.0
@return cFile, Arquivo TXT contendo as empresas e filiais
/*/
//-------------------------------------------------------------
User Function makeConfFile()

	Local cFile := "IPG\CONF\jobConf.txt"
	Local nHandle := ""
	Local aSM0 := {}
	Local i := 1

	cFile := u_pathVerify(cFile)

	DbSelectArea("SM0")
	DbGotop()
	While !Eof()
		Aadd(aSM0, { M0_CODIGO, M0_CODFIL })
		DbSkip()
	EndDo
	DbCloseArea()

	nHandle := fCreate(cFile, FO_READWRITE + FO_SHARED)

	if nHandle = -1
		MsgStop("Falha ao criar arquivo - erro: " + str(ferror()))
		Return
	EndIf

	fSeek(nHandle, 0)
	fWrite(nHandle, 'Empresa;Filial' + CRLF)
	For i := 1 to Len(aSM0)
		fWrite(nHandle, Alltrim(aSM0[i][1] + ';' + aSM0[i][2] + CRLF))
	Next

	fClose(nHandle)
Return cFile

//-------------------------------------------------------------
/*/{Protheus.doc} setAccess

Salva uma informação de acesso para a lógica de ociosidade

@type function
@author @vbastos
@since 24/05/2019
@version 1.0
@return cFile, character, arquivo com as informações de acesso
/*/
//-------------------------------------------------------------
User Function setAccess(cCall)
	Local cFile := "ipg\access\access.txt"
	Local nHandle := ""

	cFile := u_pathVerify(cFile)

	nHandle := fOpen(cFile, FO_READWRITE + FO_SHARED)

	if nHandle = -1
		nHandle := fCreate(cFile)
		if nHandle = -1
			MsgStop("Falha ao criar arquivo - erro: " + str(ferror()))
			Return
		EndIf
		fSeek(nHandle, 0)
	Else
		fSeek(nHandle, 0, FS_END)
		fWrite(nHandle, CRLF)
	EndIf

	fWrite(nHandle, Alltrim(cCall + ";" + Month2str(date())+"/"+Day2Str(date())+"/"+year2str(date()) + ";" + cValToChar(Time())))

Return cFile

//-------------------------------------------------------------
/*/{Protheus.doc} getAccess

Obtem o tempo ocioso de acesso no periodo selecionado

@type function
@author @vbastos
@since 29/05/2019
@version 1.0
@param nOpc, numeric, numero indicando o periodo de tempo a ser
verificado: 1 - Dia atual
			2 - Mês atual
			3 - Total
@return aLines, array, Array contendo as informações de acesso
da opção selecionada
/*/
//-------------------------------------------------------------
User Function getAccess(nOpc)
	Local cFile := "ipg\access\access.txt"
	Local nHandle := ""
	Local aLines := {}
	Local nHour := 0
	Local nMin := 0
	Local nSec := 0
	Local i := 1	

	cFile := u_pathVerify(cFile)

	FT_FUSE(cFile)
	FT_FGOTOP()

	Do Case
		Case nOpc = "1"
			dInit := dFim := Date()
		Case nOpc = "2"
			dInit := FirstDate(Date())
			dFim := LastDate(Date())
		Case nOpc = "3"
			if !FT_FEOF()
				dInit := CToD(Strtokarr(FT_FREADLN(),";")[2])
			EndIf
			For  i := 1 to FT_FLastRec()-1
				FT_FSKIP()
			Next
			dFim := CToD(Strtokarr(FT_FREADLN(),";")[2])
			FT_FGOTOP()
		OTHERWISE
			return .F.
	EndCase

	While !FT_FEOF()
		aAux := Strtokarr(FT_FREADLN(),";")
		If (dInit <= CToD(aAux[2])) .AND. (dFim >= CToD(aAux[2]))
			AADD(aLines, aAux)
		EndIf
		FT_FSKIP()
	EndDo

	FT_FUSE()

	nAllTime := 0
	cFirst := ""

	For i := 1 to Len(aLines)
		If cFirst = ""
			cFirst := aLines[i][3]
		EndIf

		cElapsed := ElapTime(cFirst, aLines[i][3])
		nElapsed := VAL(SUBSTR(cElapsed, 1, 2))*(3600) + VAL(SUBSTR(cElapsed, 4, 2))*(60) + VAL(SUBSTR(cElapsed, 7, 2))
		nAllTime += nElapsed
		cFirst := aLines[i][3]
	Next

	cTime := ""
	cTime += cValToChar(floor(nAllTime/3600)) + "h "
	nMin := nAllTime % 3600
	cTime += cValToChar(floor(nMin/60)) + "m "
	nSec := nMin % 60
	cTime += cValToChar(nSec) + "s"

	ConOut( "O tempo ocioso entre as datas " + DTOC(dInit) + " e " + DTOC(dFim) + " foi igual a " + ctime )
return aLines