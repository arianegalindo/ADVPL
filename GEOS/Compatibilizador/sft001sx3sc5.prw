#INCLUDE "PROTHEUS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ DoSX3SC5 ³ Autor ³ OPVS C.A.             ³ Data ³ 18/05/2013 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Funcao generica para copia de dicionarios                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³                                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function DoSX3SC5( cTexto )

Local aArea	:= GetArea()
Local i		:= 0
Local j		:= 0
Local aRegs	:= {}
Local lInclui	:= .F.

aRegs  := {}

Aadd( aRegs, { "SC5", "B5", "C5_YCDPALM", "C",               21,              0, "Ped. Palm.  ", "Ped. Palm.  ", "Ped. Palm.  ", "Ped. Palm.               ", "Ped. Palm.               ", "Ped. Palm.               ", "                                             ", "                               ", "€€€€€€€€€€€€€€ ", "                               ", "      ",              0, "þÀ", " ", " ", "U", "N", "A", "R", "000", "                               ", "                               ", "                               ", "                               ", "                    ", "                                                            ", "                                                                                ", "   ", " ", " ", "                                                        ", "                                                        ", " ", "N", "N", "               "} )
Aadd( aRegs, { "SC5", "B6", "C5_YDTIMPR", "D",               8,              0, "Dt. Importac", "Dt. Importac", "Dt. Importac", "Data Importacao          ", "Data Importacao          ", "Data Importacao          ", "                                             ", "                               ", "€€€€€€€€€€€€€€ ", "                               ", "      ",              0, "þÀ", " ", " ", "U", "N", "A", "R", "000", "                               ", "                               ", "                               ", "                               ", "                    ", "                                                            ", "                                                                                ", "   ", " ", " ", "                                                        ", "                                                        ", " ", "N", "N", "               "} )
Aadd( aRegs, { "SC5", "B7", "C5_YPEDPAI", "C",               21,              0, "Ped.Palm. Pai", "Ped.Palm. Pai", "Ped.Palm. Pai", "Ped.Palm. Pai           ", "Ped.Palm. Pai           ", "Ped.Palm. Pai            ", "                                             ", "                               ", "€€€€€€€€€€€€€€ ", "                               ", "      ",              0, "þÀ", " ", " ", "U", "N", "A", "R", "000", "                               ", "                               ", "                               ", "                               ", "                    ", "                                                            ", "                                                                                ", "   ", " ", " ", "                                                        ", "                                                        ", " ", "N", "N", "               "} )
Aadd( aRegs, { "SC5", "B0", "C5_ZZOBS  ", "M",               10,              0, "Observacao  ", "Observacao  ", "Observacao  ", "Observacao               ", "Observacao               ", "Observacao               ", "                                             ", "                               ", "€€€€€€€€€€€€€€ ", "                               ", "      ",              0, "þÀ", " ", " ", "U", "N", "A", "R", "000", "                               ", "                               ", "                               ", "                               ", "                    ", "                                                            ", "                                                                                ", "   ", " ", " ", "                                                        ", "                                                        ", " ", "N", "N", "               "} )

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

