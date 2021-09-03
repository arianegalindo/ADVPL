#INCLUDE "PROTHEUS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ DoSX2    ³ Autor ³ OPVS C.A.             ³ Data ³ 18/06/2013 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Funcao generica para copia de dicionarios                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³                                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function DoSX2( cTexto )

Local aArea		:= GetArea()
Local i			:= 0
Local j			:= 0
Local aRegs		:= {}
Local lInclui	:= .F.
Local aCampos	:= {"X2_CHAVE","X2_PATH","X2_ARQUIVO","X2_NOME","X2_NOMESPA","X2_NOMEENG","X2_ROTINA","X2_MODO","X2_MODOUN","X2_MODOEMP","X2_DELET","X2_TTS","X2_UNICO","X2_PYME","X2_MODULO","X2_DISPLAY","X2_SYSOBJ","X2_USROBJ"} 

aRegs  := {}

Aadd( aRegs, {'I00', '\DATA\                                  ', 'I00010  ', 'CABECALHO LAYOUT EXP. DADOS   ', 'CABECALHO LAYOUT EXP. DADOS   ', 'CABECALHO LAYOUT EXP. DADOS   ', '                                        ', 'C', 'C', 'C',              0, ' ', '                                                                                                                                                                                                                                                          ', ' ',              0, '                                                                                                                                                                                                                                                              '} )
Aadd( aRegs, {'I01', '\DATA\                                  ', 'I01010  ', 'ITENS LAYOUT EXPORTA DADOS    ', 'ITENS LAYOUT EXPORTA DADOS    ', 'ITENS LAYOUT EXPORTA DADOS    ', '                                        ', 'C', 'C', 'C',              0, ' ', '                                                                                                                                                                                                                                                          ', ' ',              0, '                                                                                                                                                                                                                                                              '} )
Aadd( aRegs, {'I02', '                                        ', 'I02010  ', 'LAYOUT IMPORTACAO DE DADOS    ', 'LAYOUT IMPORTACAO DE DADOS    ', 'LAYOUT IMPORTACAO DE DADOS    ', '                                        ', 'E', 'E', 'E',              0, ' ', '                                                                                                                                                                                                                                                          ', ' ',              0, '                                                                                                                                                                                                                                                              '} )
Aadd( aRegs, {'I03', '                                        ', 'I03010  ', 'ARQUIVOS IMPORTACAO DE DADOS  ', 'ARQUIVOS IMPORTACAO DE DADOS  ', 'ARQUIVOS IMPORTACAO DE DADOS  ', '                                        ', 'E', 'E', 'E',              0, ' ', '                                                                                                                                                                                                                                                          ', ' ',              0, '                                                                                                                                                                                                                                                              '} )
Aadd( aRegs, {'I04', '                                        ', 'I04010  ', 'CAMPOS IMPORTACAO DE DADOS    ', 'CAMPOS IMPORTACAO DE DADOS    ', 'CAMPOS IMPORTACAO DE DADOS    ', '                                        ', 'C', 'C', 'C',              0, ' ', '                                                                                                                                                                                                                                                          ', ' ',              0, '                                                                                                                                                                                                                                                              '} )

DbSelectArea("SX2")
DbSetOrder(1)

For i := 1 To Len(aRegs)
	
	lInclui := !DbSeek( aRegs[i,1] )
	
	cTexto += IIf( aRegs[i,1] $ cTexto, "", aRegs[i,1] + "\")
	
	RecLock("SX2", lInclui)
		
		For j := 1 to Len(aRegs[i])
			
			nPosCpo := FieldPos(aCampos[j])
			If nPosCpo == 0
				loop
			EndIf
			
			If allTrim(Field(j)) == "X2_ARQUIVO"
				aRegs[i,j] := SubStr(aRegs[i,j], 1, 3) + SM0->M0_CODIGO + "0"
			EndIf
			FieldPut(nPosCpo,aRegs[i,j])
			
		Next
	MsUnlock()
Next i

RestArea(aArea)

cTexto := "SX2.: " + cTexto  + CHR(13) + CHR(10)

Return(.T.)

