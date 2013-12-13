'Unterprogramm zum Wiedergeben der lokalen Musikdateien

'---------------------------Deklarationen---------------------------
'Subs
Declare Sub Player_UpdateLCD()
Declare Sub Player_Timer_Timer(TimerName as String)

'ISR's
Declare Sub Player_Encoder_Rotate()
Declare Sub Player_Encoder_Pressed()
Declare Sub Player_Button1_Pressed()
Declare Sub Player_Button2_Pressed()
Declare Sub Player_Button3_Pressed()

'---------------------------Variablen---------------------------
'Timer
Dim Shared _Player_LCDUpdate as udtTimer 
Dim Shared _Player_MPCUpdate as udtTimer 

'Player Variablen
Dim Shared _Player_Title as String 
Dim Shared _Player_Title_Scroll as Integer = 0
Dim Shared _Player_Status as Integer = Playing


'Encoder Variable
Dim Shared _Player_Encoder_LastState as integer = 42

Sub Main_Player()
	Dim retVal as String
	'Interrupts Setzen
	'Encoder
	setupencoder(1,2,@Player_Encoder_Rotate)
	
	'Button des Encoders Belegen
	wiringPiISR(0,INT_EDGE_FALLING, @Player_Encoder_Pressed)
	'Back Button
	wiringPiISR(5,INT_EDGE_FALLING, @Player_Button1_Pressed)
	'Next Button
	wiringPiISR(3,INT_EDGE_FALLING, @Player_Button3_Pressed)
	
	'Lichtbutton. TODO
	wiringPiISR(4,INT_EDGE_FALLING, @Player_Button2_Pressed)
	
	'Wenn wir aus dem Menü kommen und vorher nicht im Playermodus waren
	'MPC zur lokalen wiedergabe initialisieren
	if not WhereWasI = Player then
		retVal = ExecWithOutput("mpc clear && mpc listall | mpc add && mpc play")
	end if
	
	'Flag  zu --^
	WhereWasI = Player
	
	'Timer Ininitalisieren
	_Player_LCDUpdate = Type<udtTimer>("LCDUpdate", 500, @Player_Timer_Timer)
	_Player_MPCUpdate = Type<udtTimer>("MPCUpdate", 1000, @Player_Timer_Timer)
	
	'Lautstärke Setzen
	retVal = ExecWithOutput("mpc volume " & _Volume)
	myEncoder.value = _Volume
	
	Do 
		'Timer Arbeiten Lassen
		_Player_LCDUpdate.DoEvents
		_Player_MPCUpdate.DoEvents

		'Encoder Updaten
		updateEncoder
		
		'CPU Auslastung Senken
		Sleep 1
	Loop Until (not WhereAmI = Player)
End Sub

Sub Player_Timer_Timer(TimerName as String)
	Dim retVal as String

	Select Case TimerName
		Case "MPCUpdate":
			retVal = ExecWithOutput("mpc current")
			if not retVal = _Player_Title then
				_Player_Title = retVal
				_Player_Title_Scroll = 1
			end if

			retVal = ExecWithOutput("mpc -f %time%")
			
			lcdPosition (lcdHandle, 1, 0) : lcdPuts (lcdHandle, StripOutWholeTime(retVal))
		Case "LCDUpdate":
			_Player_Title_Scroll += 1
			if _Player_Title_Scroll = len(_Player_Title) then
				_Player_Title_Scroll = 1
			end if
			
			if _Volume_Changed = true then
				retVal = ExecWithOutput("mpc volume " & _Volume)
				_Volume_Changed = false
			end if
			
			Dim as Integer Dummy, i
			Dim as String strDummy = Space(10)
			
			Dummy = (_Volume - 50) * 2
			for i = 0 to Dummy / 10
				mid(strDummy, i,1) = chr(255)
				
			next i
			
			if Dummy < 100 then
				mid(strDummy, 5,3) = format(Dummy, "00")  & "%"
			else
				mid(strDummy, 4,4) = format(Dummy, "000") & "%" 
			end if
				
			lcdPosition (lcdHandle, 0, 2) : lcdPuts (lcdHandle, "Vol:[" & strDummy & "]")
				
			Player_UpdateLCD
	End Select
End Sub

Sub Player_UpdateLCD()
	Dim CharToPut as Integer
	
	'Manchmal gibts Expetions die wir nicht brauchen ;)
	On Error Goto Ende_Player_UpdateLCD
	select Case _Player_Status
		Case Playing
			lcdPosition (lcdHandle, 0, 0) : lcdPutchar (lcdHandle, Icon_Play)
			CharToPut = Icon_Pause
		Case Stopped
			lcdPosition (lcdHandle, 0, 0) : lcdPutchar (lcdHandle, Icon_Pause)
			CharToPut = Icon_Play
	End Select
			
	lcdPosition (lcdHandle, 11, 0) : lcdPuts (lcdHandle, format(Hour(Now),"00") & ":" & format(Minute(Now), "00"))
	lcdPosition (lcdHandle, 0, 1) : lcdPuts (lcdHandle, mid(_Player_Title & " " &  _Player_Title & " " &  _Player_Title, _Player_Title_Scroll, 16))
	lcdPosition (lcdHandle, 0, 3) : lcdPuts (lcdHandle, chr(Icon_Prev) & " " & chr(CharToPut) & " " & chr(Icon_Next) & Space(8) & chr(Icon_Volume) & "/" & chr(Icon_Enter))
	
	Ende_Player_UpdateLCD:
End Sub

Sub Player_Encoder_Rotate
	Dim encoderVal as Integer = myEncoder.Value 

	if _Player_Encoder_LastState <> encoderVal then
		_Player_Encoder_LastState = encoderVal
				
		if _Player_Encoder_LastState > 100 then
			_Player_Encoder_LastState = 100
		elseif _Player_Encoder_LastState < 50 then
			_Player_Encoder_LastState = 50
		end if
				
		myEncoder.Value = _Player_Encoder_LastState
		_Volume = _Player_Encoder_LastState
		_Volume_Changed = True
	end if
	
End Sub

Sub Player_Encoder_Pressed
	WhereAmI = Menu

	'Timer vernichten
	_Player_LCDUpdate.Destructor
	_Player_MPCUpdate.Destructor

End Sub

Sub Player_Button1_Pressed
	Dim retVal as String

	retVal = ExecWithOutput("mpc prev")
End Sub

Sub Player_Button2_Pressed
	Dim retVal as String
	
	if _Player_Status = Playing Then
		_Player_Status = Stopped
		retVal = ExecWithOutput("mpc pause")
	elseif _Player_Status = Stopped then
		_Player_Status = Playing
		retVal = ExecWithOutput("mpc play")
	end if
End Sub

Sub Player_Button3_Pressed
	Dim retVal as String

	retVal = ExecWithOutput("mpc next")
End Sub
