#INCLUDE "PROTHEUS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ DoSX3SUS ³ Autor ³ Miguel França.        ³ Data ³ 27/08/2013 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Funcao generica para copia de dicionarios                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³                                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function DoSX3SUS( cTexto )

Local aArea	:= GetArea()
Local i		:= 0
Local j		:= 0
Local aRegs	:= {}
Local lInclui	:= .F.

aRegs  := {}

Aadd( aRegs, { "SUS", "B5", "US_YSSCLIE", "C",               21,              0, "Cli. Softsite", "Cli. Softsite", "Cli. Softsite", "Cli. Softsite", "Cli. Softsite", "Cli. Softsite", "                                             ", "                                          ", "€€€€€€€€€€€€€€ ", "                                          ", "      ",              0, "þÀ", " ", " ", "U", "N", "A", "R", "000", "                                          ", "                                          ", "                                          ", "                                          ", "                    ", "                                                            ", "          ", "   ", " ", " ", "        ", "        ", " ", "N", "N", "               "} )
Aadd( aRegs, { "SUS", "B6", "US_YDTIMPR", "D",               8,              0, "Dt. Import. cli", "Dt. Importac. cli", "Dt. Importac. cli", "Data Importacao Cli      ", "Data Importacao Cli      ", "Data Importacao Cli      ", "                                             ", "                                          ", "€€€€€€€€€€€€€€ ", "                                          ", "      ",              0, "þÀ", " ", " ", "U", "N", "A", "R", "000", "                                          ", "                                          ", "                                          ", "                                          ", "                    ", "                                                            ", "          ", "   ", " ", " ", "        ", "        ", " ", "N", "N", "               "} )

DbSelectArea("SX3")
DbSetOrder(2)

For i := 1 To Len(aRegs)
	
	lInclui := !DbSeek( aRegs[i,3] )
	
	cTexto += IIf( aRegs[i,3] $ cTexto, '', aRegs[i,3] + "\")
	
	RecLock("SX3", lInclui)
		For j := 1 to FCount()
			If j <= Len(aRegs[i])
				FieldPut(j,aRegs[i,j])
			Endif
		Next
	MsUnlock()
Next i

RestArea(aArea)

cTexto := "SX3.: " + cTexto  + CHR(13) + CHR(10)

Return(cTexto)

