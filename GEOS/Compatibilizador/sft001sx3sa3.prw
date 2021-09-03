#INCLUDE "PROTHEUS.CH"

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun�ao    � DoSX3SA3 � Autor � OPVS C.A.             � Data � 18/05/2013 ���
���������������������������������������������������������������������������Ĵ��
���Descri�ao � Funcao generica para copia de dicionarios                    ���
���������������������������������������������������������������������������Ĵ��
���Uso       �                                                              ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
User Function DoSX3SA3( cTexto )

Local aArea	:= GetArea()
Local i		:= 0
Local j		:= 0
Local aRegs	:= {}
Local lInclui	:= .F.

aRegs  := {}

Aadd( aRegs, { "SA3", "78", "A3_ZZTPPRO", "C",               1,              0, "Tip. Produto", "Tip. Produto", "Tip. Produto", "Tip. Produto Vendido SSM ", "Tip. Produto Vendido SSM ", "Tip. Produto Vendido SSM ", "9                                           ", "                       ", "���������������", "                       ", "      ",              0, "��", " ", " ", "U", "N", "A", "R", "000", "                       ", "1=Signus;2=JPierre;3=Todos Prod.                                   ", "1=Signus;2=JPierre;3=Todos Prod.                     ", "1=Signus;2=JPierre;3=Todos Prod.                     ", "                    ", "                                                            ", "     ", "   ", " ", " ", "                                        ", "                                        ", " ", "N", "N", "               "} )

DbSelectArea("SX3")
DbSetOrder(2)

For i := 1 To Len(aRegs)
	
	lInclui := !DbSeek( aRegs[i,3] )
	
	cTexto += IIf( aRegs[i,3] $ cTexto, "", aRegs[i,3] + "\")
	
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

