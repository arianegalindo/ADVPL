#INCLUDE "PROTHEUS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ DoSX6    ³ Autor ³ OPVS C.A.             ³ Data ³ 18/06/2013 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Funcao generica para copia de dicionarios                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function DoSX6( cTexto )

Local aArea		:= GetArea()
Local i			:= 0
Local j			:= 0
Local aRegs		:= {}
Local lInclui	:= .F.

aRegs  := {}

Aadd( aRegs, {'  ', 'MV_X_FIL' , 'C', 'Cadastro de Organizacao Venda -      ', 'Cadastro de Organizacao Venda -      ', 'Cadastro de Organizacao Venda -      ', 'Geosales)    ', 'Geosales)    ', 'Geosales)    ', '             ', '             ', '             ',  '', '', '', 'U',' ', '                    ', '   ', '                    ','                                  ', '                                  '} )
Aadd( aRegs, {'  ', 'MV_XPRCMIN' , 'N', 'Quantida de escalonamento dos prd (Integraca      ', 'Quantida de escalonamento e desconto do produtos  ', 'Quantida de escalonamento e desconto do produtos  ', 'Geosales)    ', 'Geosales)    ', 'Geosales)    ', '             ', '             ', '             ',  '15     ', '15                 ', '15     ', 'U',' ', '                    ', '   ', '                    ','                                  ', '                                  '} )
//Aadd( aRegs, {'  ', 'MV_XPEDTXT' , 'C', 'Se estiver "Livre" libera a executacao da rotina  ', 'Se estiver "Livre" libera a executacao da rotina  ', 'Se estiver "Livre" libera a executacao da rotina  ', 'SFTEXP pelo Schedule.                             ', 'SFTEXP pelo Schedule.                            ', 'SFTA010 pelo Schedule.                             ', '             ', '             ', '             ',  'LIVRE                             ', 'LIVRE                             ', 'LIVRE                             ', 'U',' ', '                    ', '   ', '                    ','                                  ', '                                  '} )
//Aadd( aRegs, {'  ', 'MV_XTITUSS' , 'C', 'Prefixos dos titulos a ser gerados para SoftSite  ', 'Titulos a ser gerados para a SoftSite             ', 'Titulos a ser gerados para a SoftSite             ', 'Geosales)    ', 'Geosales)    ', 'Geosales)    ', '             ', '             ', '             ',  '851;301;501;308;508;858;011;201;251;301;401;501;551;601;651;701;801;851;                                 ', '10:00/15:00/18:00                 ', '851;301;501;308;508;858;011;201;251;301;401;501;551;601;651;701;801;851;                                 ', 'U',' ', '                    ', '   ', '                    ','                                  ', '                                  '} )
//Aadd( aRegs, {'  ', 'MV_XPEDREM' , 'C', 'Pedidos do tipo Remeça Futura - SoftSite          ', 'Pedidos do tipo Remeça Futura - SoftSite          ', 'Pedidos do tipo Remeça Futura - SoftSite          ', 'Geosales)    ', 'Geosales)    ', 'Geosales)    ', '             ', '             ', '             ',  '5116-5117-5914                    ', '10:00/15:00/18:00                 ', '5116-5117-5914                    ', 'U',' ', '                    ', '   ', '                    ','                                  ', '                                  '} )
//Aadd( aRegs, {'  ', 'MV_XPEDS30' , 'C', 'Se estiver "Livre" libera a executacao da rotina  ', 'Se estiver "Livre" libera a executacao da rotina  ', 'Se estiver "Livre" libera a executacao da rotina  ', 'SFTIMP Filial 30 pelo Schedule.                   ', 'SFTIMP Filial 30 pelo Schedule.                   ', 'SFTIMP Filial 30 pelo Schedule.                   ', '             ', '             ', '             ',  'LIVRE                             ', 'LIVRE                             ', 'LIVRE                             ', 'U',' ', '                    ', '   ', '                    ','                                  ', '                                  '} )
//Aadd( aRegs, {'  ', 'MV_XPEDS50' , 'C', 'Se estiver "Livre" libera a executacao da rotina  ', 'Se estiver "Livre" libera a executacao da rotina  ', 'Se estiver "Livre" libera a executacao da rotina  ', 'SFTIMP Filial 50 pelo Schedule.                   ', 'SFTIMP Filial 50 pelo Schedule.                   ', 'SFTIMP Filial 50 pelo Schedule.                   ', '             ', '             ', '             ',  'LIVRE                             ', 'LIVRE                             ', 'LIVRE                             ', 'U',' ', '                    ', '   ', '                    ','                                  ', '                                  '} )
//Aadd( aRegs, {'  ', 'MV_XPEDS85' , 'C', 'Se estiver "Livre" libera a executacao da rotina  ', 'Se estiver "Livre" libera a executacao da rotina  ', 'Se estiver "Livre" libera a executacao da rotina  ', 'SFTIMP Filial 85 pelo Schedule.                   ', 'SFTIMP Filial 85 pelo Schedule.                   ', 'SFTIMP Filial 85 pelo Schedule.                   ', '             ', '             ', '             ',  'LIVRE                             ', 'LIVRE                             ', 'LIVRE                             ', 'U',' ', '                    ', '   ', '                    ','                                  ', '                                  '} )
//Aadd( aRegs, {'  ', 'MV_XPEDPRO' , 'C', 'Se estiver "Livre" libera a executacao da rotina  ', 'Se estiver "Livre" libera a executacao da rotina  ', 'Se estiver "Livre" libera a executacao da rotina  ', 'SFTPROS pelo Schedule.                            ', 'SFTPROS pelo Schedule.                            ', 'SFTPROS pelo Schedule.                            ', '             ', '             ', '             ',  'LIVRE                             ', 'LIVRE                             ', 'LIVRE                             ', 'U',' ', '                    ', '   ', '                    ','                                  ', '                                  '} )
//Aadd( aRegs, {'  ', 'MV_XPEDCLI' , 'C', 'Se estiver "Livre" libera a executacao da rotina  ', 'Se estiver "Livre" libera a executacao da rotina  ', 'Se estiver "Livre" libera a executacao da rotina  ', 'SFTCLIPRO Filial 30 pelo Schedule.                ', 'SFTCLIPRO pelo Schedule.                          ', 'SFTCLIPRO pelo Schedule.                          ', '             ', '             ', '             ',  'LIVRE                             ', 'LIVRE                             ', 'LIVRE                             ', 'U',' ', '                    ', '   ', '                    ','                                  ', '                                  '} )
 
DbSelectArea("SX6")
DbSetOrder(1)

For i := 1 To Len(aRegs)
	
	lInclui := !DbSeek( aRegs[i,1]+aRegs[i,2] )
	
	cTexto += IIf( aRegs[i,1]+aRegs[i,2] $ cTexto, "", aRegs[i,1]+aRegs[i,2] + "\")
	
	RecLock("SX6", lInclui)
		For j := 1 to Len(aRegs[i])
			FieldPut(j,aRegs[i,j])
		Next
	MsUnlock()
Next i

RestArea(aArea)

cTexto := "SX6.: " + cTexto  + CHR(13) + CHR(10)

Return(.T.)

