#include 'Protheus.ch'

/*/{Protheus.doc} nomeStaticFunction
(long_description)
@type  User Function
@author user
@since date
@version version
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
User Function PEAtivado(cPE)
    Local bRet := .F.
    Local xArea := ZX4->( getArea() )
    
    DbSelectArea('ZX4')
    ZX4->( DbSetOrder(2) )
    If ZX4->( DbSeek( xFilial('ZX4') + cPE ) )
    	If ZX4->ZX4_STATUS == "A"
    		bRet := .T.
    	EndIf
    EndIf
    
    RestArea(xArea)
Return bRet

//---------------------------------------------------------------------
/*/{Protheus.doc} PETabela
(long_description)
@type  Static Function
@author @vbastos
@since 07/06/2019
@version 1.0
@param cPE, character, Nome do Ponto de Entrada a ser verificado
@return aTabs, Array, Array composto pelo par [1]: Tabela Protheus
[2]: Tabela Geosales
/*/
//---------------------------------------------------------------------
Static Function PETabela(cPE)
	Local aTabs := {}

	If AScan({"FA60BDE"},cPE) != 0
		aTabs := {"SE1","TITULOS"}
	ElseIf AScan({"M030INC","M030PALT","M030EXC"},cPE) != 0
		aTabs := {"SA1","CLIENTE"}
	ElseIf AScan({"MA040DAL","MA040DIN","MT040DEL"},cPE) != 0
		aTabs := {"SA3","VENDEDOR"}
	ElseIf AScan({"MSD2460","MSD2520"},cPE) != 0
		aTabs := {"SB2","PRODUTO_ESTOQUE"}
	ElseIf AScan({"MT010ALT","MT010INC","MT010EXC"},cPE) != 0
		aTabs := {"SB1","PRODUTO"}
	ElseIf AScan({"MT360GRV"},cPE) != 0
		aTabs := {"SE4","CONDICAO_PAGAMENTO"}
	ElseIf AScan({"MA035ALT","MA035DEL","MA035INC"},cPE) != 0
		aTabs := {"SBM",""}
	ElseIf aScan({"MA050TTS"},cPE) != 0
		aTabs := {"SA4",""}
	Else
		If cPE = "OS010EXT"
			aTabs := {"DA0","DA1"}
		ElseIF cPE = "OS010GRV"
			aTabs := {{"DA0"},{"DA1","LISTA_PRODUTO","FAIXA_PRECO_PRODUTO"}}
		Else
			aTabs := {"",""}
		EndIf
	EndIf
Return aTabs

//---------------------------------------------------------------------
/*/{Protheus.doc} PETipoEnvio
(long_description)
@type  Static Function
@author @vbastos
@since 07/06/2019
@version 1.0
@param cPE, character, Nome do Ponto de Entrada a ser verificado
@return cModEnv, character, Indica o tipo de envio a ser executado
/*/
//---------------------------------------------------------------------
Static Function PETipoEnvio(cPE)
	Local cModEnv	:= ""
	Local aSend		:= {}
	Local aDelay	:= {"M030EXC","MA035ALT","MA035DEL","MA035INC","MT010EXC","MT040DEL","MA050TTS"}
	Local aRel		:= {"FA60BDE","M030INC","M030PALT","MA040DAL","MA040DIN","MSD2460","MSD2520","MT010ALT","MT010INC","MT360GRV"}

	if AScan(aSend,cPE) != 0
		cModEnv := "SEND"
	ElseIF AScan(aDelay,cPE) != 0
		cModEnv := "DELAY"
	ElseIF AScan(aRel,cPE) != 0
		cModEnv := "REL"
	Else
		//Tipos de envios alternativos devem ser definidos aqui
		If cPE = "OS010EXT"
			cModEnv := "10EXT"
		ElseIF cPE = "OS010GRV"
			cModEnv := "10GRV"
		Else
			cModEnv := ""
		EndIf
	EndIf
Return cModEnv

//---------------------------------------------------------------------
/*/{Protheus.doc} ipgPE

Função chamada após iniciar uma gravação de dados através de um PE.
A partir do nome do PE, verifica-se se este está habilitado, define-se
a tabela e o tipo de envio a ser executado.

@type function
@author @vbastos
@since 07/06/2019
@version 1.0
@param cPE, character, Nome do Ponto de Entrada a ser verificado
@param cOP, character, Indicador da operação a ser executada
@return bExec, booleano, Indica se o PE está habilitado
/*/
//---------------------------------------------------------------------

User Function ipgPE(cPE, cOP)
	Local bExec		:= U_PEAtivado(cPE)

	If bExec
		aTabs := PETabela(cPE)
		cModEnv := PETipoEnvio(cPE)

		DO CASE
			CASE cModEnv = "REL"
				u_ipgRel(aTabs[1], aTabs[2])
			CASE cModEnv = "SEND"
				u_ipgSend(aTabs[1], cOP)
			CASE cModEnv = "DELAY"
				u_delaySend(aTabs[1])
			CASE cModEnv = "10EXT"
				U_limpaFlagGS(aTabs[1])
				U_limpaFlagGS(aTabs[2], aTabs[1])
			CASE cModEnv = "10GRV"
				U_limpaFlagGS(aTabs[1][1])
				U_limpaFlagGS(aTabs[2][1], aTabs[1][1])
				U_ipgRel(aTabs[1][1])
				U_ipgRel(aTabs[2][1], aTabs[2][2])
				U_limpaFlagGS(aTabs[2][1], aTabs[1][1])
				U_ipgRel(aTabs[2][1], aTabs[2][3])
			OTHERWISE
				bExec = .F.
		ENDCASE
	EndIf
Return bExec