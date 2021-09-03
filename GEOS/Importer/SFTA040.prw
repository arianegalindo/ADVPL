#Include 'Protheus.ch'

User Function SFTA040()

// 1=Ativo;2=Suspenso;3=Encerrado;4=Clie.Prospect;5=Ped.Pospect
Local aCores	:= {	{ "I02_STATUS=='1'",	"BR_VERDE"		},;
						{ "I02_STATUS=='2'",	"BR_AMARELO"	},;
						{ "I02_STATUS=='3'",	"BR_PRETO"	},;
						{ "I02_STATUS=='4'",	"BR_PINK"	},;
						{ "I02_STATUS=='5'",	"BR_AZUL"	};												
						}

PRIVATE aRotina := {	{ "Pesquisar",	"AxPesqui", 	0, 1	},;
						{ "Visualizar",	"U_SFT040Fun",	0, 2	},;
						{ "Incluir",	"U_SFT040Fun",	0, 3	},;
						{ "Alterar",	"U_SFT040Fun",	0, 4, 2	},;
						{ "Excluir",	"U_SFT040Fun",	0, 5	},;
						{ "Legenda",	"U_SFT040Lege",	0, 2	};
					}

PRIVATE cCadastro := "Cadasto de Layouts para importação de dados

DbSelectArea("I03")		// Arquivos
DbSelectArea("I04")		// Campos dos Arquivos
DbSelectArea("I02")		// Cadastro Layouts

mBrowse(0,0,0,0,"I02",,,,,,aCores) 

Return(.T.)

User Function SFT040Lege()

// 1=Ativo;2=Suspenso;3=Cancelado;4=Clie.Prospect;5=Ped.Pospect
BrwLegenda(cCadastro,"Legenda", {	{"BR_VERDE",	"Ativo"},;
									{"BR_AMARELO",	"Suspenso"},;
									{"BR_PRETO",	"Cancelado"},;
									{"BR_PINK",	"Cli. Propesct"},;
									{"BR_AZUL",	"Ped. Propesct"};																		
								};
			)

Return(.T.)


User Function SFT040Fun(cAlias, nReg, nOpc)
Local nI		:= 0
Local nUsado	:= 0
Local aSize		:= MsAdvSize(.T.)
Local nHeight	:= aSize[6]
Local nWidth	:= aSize[5]
Local oPanelTop
Local oJan1
Local oJan2
Local oPanelBot
Local aColsAux	:= {}

Private aHeaderI03:= {}
Private aColsI03	:= {}
Private aHeaderI04:= {}
Private aColsI04	:= {}
Private oDlg,oMsGetDI03,oMsGetDI04,oMsMGet
Private aGets	:= {}
Private aTela	:= {}

If nOpc == 3
	RegToMemory(cAlias,.T.)
Else
	RegToMemory(cAlias,.F.)
EndIf

CargaDad("I03", @aHeaderI03, @aColsI03, M->I02_CODLAY,nOpc==3)
CargaDad("I04", @aHeaderI04, @aColsI04, M->I02_CODLAY,nOpc==3)

DEFINE MSDIALOG oDlg TITLE cCadastro FROM aSize[7],0 TO nHeight, nWidth OF oMainWnd PIXEL
oPanelTop:= tPanel():New(0,0,"",oDlg,,,,,,00,70)
oPanelTop:align:= CONTROL_ALIGN_TOP

oPanelBot:= tPanel():New(0,0,"",oDlg,,,,,,00,30)
oPanelBot:align:= CONTROL_ALIGN_ALLCLIENT

oLayer := FWLayer():New()
oLayer:Init(oPanelBot,.F.,.T.) 

oLayer:addLine("LINHA1", 100, .F.)

oLayer:AddCollumn("Jan1",40,.F.,"LINHA1")
oLayer:AddWindow("Jan1","oJan1","Arquivos",095,.F.,.F.,{ || },"LINHA1",{|| })
oJan1 := oLayer:GetWinPanel("Jan1","oJan1","LINHA1") 

oLayer:AddCollumn("Jan2",60,.F.,"LINHA1")
oLayer:AddWindow("Jan2","oJan2","Campos",95,.F.,.F.,{ || },"LINHA1",{|| })
oJan2 := oLayer:GetWinPanel("Jan2","oJan2","LINHA1") 

oMsMGet := MsMGet():New(cAlias,nReg,nOpc,,,,,{15,0,(nHeight/4),(nWidth/2)},,3,,,,oPanelTop)
oMsMGet:oBox:align:= CONTROL_ALIGN_ALLCLIENT

oMsGetDI03 := MsNewGetDados():New(0,0,100,300,,"AllwaysTrue()",,,,,4096,"AllwaysTrue()",,,oJan1,aHeaderI03,aColsI03)
oMsGetDI03:oBrowse:align:= CONTROL_ALIGN_ALLCLIENT
oMsGetDI03:bChange := {||	oMsGetDI04:SetArray(aColsI04),;
							aColsAux := {},;
							aEval(oMsGetDI04:aCols,{|x| IIf(x[1] == oMsGetDI03:aCols[oMsGetDI03:nAt,1], aadd(aColsAux,x),nil) }),;
							oMsGetDI04:SetArray(aColsAux),;
							oMsGetDI04:Refresh() }

oMsGetDI04 := MsNewGetDados():New(0,0,100,300,,"AllwaysTrue()",,,,,4096,"AllwaysTrue()",,,oJan2,aHeaderI04,aColsI04)
oMsGetDI04:oBrowse:align:= CONTROL_ALIGN_ALLCLIENT

oTButton1 := TButton():New( 002, 002, "Excluir Arquivo",oJan1,{||FunCols("I03",1,5)}, 40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
oTButton1:align:= CONTROL_ALIGN_BOTTOM
oTButton2 := TButton():New( 002, 002, "Alterar Arquivo",oJan1,{||FunCols("I03",1,4)}, 40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
oTButton2:align:= CONTROL_ALIGN_BOTTOM
oTButton3 := TButton():New( 002, 002, "Incluir Arquivo",oJan1,{||FunCols("I03",1,3)}, 40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
oTButton3:align:= CONTROL_ALIGN_BOTTOM

ACTIVATE MSDIALOG oDlg  ON INIT EnchoiceBar(oDlg, {|| IIF(nOpc ==2 .or. (SFT040All() .AND. SFT040Grv()),oDlg:End(),.T.) }, {|| oDlg:End() } )

Return(.T.)

Static Function CargaDad(cAlias, aHeader, aCols, cChave, lInclui)
Local nI	:= 0    
Local nUsado	:= 0

SX3->( DbSetOrder(1) )
SX3->( MsSeek( cAlias ) )
While SX3->( !Eof() ) .AND. SX3->X3_ARQUIVO == cAlias
	If X3uso(SX3->X3_USADO) .AND. cNivel >= SX3->X3_NIVEL
		Aadd(aHeader, {	SX3->X3_TITULO,;
						SX3->X3_CAMPO,;
						SX3->X3_PICTURE,;
						SX3->X3_TAMANHO,;
						SX3->X3_DECIMAL,;
						SX3->X3_VALID,;
						SX3->X3_USADO,;
						SX3->X3_TIPO,;
						SX3->X3_F3,;
						SX3->X3_CONTEXT } )
		nUsado++
	Endif
	
	SX3->( DbSkip() )
End

If lInclui
	Aadd(aCols,Array(nUsado+1))
	For nI := 1 To nUsado
		If Alltrim(aHeader[nI][2]) == cAlias+"_SEQARQ" .OR. Alltrim(aHeader[nI][2]) == cAlias+"_SEQCPO"
			aCols[Len(aCols)][nI] := "001"
		Else
			aCols[Len(aCols)][nI] := CriaVar(aHeader[nI][2],.F.)
		Endif
	Next nJ
	aCols[Len(aCols)][nUsado+1] := .F.
Else
	(cAlias)->( DbSetOrder(1) )
	If (cAlias)->( MsSeek( xFilial(cAlias)+cChave ) )
		While	(cAlias)->( !Eof() ) .AND.;
				(cALias)->&(cAlias+"_FILIAL") == xFilial(cAlias) .AND.;
				(cAlias)->&(cAlias+"_CODLAY") == cChave
		
			Aadd(aCols,Array(nUsado+1))
			For nI := 1 To nUsado
				If ( aHeader[nI][10] !=  "V" )
					aCols[Len(aCols)][nI] := (cAlias)->( FieldGet(FieldPos(aHeader[nI][2])) )
				Else
					aCols[Len(aCols)][nI] := CriaVar(aHeader[nI][2],.T.)
				EndIf
			Next nJ
			aCols[Len(aCols)][nUsado+1] := .F.
			
			(cAlias)->( DbSkip() )
		End
	Else
		Aadd(aCols,Array(nUsado+1))
		For nI := 1 To nUsado
			aCols[Len(aCols)][nI] := CriaVar(aHeader[nI][2],.F.)
		Next nJ
		aCols[Len(aCols)][nUsado+1] := .F.
	Endif
EndIf

Return

Static Function SFT040All()

If !Obrigatorio(aGets,aTela)
	Return(.F.)
Endif

If 	(Len(oMsGetDI03:aCols) <= 1 .AND. Empty(oMsGetDI03:aCols[oMsGetDI03:nAt][2]) .AND. Empty(oMsGetDI03:aCols[oMsGetDI03:nAt][3])) .or.;
	((Len(oMsGetDI04:aCols) <= 1 .AND. Empty(oMsGetDI04:aCols[oMsGetDI04:nAt][2]) .AND. Empty(oMsGetDI04:aCols[oMsGetDI04:nAt][3])))
	MsgStop("Informe a estrutura de campos e tabela que será importada para gravação...")
	Return(.F.) 
Endif

Return(.T.)

Static Function SFT040Grv(cAlias)

Local aStruI02		:= I02->( DbStruct() )
Local nI			:= 0

Begin Transaction
	
	I02->( DbSetOrder(1) )
	I02->( MsSeek( xFilial("I02")+M->I02_CODLAY ) )
	
	I02->( RecLock( "I02", I02->(!Found()) ) )
	For nI := 1 To Len(aStruI02)
		cCampo := AllTrim(aStruI02[nI][1])
		Do Case
			Case cCampo == "I02_FILIAL"
				&("I02->"+cCampo) := xFilial("I02")
			Otherwise
				&("I02->"+cCampo) := &("M->"+cCampo)
		Endcase
	Next nI
	I02->( MsUnLock() )
	
	GrvCols("I03",M->I02_CODLAY, oMsGetDI03)
	GrvCols("I04",M->I02_CODLAY, oMsGetDI04)
	
End Transaction

Return(.T.)

Static Function GrvCols(cAlias, cChave, oMsGetD)

Local aStru			:= (cAlias)->( DbStruct() )
Local nI			:= 0
Local nJ			:= 0
Local cCampo		:= ""
Local aHeader		:= Aclone(oMsGetD:aHeader)
Local aCols			:= Aclone(oMsGetD:aCols)
Local nP_SEQARQ		:= Ascan( aHeader, { |x|, AllTrim(x[2])==cAlias+"_SEQARQ" } )
Local nP_SEQCPO		:= Ascan( aHeader, { |x|, AllTrim(x[2])==cAlias+"_SEQCPO" } )
Local cChaveArq		:= ""

For nI := 1 To Len(aCols)
	
	If nP_SEQARQ > 0 .and. Empty(aCols[nI][nP_SEQARQ])
		Loop     
	ElseIf nP_SEQARQ > 0
		cChaveArq := aCols[nI][nP_SEQARQ] 
	Endif
	
	If nP_SEQCPO > 0 .and. Empty(aCols[nI][nP_SEQCPO])
		Loop
	ElseIf nP_SEQCPO > 0
		cChaveArq += aCols[nI][nP_SEQCPO]
	Endif
	
	(cAlias)->( DbSetOrder(1) )
	(cAlias)->( MsSeek( xFilial(cAlias)+cChave+cChaveArq ) )
	
	If aCols[nI][Len(aCols[nI])]
		If (cAlias)->( Found() )
			(cAlias)->( RecLock(cAlias,.F.) )
			(cAlias)->( DbDelete() )
			(cAlias)->( MsUnLock() )
		Endif
		Loop
	Endif
	
	(cAlias)->( RecLock((cAlias),(cAlias)->(!Found())) )
	&(cAlias+"->"+cAlias+"_FILIAL") := xFilial(cAlias)
	&(cAlias+"->"+cAlias+"_CODLAY") := cChave
	For nJ := 1 To Len(aHeader)
		If aHeader[nJ][10] <> "V"
			&(cAlias+"->"+aHeader[nJ][2]) := aCols[nI][nJ]
		Else
			Loop
		Endif
	Next nI
	(cAlias)->( MsUnLock() )
Next nI
return

Static Function FunCols(cAlias, nReg, nOpc)
Local nI,nJ		:= 0
Local aHeader	:= aClone(oMsGetDI04:aHeader)
Local aCols		:= {}
Local nUsado	:= 0
Local aSize		:= MsAdvSize(.T.)
Local nHeight	:= aSize[6]
Local nWidth	:= aSize[5]
Local nP_SEQARQ	:= Ascan( oMsGetDI04:aHeader, { |x|, AllTrim(x[2])=="I04_SEQARQ" } )
Local nP_SEQCPO	:= Ascan( oMsGetDI04:aHeader, { |x|, AllTrim(x[2])=="I04_SEQCPO" } )
Local nOpcA		:= 0
Local aGetsAnt	:= aClone(aGets)
Local aTelaAnt	:= aClone(aTela)
Local nPos		:= 0 
Local lRet		:= .T.
Local cSeqArq	:= ""

Private oDlg2,oMsGetD,oMsMGet

aGets	:= {}
aTela	:= {}

RegToMemory("I03",.F.)

For nI := 1 to Len(oMsGetDI03:aHeader)
	If nOpc == 3
		M->I03_SEQARQ := StrZero(Len(oMsGetDI03:aCols)+1,3)
	Else
		&("M->"+oMsGetDI03:aHeader[nI,2]) := oMsGetDI03:aCols[oMsGetDI03:nAt][nI]
	EndIf
Next

cSeqArq := M->I03_SEQARQ

If nOpc == 3
	aadd(aCols,Array(len(oMsGetDI04:aHeader)+1))
	For nI:=1 to len(oMsGetDI04:aHeader)+1
		If nI == len(oMsGetDI04:aHeader)+1
			aCols[1][nI] := .F.	
		Else
			If oMsGetDI04:aHeader[nI,2] == "I04_SEQCPO"
				aCols[1][nI] := "001"
			Else 
				aCols[1][nI] := CriaVar(oMsGetDI04:aHeader[nI,2])
			EndIf
		Endif 
	Next
Else
	For nI:=1 to len(oMsGetDI04:aCols)
		If oMsGetDI04:aCols[nI][nP_SEQARQ] == cSeqArq
			aadd(aCols,oMsGetDI04:aCols[nI])	
		Endif
	Next
EndIf

DEFINE MSDIALOG oDlg2 TITLE cCadastro FROM aSize[7],0 TO nHeight, nWidth OF oMainWnd PIXEL

oMsMGet := MsMGet():New(cAlias,nReg,IIF(nOpc=5,4,nOpc),,,,,{15,0,(nHeight/4),(nWidth/2)},,3,,,,oDlg2)

oMsGetD := MsNewGetDados():New((nHeight/4),0,(nHeight/2),(nWidth/2),GD_INSERT+GD_DELETE+GD_UPDATE,"U_FunColLi()",,,,,4096,"U_FunColFi()",,,oDlg2,aHeader,aCols)

ACTIVATE MSDIALOG oDlg2 on init EnchoiceBar(oDlg2, {|| nOpca := 1, iif(VldCols(oMsGetD),oDlg2:End(),.T.) }, {|| nOpca := 0, oDlg2:End() } )

If nOpcA == 1 
    If nOpc == 3 .or.  nOpc == 4 
		nP_SEQARQ	:= Ascan( oMsGetDI03:aHeader, { |x|, AllTrim(x[2])=="I03_SEQARQ" } )
		nPos 		:= Ascan(oMsGetDI03:aCols, {|x| x[nP_SEQARQ] == cSeqArq }) 
		
		If nPos <= 0
			aadd(oMsGetDI03:aCols, Array(Len(oMsGetDI03:aHeader)+1))
			nPos := Len(oMsGetDI03:aCols) 
		EndIf
	
		For nI := 1 to Len(oMsGetDI03:aHeader)+1
			If nI == Len(oMsGetDI03:aHeader)+1
				oMsGetDI03:aCols[nPos][nI] := .F.
			Else
				oMsGetDI03:aCols[nPos][nI] := &("M->"+oMsGetDI03:aHeader[nI,2]) 
			EndIf
		Next	
	
		For nI:=1 to Len(oMsGetD:aCols)
			nP_SEQARQ	:= Ascan( oMsGetDI04:aHeader, { |x|, AllTrim(x[2])=="I04_SEQARQ" } )
			nP_SEQCPO	:= Ascan( oMsGetDI04:aHeader, { |x|, AllTrim(x[2])=="I04_SEQCPO" } )
			nPos 		:= Ascan(oMsGetDI04:aCols, {|x| x[nP_SEQARQ] == cSeqArq .AND. x[nP_SEQCPO] == oMsGetD:aCols[nI,nP_SEQCPO] }) 
			nPos2 		:= Ascan(aColsI04, {|x| x[nP_SEQARQ] == cSeqArq .AND. x[nP_SEQCPO] == oMsGetD:aCols[nI,nP_SEQCPO] }) 

			If nPos <= 0
				aadd(oMsGetDI04:aCols, Array(Len(oMsGetDI04:aHeader)+1))
				nPos := Len(oMsGetDI04:aCols) 
			EndIf
		
			For nJ := 1 to Len(oMsGetDI04:aHeader)+1
				oMsGetDI04:aCols[nPos][nJ] := oMsGetD:aCols[nI,nJ]
			Next
			
			If nPos2 <= 0
				aadd(aColsI04, Array(Len(oMsGetDI04:aHeader)+1))
				nPos2 := Len(aColsI04) 
			EndIf
		
			For nJ := 1 to Len(oMsGetDI04:aHeader)+1
				aColsI04[nPos2][nJ] := oMsGetD:aCols[nI,nJ]
			Next
		Next
	 
	ElseIf nOpc == 5
		lRet := .F.
		While !lRet
			nP_SEQARQ	:= Ascan( oMsGetDI03:aHeader, { |x|, AllTrim(x[2])=="I03_SEQARQ" } )
			nPos 		:= Ascan(oMsGetDI03:aCols, {|x| x[nP_SEQARQ] == cSeqArq }) 
			
			If nPos > 0
				aDel(oMsGetDI03:aCols, nPos)
				If len(oMsGetDI03:aCols) <= 0
					oMsGetDI03:AddLine(.T.)
				Endif
				lRet := .T.
			Else
				lRet := .F.
			EndIf
			
			For nI:=1 to Len(oMsGetD:aCols)
				nP_SEQARQ	:= Ascan( oMsGetDI04:aHeader, { |x|, AllTrim(x[2])=="I04_SEQARQ" } )
				nPos 		:= Ascan(oMsGetDI04:aCols, {|x| x[nP_SEQARQ] == cSeqArq }) 
				nPos2 		:= Ascan(aColsI04, {|x| x[nP_SEQARQ] == cSeqArq  }) 
						
				If nPos > 0
					aDel(oMsGetDI04:aCols, nPos)
					If len(oMsGetDI04:aCols) <= 0
						oMsGetDI04:AddLine(.T.)
					Endif
					lRet := .T.
				Else
					lRet := .F.
				EndIf
				
				If nPos2 > 0
					aDel(aColsI04, nPos2)
				EndIf
			Next
	
		EndDo
	EndIf
	oMsGetDI03:Refresh()
	oMsGetDI04:Refresh()
EndIf

aGets := aClone(aGetsAnt)
aTela := aClone(aTelaAnt)

Return(.T.)                      

Static Function VldCols(oMsGetD)
Local lRet := .T.

If !Obrigatorio(aGets,aTela)
	lRet := .F.
Endif

If 	Len(oMsGetD:aCols) <= 1 .and. Empty(oMsGetD:aCols[oMsGetD:nAt][3])  .and. Empty(oMsGetD:aCols[oMsGetD:nAt][4]) 
	MsgStop("Informe a estrutura de campos e tabela que será importada para gravação...")
	lRet := .F.
Endif

Return(lRet)

User Function FunColLi()

If Empty(oMsGetD:aCols[oMsGetD:nAt][3]) .AND. Empty(oMsGetD:aCols[oMsGetD:nAt][4])
	MsgStop("É obrigatório informar um campo ou uma função...")
	Return(.F.)
Endif 

Return(.T.)

User Function FunColFi()

Local cCampo		:= Alltrim( ReadVar() )
Local aHeader		:= Aclone(oMsGetD:aHeader)
Local aCols			:= Aclone(oMsGetD:aCols)
Local nPI04_CAMPO	:= Ascan( aHeader, { |x|, AllTrim(x[2])=="I04_CAMPO" } )
Local nPI04_FUNCAO	:= Ascan( aHeader, { |x|, AllTrim(x[2])=="I04_FUNCAO" } )

Do Case
	Case cCampo == "M->I04_CAMPO"
		If !Empty( aCols[oMsGetD:nAt][nPI04_FUNCAO] )
			MsgStop("Você definiu uma função e não poderá definir um campo ao mesmo tempo...")
			Return(.F.)
		Endif
	Case cCampo == "M->I04_FUNCAO"
		If !Empty( aCols[oMsGetD:nAt][nPI04_CAMPO] )
			MsgStop("Você definiu um campo e não poderá definir uma função ao mesmo tempo...")
			Return(.F.)
		Endif
		If !FindFunction( &(cCampo) )
			MsgAlert("Atenção, Esta função não está compilada neste repositório...")
		Endif
Endcase

Return(.T.)
