#Include 'Protheus.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} SGEOV002()

Verifica os PEs existentes na rotina

@type  Function
@author Sam
@since 02/08/2018
@version version
/*/
//-------------------------------------------------------------------
User Function SGEOV002()
	Local cMsg := ""
	Local i := 0
	Local aPE  := {}

	AADD(aPE, "M030EXC")
	AADD(aPE, "M030INC")
	AADD(aPE, "M030PALT")
	AADD(aPE, "MA035ALT")
	AADD(aPE, "MA035DEL")
	AADD(aPE, "MA035INC")
	AADD(aPE, "MA040DAL")
	AADD(aPE, "MA040DIN")
	AADD(aPE, "MA050TTS")
	AADD(aPE, "MSD2460")
	AADD(aPE, "MSD2520")
	AADD(aPE, "MT010ALT")
	AADD(aPE, "MT010EXC")
	AADD(aPE, "MT010INC")
	AADD(aPE, "MT020FOPOS")
	AADD(aPE, "MT040DEL")
	AADD(aPE, "MT360GRV")
	AADD(aPE, "PEMAT010")

	cMsg := "Diponibilidade para uso:" + CRLF

	For i := 1 to len(aPE) 
		cMsg += aPE[i] + IIF(ExistBlock(aPE[i]), ": Em uso",": Disponível") + CRLF
	Next i

	MsgInfo(cMsg, "Geosales")
Return 