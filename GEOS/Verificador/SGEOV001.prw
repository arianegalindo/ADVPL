#Include 'Protheus.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} SGEOV001()

Verifica os menus existentes na rotina

@type  Function
@author Sam
@since 02/08/2018
@version version
/*/
//-------------------------------------------------------------------
User Function SGEOV001()
    Local cRootPath := GetSrvProfString("RootPath", "\undefined")
    Local cStartPath := GetSrvProfString("StartPath", "\undefined")

    Local cPath := ""
    Local cMsg := ""

    Local i := 0

    Local aFileEsp  := {}
    Local aMenuEsp  := {}

    AADD(aFileEsp, "sigaesp.xnu")
    AADD(aFileEsp, "sigaesp1.xnu")
    AADD(aFileEsp, "sigaesp2.xnu")

    AADD(aMenuEsp, "SIGAESP")
    AADD(aMenuEsp, "SIGA1ESP")
    AADD(aMenuEsp, "SIGA2ESP")

    cMsg := "Diponibilidade para uso:" + CRLF

    For i := 1 to len(aFileEsp) 
        cPath := cRootPath + cStartPath + aFileEsp[i]
        cMsg += aMenuEsp[i] + IIF(File(cPath), ": Em uso",": Disponível") + CRLF
    Next i

    MsgInfo(cMsg, "Geosales")
Return 