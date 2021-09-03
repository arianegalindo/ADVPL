#INCLUDE "PROTHEUS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ DoSX3I01 ³ Autor ³ OPVS C.A.             ³ Data ³ 18/06/2013 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Funcao generica para copia de dicionarios                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function DoSX3I01( cTexto )

Local aArea		:= GetArea()
Local i			:= 0
Local j			:= 0
Local aRegs		:= {}
Local lInclui	:= .F.

aRegs  := {}

Aadd( aRegs, {'I01', '04', 'I01_CAMPO ', 'C',               10,              0, 'Campo       ', 'Campo       ', 'Campo       ', 'Campo                    ', 'Campo                    ', 'Campo                    ', '@!                                           ', 'ExistCpo("SX3",M->I01_CAMPO,2)      ', '€€€€€€€€€€€€€€ ', '                           ', 'SFTSX3',              0, 'þÀ', ' ', ' ', 'U', 'S', 'A', 'R', '000', '                           ', '                           ', '                           ', '                           ', '                    ', '              ', '                                  ', '   ', ' ', ' ', '  ', '  ', ' ', 'N', 'N', '               '} )
Aadd( aRegs, {'I01', '02', 'I01_CODLAY', 'C',               6,              0, 'Cod Layout  ', 'Cod Layout  ', 'Cod Layout  ', 'Codigo do Layout         ', 'Codigo do Layout         ', 'Codigo do Layout         ', '@!                                           ', '                           ', '€€€€€€€€€€€€€€€', '                           ', '      ',              0, 'þÀ', ' ', ' ', 'U', 'N', 'A', 'R', '000', '                           ', '                           ', '                           ', '                           ', '                    ', '              ', '                                  ', '   ', ' ', ' ', '  ', '  ', ' ', 'N', 'N', '               '} )
Aadd( aRegs, {'I01', '08', 'I01_DECIMA', 'N',               1,              0, 'Decimais    ', 'Decimais    ', 'Decimais    ', 'Decimais                 ', 'Decimais                 ', 'Decimais                 ', '9                                            ', '                           ', '€€€€€€€€€€€€€€ ', '                           ', '      ',              0, 'þÀ', ' ', ' ', 'U', 'N', 'A', 'R', '000', '                           ', '                           ', '                           ', '                           ', '                    ', '              ', '                                  ', '   ', ' ', ' ', '  ', '  ', ' ', 'N', 'N', '               '} )
Aadd( aRegs, {'I01', '01', 'I01_FILIAL', 'C',               6,              0, 'Filial      ', 'Sucursal    ', 'Branch      ', 'Filial do Sistema        ', 'Sucursal                 ', 'Branch of the System     ', '@!                                           ', '                           ', '€€€€€€€€€€€€€€€', '                           ', '      ',               1, 'þÀ', ' ', ' ', 'U', 'N', ' ', ' ', '   ', '                           ', '                           ', '                           ', '                           ', '                    ', '              ', '                                  ', '033', ' ', ' ', '  ', '  ', ' ', ' ', ' ', '               '} )
Aadd( aRegs, {'I01', '09', 'I01_FINCPO', 'C',               100,              0, 'Final Campo ', 'Final Campo ', 'Final Campo ', 'Final Campo              ', 'Final Campo              ', 'Final Campo              ', '                                             ', '                           ', '€€€€€€€€€€€€€€ ', '                           ', '      ',              0, 'þÀ', ' ', ' ', 'U', 'S', 'A', 'R', '000', '                           ', '                           ', '                           ', '                           ', '                    ', '              ', '                                  ', '   ', ' ', ' ', '  ', '  ', ' ', 'N', 'N', '               '} )
Aadd( aRegs, {'I01', '05', 'I01_FUNCAO', 'M',               10,              0, 'Funcao      ', 'Funcao      ', 'Funcao      ', 'Funcao                   ', 'Funcao                   ', 'Funcao                   ', '                                             ', '                           ', '€€€€€€€€€€€€€€ ', '                           ', '      ',              0, 'þÀ', ' ', ' ', 'U', 'S', 'A', 'R', '000', '                           ', '                           ', '                           ', '                           ', '                    ', '              ', '                                  ', '   ', ' ', ' ', '  ', '  ', ' ', 'N', 'N', '               '} )
Aadd( aRegs, {'I01', '03', 'I01_ORDEM ', 'C',               4,              0, 'Ordem       ', 'Ordem       ', 'Ordem       ', 'Ordem                    ', 'Ordem                    ', 'Ordem                    ', '9999                                         ', '                           ', '€€€€€€€€€€€€€€ ', 'StrZero(Val(oMsGetD:aCols[oMsGetD:nAt][1])+1,4)                                   ', '      ',              0, 'þÀ', ' ', ' ', 'U', 'S', 'V', 'R', '000', '                           ', '                           ', '                           ', '                           ', '                    ', '              ', '                                  ', '   ', ' ', ' ', '  ', '  ', ' ', 'N', 'N', '               '} )
Aadd( aRegs, {'I01', '07', 'I01_TAMANH', 'N',               3,              0, 'Tamanho     ', 'Tamanho     ', 'Tamanho     ', 'Tamanho                  ', 'Tamanho                  ', 'Tamanho                  ', '999                                          ', '                           ', '€€€€€€€€€€€€€€ ', '                           ', '      ',              0, 'þÀ', ' ', ' ', 'U', 'N', 'A', 'R', '000', '                           ', '                           ', '                           ', '                           ', '                    ', '              ', '                                  ', '   ', ' ', ' ', '  ', '  ', ' ', 'N', 'N', '               '} )
Aadd( aRegs, {'I01', '06', 'I01_TIPDAT', 'C',               1,              0, 'Tipo do Dado', 'Tipo do Dado', 'Tipo do Dado', 'Tipo do Dado             ', 'Tipo do Dado             ', 'Tipo do Dado             ', '9                                            ', '                           ', '€€€€€€€€€€€€€€ ', '                           ', '      ',              0, 'þÀ', ' ', ' ', 'U', 'N', 'A', 'R', '000', '                           ', '1=Caracter;2=Numerico;3=Data        ', '1=Caracter;2=Numerico;3=Data        ', '1=Caracter;2=Numerico;3=Data        ', '                    ', '              ', '                                  ', '   ', ' ', ' ', '  ', '  ', ' ', 'N', 'N', '               '} )

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

