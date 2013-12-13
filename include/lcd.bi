''
''
'' lcd -- header translated with help of SWIG FB wrapper
''
'' NOTICE: This file is part of the FreeBASIC Compiler package and can't
''         be included in other distributions without authorization.
''
''
#ifndef __lcd_bi__
#define __lcd_bi__

#define MAX_LCDS 8

declare sub lcdHome cdecl alias "lcdHome" (byval fd as integer)
declare sub lcdClear cdecl alias "lcdClear" (byval fd as integer)
declare sub lcdDisplay cdecl alias "lcdDisplay" (byval fd as integer, byval state as integer)
declare sub lcdCursor cdecl alias "lcdCursor" (byval fd as integer, byval state as integer)
declare sub lcdCursorBlink cdecl alias "lcdCursorBlink" (byval fd as integer, byval state as integer)
declare sub lcdSendCommand cdecl alias "lcdSendCommand" (byval fd as integer, byval command as ubyte)
declare sub lcdPositionO cdecl alias "lcdPosition" (byval fd as integer, byval x as integer, byval y as integer)
declare sub lcdCharDef cdecl alias "lcdCharDef" (byval fd as integer, byval index as integer, byval data as ubyte ptr)
declare sub lcdPutchar cdecl alias "lcdPutchar" (byval fd as integer, byval data as ubyte)
declare sub lcdPutsO cdecl alias "lcdPuts" (byval fd as integer, byval string as zstring ptr)
declare sub lcdPrintf cdecl alias "lcdPrintf" (byval fd as integer, byval message as zstring ptr, ...)
declare function lcdInit cdecl alias "lcdInit" (byval rows as integer, byval cols as integer, byval bits as integer, byval rs as integer, byval strb as integer, byval d0 as integer, byval d1 as integer, byval d2 as integer, byval d3 as integer, byval d4 as integer, byval d5 as integer, byval d6 as integer, byval d7 as integer) as integer

#endif