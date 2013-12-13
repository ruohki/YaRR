''
''
'' pcf8574 -- header translated with help of SWIG FB wrapper
''
'' NOTICE: This file is part of the FreeBASIC Compiler package and can't
''         be included in other distributions without authorization.
''
''
#ifndef __pcf8574_bi__
#define __pcf8574_bi__

declare function pcf8574Setup cdecl alias "pcf8574Setup" (byval pinBase as integer, byval i2cAddress as integer) as integer

#endif
