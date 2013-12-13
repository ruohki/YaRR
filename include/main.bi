'---------------------------Konstanten---------------------------
'Boolean
Const True = 1
Const False = 0

'Playerzustand
Const Stopped = 0
Const Playing = 1

'Wobinich Flag
Const Radio = 0
Const Menu = 1
Const Player = 2

'DebugFlag
Const DebugFlag = Not True

'---------------------------Custom Chars---------------------------
Dim shared customChar1(7) as ubyte = {&h0, &h8, &hc, &he, &hc, &h8, &h0, &h0}
Dim shared customChar2(7) as ubyte = {&h0, &ha, &ha, &ha, &ha, &ha, &h0, &h0}
Dim shared customChar3(7) as ubyte = {&h0, &h11, &h19, &h1d, &h19, &h11, &h0, &h0}
Dim shared customChar4(7) as ubyte = {&h0, &h11, &h19, &h1d, &h19, &h11, &h0, &h0}
Dim shared customChar5(7) as ubyte = {&h0, &h0, &h1, &h9, &h1f, &h8, &h0, &h0}
DIm shared customChar6(7) as ubyte = {&h0, &h1, &h3, &h7, &hf, &h1f, &h0}

Const Icon_Play = &h0
Const Icon_Pause = &h1
Const Icon_Prev = &h2
Const Icon_Next = &h3
Const Icon_Enter = &h4
Const Icon_Volume = &h5

'---------------------------Variablen---------------------------
'Koordination
Dim Shared ExitFlag as Byte = False
Dim Shared WhereAmI as Integer = Menu
Dim Shared WhereWasI as Integer = Menu 'Ja ich weis das es WhereIveBeen heiﬂt

'Globale Volume Vars
Dim Shared _Volume as Integer = 90
Dim Shared _Volume_Changed as integer = false

'LCD Handle
Dim Shared lcdHandle as integer

'---------------------------Deklarationen---------------------------
'Subs
Declare Sub Main_Radio()
Declare Sub Main_Menu()
Declare Sub Main_Player()

declare sub lcdPuts (byval fd as integer, byval string as zstring ptr)
declare sub lcdPosition (byval fd as integer, byval x as integer, byval y as integer)

'Funktionen
Declare Function ExecWithOutput(strCommand as String) as String
Declare Function StripOutTime(searchString as String) as String
Declare Function StripOutWholeTime(searchString as String) as String

'---------------------------Prozeduren---------------------------
'Debug Stuff
sub lcdPosition (byval fd as integer, byval x as integer, byval y as integer)
	if DebugFlag = True then
		locate y +1, x + 1
	end if
	lcdPositionO(fd, x, y)
end sub

sub lcdPuts (byval fd as integer, byval stringtopr as zstring ptr)
	if DebugFlag = True then
		print(*stringtopr)
	end if
	lcdPutsO(fd, stringtopr)
end sub

'---------------------------Funktionen---------------------------
'Output: 1:20
Function StripOutTime(searchString as String) as String
    Dim Wert1 as Integer = instr(instr(searchString, "/") , searchString, " ")
    Dim Wert2 as Integer = instr(Wert1, searchString, "/")
    
    While (instr(Wert1, mid(searchString,1, Wert2), " ") <> 0) AND (Wert1 < len(SearchString))
        Wert1 += 1
    Wend 
    
    return mid(searchString, Wert1, Wert2 - Wert1)
End Function

'Output: 1:20/2:30
Function StripOutWholeTime(searchString as String) as String
    Dim Wert1 as Integer = instr(instr(searchString, "/") , searchString, " ")
    Dim Wert2 as Integer = instr(Wert1, searchString, " (")
    
    While (instr(Wert1, mid(searchString,1, Wert2 - 1), " ") <> 0) AND (Wert1 < len(SearchString))
        Wert1 += 1
    Wend 
    
    return mid(searchString, Wert1, Wert2 - Wert1)
End Function

'Piped Shell Command
Function ExecWithOutput(strCommand as String) as String
	Dim as String Dummy, s
	DIM AS INTEGER nr = FREEFILE
	
	OPEN PIPE strCommand FOR INPUT AS #nr

	DO UNTIL EOF(nr)
	   LINE INPUT #nr, s
	   Dummy &= s
	LOOP
	CLOSE #nr
	
	sleep 100
	return Dummy
End Function
