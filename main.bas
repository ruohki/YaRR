'wiringPi
#include "include/wiringPi.bi"
#include "include/pcf8574.bi"

'Rotary Encoder
#include "include/rotaryEncoder.bi"

'LCD Lib
#include "include/lcd.bi"

'Custom Stuff
#include "vbcompat.bi"

'Timer UDT
#include "include/timer.bi"

'Config
#include "include/conf.bi"

'Hauptheader
#include once "include/main.bi"



'Unterprogramme
#include "modeRadio.bas"
#include "modeMenu.bas"
#include "modePlayer.bas"

'---------------------------Deklarationen---------------------------
'Subs
Declare Sub Main()


'---------------------------Programmstart---------------------------
if DebugFlag = True then
	cls
end if

Main()
End

'---------------------------Prozeduren---------------------------
Sub Main()
	Dim retVal as String
	
	_Conf.ReadConf("./radio.conf")
	
	Print "Raspi WiFi Radio"
	
	'wiringPi und den Portexpander Initialisieren
	If wiringPiSetup() = -1 then
		Print "wiringPi Initalisierungsfehler!"
		End
	End If
	
	if pcf8574Setup (100, cint(_Conf.ReadValue("i2c","adresse","34"))) = -1 then
		Print "PCD8574 Initalisierungsfehler!"
		END
	end if
	
	DigitalWrite(cint(_Conf.ReadValue("i2c","pin_bl", "7")) + 100, LOW)
	DigitalWrite(cint(_Conf.ReadValue("i2c","pin_rw", "5")) + 100, LOW)
	
	'LCD Initialisieren
	lcdHandle = lcdInit(4,20,4,cint(_Conf.ReadValue("i2c","pin_rs","4")) + 100,cint(_Conf.ReadValue("i2c","pin_strb","6")) + 100, _
					cint(_Conf.ReadValue("i2c","pin_db4", "0")) + 100, _
					cint(_Conf.ReadValue("i2c","pin_db5", "1")) + 100, _
					cint(_Conf.ReadValue("i2c","pin_db6", "2")) + 100, _
					cint(_Conf.ReadValue("i2c","pin_db7", "3")) + 100, 0, 0, 0, 0)
	
	lcdHome (lcdHandle)
    lcdClear (lcdHandle)
	lcdDisplay(lcdHandle, 1)

	lcdCursor(lcdHandle, 0)
	lcdCursorBlink(lcdHandle, 0)
	
	'Benutzerdefinierte Symbole in den LCD Speicher Schreiben
	lcdCharDef(lcdHandle, Icon_Play, @customChar1(0))
	lcdCharDef(lcdHandle, Icon_Pause, @customChar2(0))
	lcdCharDef(lcdHandle, Icon_Prev, @customChar3(0))
	lcdCharDef(lcdHandle, Icon_Next, @customChar4(0))
	lcdCharDef(lcdHandle, Icon_Enter, @customChar5(0))
	lcdCharDef(lcdHandle, Icon_Volume, @customChar6(0))
	
	'"Splash" Screen
	lcdPosition (lcdHandle, 0, 0) : lcdPuts (lcdHandle, format(Hour(Now),"00") & ":" & format(Minute(Now), "00"))
	lcdPosition (lcdHandle, 12, 0) : lcdPuts (lcdHandle, "v0.3")
	lcdPosition (lcdHandle, 0, 1) : lcdPuts (lcdHandle, "Raspberry Radio")
	lcdPosition (lcdHandle, 0, 2) : lcdPuts (lcdHandle, "   Startet...")
	Sleep 2000
	
	'MPC Setup
	retVal = ExecWithOutput("mpc repeat on")
	
	lcdClear(lcdHandle)
	
	'Mainloop
	While ExitFlag <> True
		Select Case WhereAmI
			case Radio:
				lcdClear(lcdHandle)
				Main_Radio
			case Menu:
				lcdClear(lcdHandle)
				Main_Menu
			case Player:
				lcdClear(lcdHandle)
				Main_Player
		end select
		
		Sleep 1
	Wend
	
End SuB






'---------------------------Funktionen---------------------------

