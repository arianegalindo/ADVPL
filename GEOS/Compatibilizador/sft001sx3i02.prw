#INCLUDE "PROTHEUS.CH"

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun�ao    � DoSX3I02 � Autor � OPVS C.A.             � Data � 18/06/2013 ���
���������������������������������������������������������������������������Ĵ��
���Descri�ao � Funcao generica para copia de dicionarios                    ���
���������������������������������������������������������������������������Ĵ��
���Uso       �                                                              ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
User Function DoSX3I02( cTexto )

Local aArea		:= GetArea()
Local i			:= 0
Local j			:= 0
Local aRegs		:= {}
Local lInclui	:= .F.

aRegs  := {}

Aadd( aRegs, {'I02', '07', 'I02_ARQPRI', 'C',               20,              0, 'Arq. Princ. ', 'Arq. Princ. ', 'Arq. Princ. ', 'Arq. Princ.              ', 'Arq. Princ.              ', 'Arq. Princ.              ', '                                             ', '                                     ', '���������������', '                                     ', '      ',              0, '��', ' ', ' ', 'U', 'S', 'A', 'R', '000', '                                     ', '                                     ', '                                     ', '                                     ', '                    ', '                                                            ', '                                                                                ', '   ', ' ', ' ', '                                                                    ', '                                                                    ', ' ', 'N', 'N', '               '} )
Aadd( aRegs, {'I02', '08', 'I02_CHAVE ', 'C',               20,              0, 'Chave Relac.', 'Chave Relac.', 'Chave Relac.', 'Chave Relac.             ', 'Chave Relac.             ', 'Chave Relac.             ', '@!                                           ', '                                     ', '���������������', '                                     ', '      ',              0, '��', ' ', ' ', 'U', 'S', 'A', 'R', '000', '                                     ', '                                     ', '                                     ', '                                     ', '                    ', '                                                            ', '                                                                                ', '   ', ' ', ' ', '                                                                    ', '                                                                    ', ' ', 'N', 'N', '               '} )
Aadd( aRegs, {'I02', '02', 'I02_CODLAY', 'C',               6,              0, 'Cod. Layout ', 'Cod. Layout ', 'Cod. Layout ', 'Cod. Layout              ', 'Cod. Layout              ', 'Cod. Layout              ', '@!                                           ', '                                     ', '���������������', '                                     ', '      ',              0, '��', ' ', ' ', 'U', 'S', 'A', 'R', '000', '                                     ', '                                     ', '                                     ', '                                     ', '                    ', '                                                            ', '                                                                                ', '   ', ' ', ' ', '                                                                    ', '                                                                    ', ' ', 'N', 'N', '               '} )
Aadd( aRegs, {'I02', '03', 'I02_DESLAY', 'C',               30,              0, 'Desc. Layout', 'Desc. Layout', 'Desc. Layout', 'Desc. Layout             ', 'Desc. Layout             ', 'Desc. Layout             ', '@!                                           ', '                                     ', '���������������', '                                     ', '      ',              0, '��', ' ', ' ', 'U', 'S', 'A', 'R', '000', '                                     ', '                                     ', '                                     ', '                                     ', '                    ', '                                                            ', '                                                                                ', '   ', ' ', ' ', '                                                                    ', '                                                                    ', ' ', 'N', 'N', '               '} )
Aadd( aRegs, {'I02', '06', 'I02_EXECAU', 'C',               10,              0, 'Rot. Aut.   ', 'Rot. Aut.   ', 'Rot. Aut.   ', 'Rot. Aut.                ', 'Rot. Aut.                ', 'Rot. Aut.                ', '@!                                           ', '                                     ', '���������������', '                                     ', '      ',              0, '��', ' ', ' ', 'U', 'S', 'A', 'R', '000', '                                     ', '                                     ', '                                     ', '                                     ', '                    ', '                                                            ', '                                                                                ', '   ', ' ', ' ', '                                                                    ', '                                                                    ', ' ', 'N', 'N', '               '} )
Aadd( aRegs, {'I02', '01', 'I02_FILIAL', 'C',               6,              0, 'Filial      ', 'Sucursal    ', 'Branch      ', 'Filial do Sistema        ', 'Sucursal                 ', 'Branch of the System     ', '@!                                           ', '                                     ', '���������������', '                                     ', '      ',               1, '��', ' ', ' ', 'U', 'N', ' ', ' ', '   ', '                                     ', '                                     ', '                                     ', '                                     ', '                    ', '                                                            ', '                                                                                ', '033', ' ', ' ', '                                                                    ', '                                                                    ', ' ', ' ', ' ', '               '} )
Aadd( aRegs, {'I02', '04', 'I02_STATUS', 'C',               1,              0, 'Status      ', 'Status      ', 'Status      ', 'Status                   ', 'Status                   ', 'Status                   ', '                                             ', '                                     ', '���������������', '                                     ', '      ',              0, '��', ' ', ' ', 'U', 'S', 'A', 'R', '000', '                                     ', '1=Ativo;2=Suspenso;3=Cancelado;4=Clie.Prospect;5=Ped.Pospect       ', '                                     ', '                                     ', '                    ', '                                                            ', '                                                                                ', '   ', ' ', ' ', '                                                                    ', '                                                                    ', ' ', 'N', 'N', '               '} )
Aadd( aRegs, {'I02', '05', 'I02_TIPIMP', 'C',               1,              0, 'Tp. Import. ', 'Tp. Import. ', 'Tp. Import. ', 'Tp. Import.              ', 'Tp. Import.              ', 'Tp. Import.              ', '                                             ', '                                     ', '���������������', '                                     ', '      ',              0, '��', ' ', ' ', 'U', 'S', 'A', 'R', '000', '                                     ', '1=Rotina Automatica;2=Insert Dados   ', '                                     ', '                                     ', '                    ', '                                                            ', '                                                                                ', '   ', ' ', ' ', '                                                                    ', '                                                                    ', ' ', 'N', 'N', '               '} )

DbSelectArea("SX3")
DbSetOrder(2)

For i := 1 To Len(aRegs)
	
	lInclui := !DbSeek( aRegs[i,3] )
	
	cTexto += IIf( aRegs[i,3] $ cTexto, "", aRegs[i,3] + "\")
	
	RecLock("SX3", lInclui)
		For j := 1 to Len(aRegs[i])
			nSX3 := SX3->(FieldPos(aSX3[j]))
			
			If nSX3 > 0
				FieldPut(nSX3,aRegs[i,j])
			Endif
		Next
	MsUnlock()
	
Next i

RestArea(aArea)

cTexto := "SX3.: " + cTexto  + CHR(13) + CHR(10)

Return(.T.)

