'Unterprogramm zum Wiedergeben der lokalen Musikdateien

'---------------------------Deklarationen---------------------------
'Subs
Declare Sub Radio_UpdateLCD()
Declare Sub Radio_Timer_Timer(TimerName as String)

'ISR's
Declare Sub Radio_Encoder_Rotate()
Declare Sub Radio_Encoder_Pressed()
Declare Sub Radio_Button1_Pressed()
Declare Sub Radio_Button2_Pressed()
Declare Sub Radio_Button3_Pressed()

'---------------------------Variablen---------------------------
'Timer
Dim Shared _Radio_LCDUpdate as udtTimer 
Dim Shared _Radio_MPCUpdate as udtTimer 

'Player Variablen
Dim Shared _Radio_Title as String 
Dim Shared _Radio_Title_Scroll as Integer = 0
Dim Shared _Radio_Status as Integer = Playing

'Dim Shared _Radio_Time as String
'Encoder Variable
Dim Shared _Radio_Encoder_LastState as integer = 42

Sub Main_Radio()
	Dim retVal as String
	'Interrupts Setzen
	'Encoder
	setupencoder(1,2,@Radio_Encoder_Rotate)
	
	'Button des Encoders Belegen
	wiringPiISR(0,INT_EDGE_FALLING, @Radio_Encoder_Pressed)
	'Back Button
	wiringPiISR(5,INT_EDGE_FALLING, @Radio_Button1_Pressed)
	'Next Button
	wiringPiISR(3,INT_EDGE_FALLING, @Radio_Button3_Pressed)
	
	'Lichtbutton TODO
	wiringPiISR(4,INT_EDGE_FALLING, @Radio_Button2_Pressed)

	'Wenn wir aus dem Menü kommen und vorher nicht im Radiomodus waren
	'MPC zur Stream wiedergabe initialisieren	
	if not WhereWasI = Radio then
		retVal = ExecWithOutput("mpc clear && mpc load WebRadio && mpc play")
	end if
	
	'Flag zu --^
	WhereWasI = Radio
		
	'Timer Ininitalisieren
	_Radio_LCDUpdate = Type<udtTimer>("LCDUpdate", 500, @Radio_Timer_Timer)
	_Radio_MPCUpdate = Type<udtTimer>("MPCUpdate", 1000, @Radio_Timer_Timer)
	
	retVal = ExecWithOutput("mpc volume " & _Volume)
	
	myEncoder.value = _Volume
	
	Do 
		'Timer Arbeiten Lassen
		_Radio_LCDUpdate.DoEvents
		_Radio_MPCUpdate.DoEvents

		'Encoder Updaten
		updateEncoder
		
		'CPU Auslastung Senken
		Sleep 1
	Loop Until (not WhereAmI = Radio)
End Sub

Sub Radio_Timer_Timer(TimerName as String)
	Dim retVal as String

	Select Case TimerName
		Case "MPCUpdate":
			retVal = ExecWithOutput("mpc current")
			if retVal <> _Radio_Title then
				_Radio_Title = retVal
				_Radio_Title_Scroll = 0
			end if
			
			retVal = ExecWithOutput("mpc -f %time%")
			
			lcdPosition (lcdHandle, 1, 0) : lcdPuts (lcdHandle, StripOutTime(retVal))
		Case "LCDUpdate":
			_Radio_Title_Scroll += 1
			if _Radio_Title_Scroll > len(_Radio_Title) then
				_Radio_Title_Scroll = 0
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
			
			Radio_UpdateLCD
	End Select
End Sub

Sub Radio_UpdateLCD()
	Dim CharToPut as Integer
	
	'Manchmal gibts Expetions die wir nicht brauchen ;)
	On error goto Ende_Radio_UpdateLCD
	select Case _Radio_Status
		Case Playing
			lcdPosition (lcdHandle, 0, 0) : lcdPutchar (lcdHandle, Icon_Play)
			CharToPut = Icon_Pause
		Case Stopped
			lcdPosition (lcdHandle, 0, 0) : lcdPutchar (lcdHandle, Icon_Pause)
			CharToPut = Icon_Play
	End Select
	
	lcdPosition (lcdHandle, 11, 0) : lcdPuts (lcdHandle, format(Hour(Now),"00") & ":" & format(Minute(Now), "00"))
	lcdPosition (lcdHandle, 0, 1) : lcdPuts (lcdHandle, mid(_Radio_Title & " " & _Radio_Title & " " & _Radio_Title, _Radio_Title_Scroll, 16))
	lcdPosition (lcdHandle, 0, 3) : lcdPuts (lcdHandle, chr(Icon_Prev) & " " & chr(CharToPut) & " " & chr(Icon_Next) & Space(8) & chr(Icon_Volume) & "/" & chr(Icon_Enter))
	
	Ende_Radio_UpdateLCD:
End Sub

Sub Radio_Encoder_Rotate
	Dim encoderVal as Integer = myEncoder.Value 

	if _Radio_Encoder_LastState <> encoderVal then
		_Radio_Encoder_LastState = encoderVal
				
		if _Radio_Encoder_LastState > 100 then
			_Radio_Encoder_LastState = 100
		elseif _Radio_Encoder_LastState < 50 then
			_Radio_Encoder_LastState = 50
		end if
				
		myEncoder.Value = _Radio_Encoder_LastState
		_Volume = _Radio_Encoder_LastState
		_Volume_Changed = True
	end if
	
End Sub

Sub Radio_Encoder_Pressed
	WhereAmI = Menu

	'Timer vernichten
	_Radio_LCDUpdate.Destructor
	_Radio_MPCUpdate.Destructor

End Sub

Sub Radio_Button1_Pressed
	Dim retVal as String

	retVal = ExecWithOutput("mpc prev")
End Sub

Sub Radio_Button2_Pressed
	Dim retVal as String
	
	if _Radio_Status = Playing Then
		_Radio_Status = Stopped
		retVal = ExecWithOutput("mpc pause")
	elseif _Radio_Status = Stopped then
		_Radio_Status = Playing
		retVal = ExecWithOutput("mpc play")
	end if
End Sub

Sub Radio_Button3_Pressed
	Dim retVal as String

	retVal = ExecWithOutput("mpc next")
End Sub
