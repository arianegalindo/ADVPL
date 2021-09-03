#INCLUDE "PROTHEUS.CH"

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun�ao    � DoSX3SUS � Autor � Miguel Fran�a.        � Data � 27/08/2013 ���
���������������������������������������������������������������������������Ĵ��
���Descri�ao � Funcao generica para copia de dicionarios                    ���
���������������������������������������������������������������������������Ĵ��
���Uso       �                                                              ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
User Function DoSX3SU5( cTexto )

Local aArea	:= GetArea()
Local i		:= 0
Local j		:= 0
Local aRegs	:= {}
Local lInclui	:= .F.

aRegs  := {}

Aadd( aRegs, { "SU5", "B5", "U5_YSSCLIE", "C",               21,              0, "Cli. Softsite", "Cli. Softsite", "Cli. Softsite", "Cli. Softsite", "Cli. Softsite", "Cli. Softsite", "                                             ", "                              ", "���������������", "                              ", "      ",              0, "��", " ", " ", "U", "N", "A", "R", "000", "                              ", "                              ", "                              ", "                              ", "                    ", "                                                            ", "                                                                                ", "   ", " ", " ", "                                                      ", "                                                      ", " ", "N", "N", "               "} )
Aadd( aRegs, { "SU5", "B5", "U5_YSSREFE", "C",               21,              0, "Ref. Softsite", "Ref. Softsite", "Ref. Softsite", "Ref. Softsite", "Ref. Softsite", "Ref. Softsite", "                                             ", "                              ", "���������������", "                              ", "      ",              0, "��", " ", " ", "U", "N", "A", "R", "000", "                              ", "                              ", "                              ", "                              ", "                    ", "                                                            ", "                                                                                ", "   ", " ", " ", "                                                      ", "                                                      ", " ", "N", "N", "               "} )
Aadd( aRegs, { "SU5", "B6", "U5_YDTIMPR", "D",               8,              0, "Dt. Import. ref", "Dt. Importac. ref", "Dt. Importac. ref", "Data Importacao ref      ", "Data Importacao ref      ", "Data Importacao ref      ", "                                             ", "                              ", "���������������", "                              ", "      ",              0, "��", " ", " ", "U", "N", "A", "R", "000", "                              ", "                              ", "                              ", "                              ", "                    ", "                                                            ", "                                                                                ", "   ", " ", " ", "                                                      ", "                                                      ", " ", "N", "N", "               "} )

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

