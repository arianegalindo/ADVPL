#INCLUDE "PROTHEUS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ DoSIX    ³ Autor ³ OPVS C.A.             ³ Data ³ 18/06/2013 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Funcao generica para copia de dicionarios                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³                                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function DoSIX( cTexto )

Local aArea		:= GetArea()
Local i			:= 0
Local j			:= 0
Local aRegs		:= {}
Local lInclui	:= .F.
Local aCampos	:= {"INDICE","ORDEM","CHAVE","DESCRICAO","DESCSPA","DESCENG","PROPRI","F3","NICKNAME","SHOWPESQ"} 

aRegs  := {}

Aadd( aRegs, {'I00', '1', 'I00_FILIAL+I00_CODLAY                                                                                                                                           ', 'Cod. Layout                                                           ', 'Cod. Layout                                                           ', 'Cod. Layout                                                           ', 'U', '                                                                                                                                                                ', '          ', 'S'} )
Aadd( aRegs, {'I00', '2', 'I00_FILIAL+I00_TABELA                                                                                                                                           ', 'Tabela                                                                ', 'Tabela                                                                ', 'Tabela                                                                ', 'U', '                                                                                                                                                                ', '          ', 'S'} )
Aadd( aRegs, {'I01', '1', 'I01_FILIAL+I01_CODLAY+I01_ORDEM                                                                                                                                 ', 'Cod Layout+Ordem                                                      ', 'Cod Layout+Ordem                                                      ', 'Cod Layout+Ordem                                                      ', 'U', '                                                                                                                                                                ', '          ', 'S'} )
Aadd( aRegs, {'I02', '1', 'I02_FILIAL+I02_CODLAY                                                                                                                                           ', 'Cod. Layout                                                           ', 'Cod. Layout                                                           ', 'Cod. Layout                                                           ', 'U', '                                                                                                                                                                ', '          ', 'N'} )
Aadd( aRegs, {'I03', '1', 'I03_FILIAL+I03_CODLAY+I03_SEQARQ                                                                                                                                ', 'Cod. Layout+Seq. Arquivo                                              ', 'Cod. Layout+Seq. Arquivo                                              ', 'Cod. Layout+Seq. Arquivo                                              ', 'U', '                                                                                                                                                                ', '          ', 'N'} )
Aadd( aRegs, {'I04', '1', 'I04_FILIAL+I04_CODLAY+I04_SEQARQ+I04_SEQCPO                                                                                                                     ', 'Cod. Layout+Seq. Arquivo+Seq. Campo                                   ', 'Cod. Layout+Seq. Arquivo+Seq. Campo                                   ', 'Cod. Layout+Seq. Arquivo+Seq. Campo                                   ', 'U', '                                                                                                                                                                ', '          ', 'N'} )

DbSelectArea("SIX")
DbSetOrder(1)

For i := 1 To Len(aRegs)
	
	lInclui := !DbSeek( aRegs[i,1]+aRegs[i,2] )
	
	cTexto += IIf( aRegs[i,1]+aRegs[i,2] $ cTexto, "", aRegs[i,1]+aRegs[i,2] + "\")
	
	RecLock("SIX", lInclui)
		
		For j := 1 to Len(aRegs[i])
			
			nPosCpo := FieldPos(aCampos[j])
			If nPosCpo == 0
				loop
			EndIf
			
			If j <= Len(aRegs[i])
				FieldPut(nPosCpo,aRegs[i,j])
			Endif
		Next
	MsUnlock()
Next i

RestArea(aArea)

cTexto := "SIX.: " + cTexto  + CHR(13) + CHR(10)

Return(.T.)

