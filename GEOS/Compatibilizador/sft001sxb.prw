#INCLUDE "PROTHEUS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ DoSXB    ³ Autor ³ OPVS C.A.             ³ Data ³ 18/06/2013 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Funcao generica para copia de dicionarios                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³                                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function DoSXB( cTexto )

Local aArea		:= GetArea()
Local i			:= 0
Local j			:= 0
Local aRegs		:= {}
Local lInclui	:= .F.

aRegs  := {}

Aadd( aRegs, {'SFTSX2', '1', '01', 'DB', 'Tabelas do Sistema  ', 'Tablas del Sistema  ', 'System Table        ', 'SX2                                                                                                                                                                                                                                                       ', '                                                                                                                                                                                                                                                          '} )
Aadd( aRegs, {'SFTSX2', '2', '01', '01', 'Código              ', 'Codigo              ', 'Code                ', '                                                                                                                                                                                                                                                          ', '                                                                                                                                                                                                                                                          '} )
Aadd( aRegs, {'SFTSX2', '4', '01', '01', 'Chave               ', 'Clave               ', 'Key                 ', 'X2_CHAVE                                                                                                                                                                                                                                                  ', '                                                                                                                                                                                                                                                          '} )
Aadd( aRegs, {'SFTSX2', '4', '01', '02', 'Descrição Portugues ', 'Descrip.en Port.    ', 'Portug.Description  ', 'X2_NOME                                                                                                                                                                                                                                                   ', '                                                                                                                                                                                                                                                          '} )
Aadd( aRegs, {'SFTSX2', '5', '01', '  ', '                    ', '                    ', '                    ', 'SX2->X2_CHAVE                                                                                                                                                                                                                                             ', '                                                                                                                                                                                                                                                          '} )
Aadd( aRegs, {'SFTSX3', '1', '01', 'DB', 'Campos do Sistema   ', 'Campos do Sistema   ', 'Campos do Sistema   ', 'SX3                                                                                                                                                                                                                                                       ', '                                                                                                                                                                                                                                                          '} )
Aadd( aRegs, {'SFTSX3', '2', '01', '01', 'Campos              ', 'Campos              ', 'Campos              ', '                                                                                                                                                                                                                                                          ', '                                                                                                                                                                                                                                                          '} )
Aadd( aRegs, {'SFTSX3', '4', '01', '01', 'Arquivo             ', 'Arquivo             ', 'Arquivo             ', 'X3_ARQUIVO                                                                                                                                                                                                                                                ', '                                                                                                                                                                                                                                                          '} )
Aadd( aRegs, {'SFTSX3', '4', '01', '02', 'Ordem               ', 'Ordem               ', 'Ordem               ', 'X3_ORDEM                                                                                                                                                                                                                                                  ', '                                                                                                                                                                                                                                                          '} )
Aadd( aRegs, {'SFTSX3', '4', '01', '03', 'Campo               ', 'Campo               ', 'Campo               ', 'X3_CAMPO                                                                                                                                                                                                                                                  ', '                                                                                                                                                                                                                                                          '} )
Aadd( aRegs, {'SFTSX3', '4', '01', '04', 'Tipo                ', 'Tipo                ', 'Tipo                ', 'X3_TIPO                                                                                                                                                                                                                                                   ', '                                                                                                                                                                                                                                                          '} )
Aadd( aRegs, {'SFTSX3', '4', '01', '05', 'Tamanho             ', '                    ', '                    ', 'X3_TAMANHO                                                                                                                                                                                                                                                ', '                                                                                                                                                                                                                                                          '} )
Aadd( aRegs, {'SFTSX3', '4', '01', '06', 'Decimal             ', '                    ', '                    ', 'X3_DECIMAL                                                                                                                                                                                                                                                ', '                                                                                                                                                                                                                                                          '} )
Aadd( aRegs, {'SFTSX3', '4', '01', '07', 'Titulo              ', '                    ', '                    ', 'X3_TITULO                                                                                                                                                                                                                                                 ', '                                                                                                                                                                                                                                                          '} )
Aadd( aRegs, {'SFTSX3', '4', '01', '08', 'Descricao           ', '                    ', '                    ', 'X3_DESCRIC                                                                                                                                                                                                                                                ', '                                                                                                                                                                                                                                                          '} )
Aadd( aRegs, {'SFTSX3', '5', '01', '  ', '                    ', '                    ', '                    ', 'SX3->X3_CAMPO                                                                                                                                                                                                                                             ', '                                                                                                                                                                                                                                                          '} )
Aadd( aRegs, {'SFTSX3', '6', '01', '  ', '                    ', '                    ', '                    ', 'X3_ARQUIVO == M->I00_TABELA                                                                                                                                                                                                                               ', '                                                                                                                                                                                                                                                          '} )

DbSelectArea("SXB")
DbSetOrder(1)

For i := 1 To Len(aRegs)
	
	lInclui := !DbSeek( aRegs[i,1]+aRegs[i,2]+aRegs[i,3]+aRegs[i,4] )
	
	cTexto += IIf( aRegs[i,1]+aRegs[i,2]+aRegs[i,3]+aRegs[i,4] $ cTexto, "", aRegs[i,1]+aRegs[i,2]+aRegs[i,3]+aRegs[i,4] + "\")
	
	RecLock("SXB", lInclui)
		For j := 1 to Len(aRegs[i])
			FieldPut(j,aRegs[i,j])
		Next
	MsUnlock()
Next i

RestArea(aArea)

cTexto := "SXB.: " + cTexto  + CHR(13) + CHR(10)

Return(.T.)

