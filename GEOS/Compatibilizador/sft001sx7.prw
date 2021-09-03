#INCLUDE "PROTHEUS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ DoSX7    ³ Autor ³ OPVS C.A.             ³ Data ³ 18/06/2013 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Funcao generica para copia de dicionarios                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³                                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function DoSX7( cTexto )

Local aArea		:= GetArea()
Local i			:= 0
Local j			:= 0
Local aRegs		:= {}
Local lInclui	:= .F.

aRegs  := {}

Aadd( aRegs, {'I00_INDICE', '001', 'SIX->CHAVE                                                                                          ', 'I00_DESIND', 'P', 'S', 'SIX',               1, 'M->(I00_TABELA+I00_INDICE)                                                                          ', '                                        ', 'U'} )
Aadd( aRegs, {'I00_TABELA', '001', 'SX2->X2_NOME                                                                                        ', 'I00_DESTAB', 'P', 'S', 'SX2',               1, 'M->I00_TABELA                                                                                       ', '                                        ', 'U'} )

DbSelectArea("SX7")
DbSetOrder(1)

For i := 1 To Len(aRegs)
	
	lInclui := !DbSeek( aRegs[i,1]+aRegs[i,2] )
	
	cTexto += IIf( aRegs[i,1]+aRegs[i,2] $ cTexto, "", aRegs[i,1]+aRegs[i,2] + "\")
	
	RecLock("SX7", lInclui)
		For j := 1 to Len(aRegs[i])
			FieldPut(j,aRegs[i,j])
		Next
	MsUnlock()
Next i

RestArea(aArea)

cTexto := "SX7.: " + cTexto  + CHR(13) + CHR(10)

Return(.T.)

