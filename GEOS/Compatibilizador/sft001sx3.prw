#INCLUDE "PROTHEUS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄ-ÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³DoSX3     ³ Autor ³ OPVS C.A.             ³ Data ³ 18/06/2013 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄ-ÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Funcao Principal                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄ-ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³                                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ-ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function DoSX3( cTexto )
Private aSx3	:= {"X3_ARQUIVO","X3_ORDEM","X3_CAMPO","X3_TIPO","X3_TAMANHO","X3_DECIMAL","X3_TITULO","X3_TITSPA","X3_TITENG","X3_DESCRIC","X3_DESCSPA","X3_DESCENG","X3_PICTURE","X3_VALID","X3_USADO","X3_RELACAO","X3_F3","X3_NIVEL","X3_RESERV","X3_CHECK","X3_TRIGGER","X3_PROPRI","X3_BROWSE","X3_VISUAL","X3_CONTEXT","X3_OBRIGAT","X3_VLDUSER","X3_CBOX","X3_CBOXSPA","X3_CBOXENG","X3_PICTVAR","X3_WHEN","X3_INIBRW","X3_GRPSXG","X3_FOLDER","X3_PYME","X3_CONDSQL","X3_CHKSQL","X3_IDXSRV","X3_ORTOGRA","X3_IDXFLD","X3_TELA","X3_AGRUP"}
Private	nSx3	:= 0

	// Roda o compatibilizador de estrutura da tabela I00
	U_DoSX3I00( @cTexto )
	Aadd( aArqUpd, "I00" )
	// Roda o compatibilizador de estrutura da tabela I01
	U_DoSX3I01( @cTexto )
	Aadd( aArqUpd, "I01" )
	// Roda o compatibilizador de estrutura da tabela I02
	U_DoSX3I02( @cTexto )
	Aadd( aArqUpd, "I02" )
	// Roda o compatibilizador de estrutura da tabela I03
	U_DoSX3I03( @cTexto )
	Aadd( aArqUpd, "I03" )
	// Roda o compatibilizador de estrutura da tabela I04
	U_DoSX3I04( @cTexto )
	Aadd( aArqUpd, "I04" )

	// Roda o compatibilizador de estrutura da tabela SC5
	U_DoSX3SC5( @cTexto )
	aadd(aArqUpd, "SC5")

	// Roda o compatibilizador de estrutura da tabela SC6
	U_DoSX3SC6( @cTexto )
	aadd(aArqUpd, "SC6")
	
	// Roda o compatibilizador de estrutura da tabela SC5
	U_DoSX3SU5( @cTexto )
	aadd(aArqUpd, "SU5")

	// Roda o compatibilizador de estrutura da tabela SC6
	U_DoSX3SUS( @cTexto )
	aadd(aArqUpd, "SUS")
	
	// Roda o compatibilizador de estrutura da tabela SC6
	U_DoSX3SA1( @cTexto )
	aadd(aArqUpd, "SA1")
Return(.T.)

