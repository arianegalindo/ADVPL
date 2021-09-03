#INCLUDE "PROTHEUS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ DoSX3I04 ³ Autor ³ OPVS C.A.             ³ Data ³ 18/06/2013 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Funcao generica para copia de dicionarios                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³                                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function DoSX3I04( cTexto )

Local aArea		:= GetArea()
Local i			:= 0
Local j			:= 0
Local aRegs		:= {}
Local lInclui	:= .F.

aRegs  := {}

Aadd( aRegs, {'I04', '02', 'I04_CODLAY', 'C',               6,              0, 'Cod. Layout ', 'Cod. Layout ', 'Cod. Layout ', 'Cod. Layout              ', 'Cod. Layout              ', 'Cod. Layout              ', '                                             ', '                ', '€€€€€€€€€€€€€€€', '                ', '      ',              0, 'þÀ', ' ', ' ', 'U', 'N', 'V', 'R', '000', '                ', '                ', '                ', '                ', '                    ', '                                                            ', '      ', '   ', ' ', ' ', '                          ', '                          ', ' ', 'N', 'N', '               '} )
Aadd( aRegs, {'I04', '08', 'I04_CPOATE', 'C',               3,              0, 'Ate         ', 'Ate         ', 'Ate         ', 'Ate                      ', 'Ate                      ', 'Ate                      ', '999                                          ', '                ', '€€€€€€€€€€€€€€ ', '                ', '      ',              0, 'þÀ', ' ', ' ', 'U', 'N', 'A', 'R', '000', '                ', '                ', '                ', '                ', '                    ', '                                                            ', '      ', '   ', ' ', ' ', '                          ', '                          ', ' ', 'N', 'N', '               '} )
Aadd( aRegs, {'I04', '07', 'I04_CPODE ', 'C',               3,              0, 'De          ', 'De          ', 'De          ', 'De                       ', 'De                       ', 'De                       ', '999                                          ', '                ', '€€€€€€€€€€€€€€ ', '                ', '      ',              0, 'þÀ', ' ', ' ', 'U', 'N', 'A', 'R', '000', '                ', '                ', '                ', '                ', '                    ', '                                                            ', '      ', '   ', ' ', ' ', '                          ', '                          ', ' ', 'N', 'N', '               '} )
Aadd( aRegs, {'I04', '12', 'I04_CPODES', 'C',               10,              0, 'Cpo Destino ', 'Cpo Destino ', 'Cpo Destino ', 'Cpo Destino              ', 'Cpo Destino              ', 'Cpo Destino              ', '@!                                           ', '                ', '€€€€€€€€€€€€€€ ', '                ', '      ',              0, 'þÀ', ' ', ' ', 'U', 'N', 'A', 'R', '000', '                ', '                ', '                ', '                ', '                    ', '                                                            ', '      ', '   ', ' ', ' ', '                          ', '                          ', ' ', 'N', 'N', '               '} )
Aadd( aRegs, {'I04', '05', 'I04_CPOORI', 'C',               20,              0, 'Cpo Origem  ', 'Cpo Origem  ', 'Cpo Origem  ', 'Cpo Origem               ', 'Cpo Origem               ', 'Cpo Origem               ', '@!                                           ', '                ', '€€€€€€€€€€€€€€ ', '                ', '      ',              0, 'þÀ', ' ', ' ', 'U', 'N', 'A', 'R', '000', '                ', '                ', '                ', '                ', '                    ', '                                                            ', '      ', '   ', ' ', ' ', '                          ', '                          ', ' ', 'N', 'N', '               '} )
Aadd( aRegs, {'I04', '10', 'I04_DECIMA', 'N',               1,              0, 'Decimal     ', 'Decimal     ', 'Decimal     ', 'Decimal                  ', 'Decimal                  ', 'Decimal                  ', '9                                            ', '                ', '€€€€€€€€€€€€€€ ', '                ', '      ',              0, 'þÀ', ' ', ' ', 'U', 'N', 'A', 'R', '000', '                ', '                ', '                ', '                ', '                    ', '                                                            ', '      ', '   ', ' ', ' ', '                          ', '                          ', ' ', 'N', 'N', '               '} )
Aadd( aRegs, {'I04', '01', 'I04_FILIAL', 'C',               6,              0, 'Filial      ', 'Sucursal    ', 'Branch      ', 'Filial do Sistema        ', 'Sucursal                 ', 'Branch of the System     ', '@!                                           ', '                ', '€€€€€€€€€€€€€€€', '                ', '      ',               1, 'þÀ', ' ', ' ', 'U', 'N', ' ', ' ', '   ', '                ', '                ', '                ', '                ', '                    ', '                                                            ', '      ', '033', ' ', ' ', '                          ', '                          ', ' ', ' ', ' ', '               '} )
Aadd( aRegs, {'I04', '06', 'I04_FUNC  ', 'M',               10,              0, 'Funcao      ', 'Funcao      ', 'Funcao      ', 'Funcao                   ', 'Funcao                   ', 'Funcao                   ', '                                             ', '                ', '€€€€€€€€€€€€€€ ', '                ', '      ',              0, 'þÀ', ' ', ' ', 'U', 'N', 'A', 'R', '000', '                ', '                ', '                ', '                ', '                    ', '                                                            ', '      ', '   ', ' ', ' ', '                          ', '                          ', ' ', 'N', 'N', '               '} )
Aadd( aRegs, {'I04', '03', 'I04_SEQARQ', 'C',               3,              0, 'Seq. Arquivo', 'Seq. Arquivo', 'Seq. Arquivo', 'Seq. Arquivo             ', 'Seq. Arquivo             ', 'Seq. Arquivo             ', '                                             ', '                ', '€€€€€€€€€€€€€€ ', 'M->I03_SEQARQ   ', '      ',              0, 'þÀ', ' ', ' ', 'U', 'N', 'V', 'R', '000', '                ', '                ', '                ', '                ', '                    ', '                                                            ', '      ', '   ', ' ', ' ', '                          ', '                          ', ' ', 'N', 'N', '               '} )
Aadd( aRegs, {'I04', '04', 'I04_SEQCPO', 'C',               3,              0, 'Seq. Campo  ', 'Seq. Campo  ', 'Seq. Campo  ', 'Seq. Campo               ', 'Seq. Campo               ', 'Seq. Campo               ', '                                             ', '                ', '€€€€€€€€€€€€€€ ', 'StrZero(Val(oMsGetD:aCols[oMsGetD:nAt][2])+1,3)       ', '      ',              0, 'þÀ', ' ', ' ', 'U', 'N', 'V', 'R', '000', '                ', '                ', '                ', '                ', '                    ', '                                                            ', '      ', '   ', ' ', ' ', '                          ', '                          ', ' ', 'N', 'N', '               '} )
Aadd( aRegs, {'I04', '09', 'I04_TAMANH', 'N',               3,              0, 'Tamanho     ', 'Tamanho     ', 'Tamanho     ', 'Tamanho                  ', 'Tamanho                  ', 'Tamanho                  ', '999                                          ', '                ', '€€€€€€€€€€€€€€ ', '                ', '      ',              0, 'þÀ', ' ', ' ', 'U', 'N', 'A', 'R', '000', '                ', '                ', '                ', '                ', '                    ', '                                                            ', '      ', '   ', ' ', ' ', '                          ', '                          ', ' ', 'N', 'N', '               '} )
Aadd( aRegs, {'I04', '11', 'I04_TIPDAT', 'C',               1,              0, 'Tipo do Dado', 'Tipo do Dado', 'Tipo do Dado', 'Tipo do Dado             ', 'Tipo do Dado             ', 'Tipo do Dado             ', '                                             ', '                ', '€€€€€€€€€€€€€€ ', '                ', '      ',              0, 'þÀ', ' ', ' ', 'U', 'N', 'A', 'R', '000', '                ', '1=Caracter;2=Numerico;3=Data                          ', '                ', '                ', '                    ', '                                                            ', '      ', '   ', ' ', ' ', '                          ', '                          ', ' ', 'N', 'N', '               '} )

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

