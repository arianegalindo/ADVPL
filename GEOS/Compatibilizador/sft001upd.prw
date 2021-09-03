#INCLUDE "PROTHEUS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄ-ÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³SFT001UPD ³ Autor ³ OPVS C.A.             ³ Data ³ 18/06/2013 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄ-ÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Funcao Principal                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄ-ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³                                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ-ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function SFT001UPD(cTab)
	PRIVATE cArqEmp		:= "SigaMat.Emp"
	PRIVATE __cInterNet	:= Nil
	PRIVATE cMessage	:= ""
	PRIVATE aArqUpd		:= {}
	PRIVATE aREOPEN		:= {}
	PRIVATE nModulo		:= 51
	PRIVATE lEmpenho	:= .F.
	PRIVATE lAtuMnu		:= .F.
	PRIVATE oMainWnd

	Default cTab		:= ""

	SET DELETE ON

	Processa({|| ProcATU(cTab)},"Processando [OPV001UPD]","Aguarde , processando preparação dos arquivos")
Return(.T.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄ-ÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ProcATU   ³ Autor ³ OPVS C.A.             ³ Data ³ 18/06/2013 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄ-ÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao de processamento da gravacao dos arquivos             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄ-ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³                                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ-ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ProcATU(cTab)
	Local oDlg,oFonte
	Local cTexto		:= ""
	Local cFile			:= ""
	Local cMask			:= "Arquivos Texto (*.TXT) |*.txt|"
	Local nRecno		:= 0
	Local nI			:= 0
	Local nX			:= 0
	Local aRecnoSM0		:= {}
	Local lOpen			:= .F.
	Local oMemo			:= ""

	ProcRegua(1)
	IncProc("Verificando integridade dos dicionários....")

	If (lOpen := IIF(Alias() <> "SM0", MyOpenSm0Ex(), .T. ))

		DbSelectArea("SM0")
		DbGotop()
		While !Eof()
			If Ascan(aRecnoSM0,{ |x| x[2] == M0_CODIGO}) == 0
				Aadd(aRecnoSM0,{Recno(),M0_CODIGO})
			EndIf
			DbSkip()
		EndDo

		If lOpen
			For nI := 1 To Len(aRecnoSM0)

				SM0->(DbGoto(aRecnoSM0[nI,1]))

				RpcSetType(3)
				RpcSetEnv(SM0->M0_CODIGO, SM0->M0_CODFIL)

				nModulo			:= 51
				lMsFinalAuto	:= .F.

				cTexto += Replicate("-",128)+CHR(13)+CHR(10)
				cTexto += "Empresa : "+SM0->M0_CODIGO+SM0->M0_NOME+CHR(13)+CHR(10)

				ProcRegua(8)

				Begin Transaction
					// Atualiza o dicionario SX2 Tabelas...
					IncProc("Analisando Dicionario SX2 Tabelas...")
					U_DoSX2( @cTexto )
					U_FSAtuSX2()

					// Atualiza o dicionario SX3 Campos...
					IncProc("Analisando Dicionario SX3 Campos...")
					U_DoSX3( @cTexto )
					U_FSAtuSX3(cTab)

					// Atualiza o dicionario SIX Indices...
					IncProc("Analisando Dicionario SIX Indices...")
					U_DoSIX( @cTexto )
					U_FSAtuSIX()

					// Atualiza o dicionario SX6 Parametros...
					IncProc("Analisando Dicionario SX6 Triggers...")
					U_DoSX6( @cTexto )

					// Atualiza o dicionario SX7 Triggers...
					IncProc("Analisando Dicionario SX7 Triggers...")
					U_DoSX7( @cTexto )

					// Atualiza o dicionario SXB Consultas...
					IncProc("Analisando Dicionario SXB Consultas...")
					U_DoSXB( @cTexto )

					// Função de processamento da gravação dos Helps de Campos...
					IncProc("Analisando gravação dos Helps de Campos....")
					U_FSAtuHlp()
				End Transaction

				__SetX31Mode(.F.)
				For nX := 1 To Len(aArqUpd)

					IncProc("Atualizando estruturas. Aguarde... ["+aArqUpd[nx]+"]")

					If Select(aArqUpd[nx])>0
						DbSelecTArea(aArqUpd[nx])
						DbCloseArea()
					EndIf

					X31UpdTable(aArqUpd[nx])

					If __GetX31Error()
						Alert(__GetX31Trace())
						Aviso("Atencao!","Ocorreu um erro desconhecido durante a atualizacao da tabela : "+ aArqUpd[nx] + ". Verifique a integridade do dicionario e da tabela.",{"Continuar"},2)
						cTexto += "Ocorreu um erro desconhecido durante a atualizacao da estrutura da tabela : "+aArqUpd[nx] +CHR(13)+CHR(10)
					EndIf

					DbSelectArea(aArqUpd[nx])

				Next nX

				RpcClearEnv()
				If !( lOpen := MyOpenSm0Ex() )
					Exit
				EndIf
			Next nI

			u_makeConfFile()						//criando arquivo de configurao JOB

			If lOpen

				cTexto		:= "Log da atualizacao " + CHR(13) + CHR(10) + cTexto
				__cFileLog	:= MemoWrite(Criatrab(,.f.) + ".LOG", cTexto)

				DEFINE FONT oFonte NAME "Courier New" SIZE 0,14 BOLD

				DEFINE MSDIALOG oDlg TITLE "Atualizador [OPV001UPD] - Atualizacao concluida." From 3,0 to 340,417 PIXEL

					@ 5,5 GET oMemo  VAR cTexto MEMO SIZE 200,145 OF oDlg PIXEL
					oMemo:bRClicked := {||AllwaysTrue()}
					oMemo:oFont:=oFonte

					DEFINE SBUTTON  FROM 153,175 TYPE 1 ACTION oDlg:End() ENABLE OF oDlg PIXEL //Apaga
					DEFINE SBUTTON  FROM 153,145 TYPE 13 ACTION (cFile:=cGetFile(cMask,""),If(cFile="",.t.,MemoWrite(cFile,cTexto))) ENABLE OF oDlg PIXEL //Salva e Apaga //"Salvar Como..."

				ACTIVATE MSDIALOG oDlg CENTER

			EndIf
		EndIf
	EndIf
Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄ-ÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MyOpenSM0E³ Autor ³OPVS C.A.              ³ Data ³ 18/06/2013 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄ-ÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Efetua a abertura do SM0 exclusivo                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄ-ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³                                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ-ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MyOpenSM0Ex()
	Local lOpen := .F.
	Local nLoop := 0

	For nLoop := 1 To 20

		DbUseArea( .T.,, "SIGAMAT.EMP", "SM0", .F., .F. )

		If !Empty( Select( "SM0" ) )
			lOpen := .T.
			DbSetIndex("SIGAMAT.IND")
			Exit
		EndIf

		Sleep( 500 )

	Next nLoop

	If !lOpen
		Aviso( "Atencao !", "Nao foi possivel a abertura da tabela de empresas de forma exclusiva !", { "Ok" }, 2 )
	EndIf
Return( lOpen )