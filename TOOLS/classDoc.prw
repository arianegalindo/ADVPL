#include 'protheus.ch'
#include 'fileio.ch'
#define cr chr(13)+chr(10)

user function classDoc(o, cPath, cClass)
	local cFile
	local aData
	local cPar
	local i,j

	default cPath := 'f:\util\classes\'
	default cClass := ''

	cPath := allTrim(cPath)+if(right(allTrim(cPath),1) <> '\', '\', '')

	if valType(o) == "O" .and. ( !empty(cClass) .or. methIsMemberOf(o,'CLASSNAME') )
		cClass := if(!empty(cClass),cClass,upper(o:className()))
		cFile := cPath + cClass +'.txt' 

		if !file(cFile)
			logg(cFile, "Class " + cClass + cr)

			aData := ClassDataArr(o,.t.)
			if !empty(aData)
				logg(cFile, "Properties")

				for i := 1 to len(aData)
					logg(cFile, chr(9) + beautyVar(aData[i,1]) + if(!empty(aData[i,4]) .and. upper(aData[i,4]) <> cClass,' (inherithed from ' + aData[i,4] + ')', ''))
				next i
				logg(cFile, "")
			endIf

			aData := ClassMethArr(o,.t.)
			if !empty(aData)
				logg(cFile, "Methods")

				for i := 1 to len(aData)
					cPar := ''
					for j := 1 to len(aData[i,2])
						cPar += beautyVar(aData[i,2,j]) + ', '
					next j
					if !empty(cPar)
						cPar := ' ' + left(cPar,len(cPar)-2) + ' '
					endIf

					logg(cFile, chr(9) + aData[i,1] + '(' + cPar + ')' + if(!empty(aData[i,3]) .and. upper(aData[i,3]) <> cClass,' (inherithed from ' + aData[i,3] + ')', ''))
				next i
				logg(cFile, "")
			endIf
		endIf 
	endIf

return


static function logg( cArquivo, cTexto )
	Local nHdl         := 0

	If !File(cArquivo)
		nHdl := FCreate(cArquivo,,,.f.)
	Else
		nHdl := FOpen(cArquivo, FO_READWRITE)
	Endif
	FSeek(nHdl,0,FS_END)
	cTexto += Chr(13)+Chr(10)
	FWrite(nHdl, cTexto, Len(cTexto))
	FClose(nHdl)

Return


static function beautyVar(c)
return lower(subs(c,1,1))+upper(subs(c,2,1))+lower(subs(c,3))