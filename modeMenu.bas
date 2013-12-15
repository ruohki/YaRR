'---------------------------Deklarationen---------------------------
'Subs
Declare Sub Menu_Encoder_Pressed()
Declare Sub FillMenu()

Declare Sub Menu_Encoder_Rotate()
Declare Sub Menu_Timer_Timer(TimerName as String)
Declare Sub DrawMenu(mnuIndex As Integer)
Declare Sub Dummy_Sub()

'Funktionen
Declare Function LastItem(ID as Integer) as Integer

'---------------------------Typen & Enumeratoren---------------------------
Enum enItemComman
    GotoMenu = 1
    Radio = 2
    Player = 4
    Extras = 8
	ShellCmd = 64
End Enum

Type MenuItem
    Caption As String
    ItemCommand As enItemComman
    ItemData As String
End Type

'---------------------------Variablen---------------------------
Dim Shared As Integer MenuID, ItemID
Dim Shared _Menu(0 To 1, 0 To 9) As MenuItem

'Encoder
Dim Shared _Menu_Encoder_LastState as Integer

'Timer
Dim Shared MenuInputTimer as udtTimer 

'---------------------------Prozeduren---------------------------
Sub Main_Menu()
	Dim retVal as String
	'Interrupts Setzen
	setupencoder(cint(_Conf.ReadValue("Encoder","PinLeft","1")),cint(_Conf.ReadValue("Encoder","PinRight","2")),@Menu_Encoder_Rotate)
	
	'Button des Encoders Belegen
	wiringPiISR(cint(_Conf.ReadValue("Encoder","PinPush","0")),INT_EDGE_FALLING, @Menu_Encoder_Pressed)

	wiringPiISR(cint(_Conf.ReadValue("Button","Button1","5")),INT_EDGE_FALLING, @Dummy_Sub)
	wiringPiISR(cint(_Conf.ReadValue("Button","Button2","3")),INT_EDGE_FALLING, @Dummy_Sub)
	wiringPiISR(cint(_Conf.ReadValue("Button","Button3","4")),INT_EDGE_FALLING, @Dummy_Sub)
		
	'Menu Füllen
	FillMenu
	
	'Timer Initialisieren
	MenuInputTimer = Type<udtTimer>("MenuInputTimer", 500, @Menu_Timer_Timer)


	While WhereAmI = Menu
		'Encoder Lesen
		updateEncoder
		
		'Timer arbeiten lassen
		MenuInputTimer.DoEvents
		Sleep 1
	Wend
End Sub

Sub Dummy_Sub()
	'ISR für die Buttons im Menü hier eine Dummy Prozedur da wir die Buttons im Menü nicht belegen
	
End Sub

'Das Menü auf dem LCD ausgeben
Sub DrawMenu(mnuIndex As Integer)
	Dim ItemDummy As String
    
        lcdPosition (lcdHandle, 0, 0) : lcdPuts (lcdHandle, "Men" & chr(245))
		lcdPosition (lcdHandle, 11, 0) : lcdPuts (lcdHandle, format(Hour(Now),"00") & ":" & format(Minute(Now), "00"))
		
		ItemDummy = Space(16): mid(ItemDummy, 2, 14) = _Menu(mnuIndex,ItemID).Caption
		mid(ItemDummy, 1, 1) = ">": mid(ItemDummy, 16, 1) = "<"
		lcdPosition (lcdHandle, 0, 2) : lcdPuts (lcdHandle, ItemDummy)
			
		If ItemID = 0 then
			ItemDummy = Space(16)
			lcdPosition (lcdHandle, 1, 1) : lcdPuts (lcdHandle, ItemDummy)
			ItemDummy = Space(16): mid(ItemDummy, 1, 14) = _Menu(mnuIndex,ItemID+1).Caption
			lcdPosition (lcdHandle, 1, 3) : lcdPuts (lcdHandle, ItemDummy)
		elseif ItemID >=5 then
			ItemDummy = Space(16): mid(ItemDummy, 1, 14) = _Menu(mnuIndex,ItemID-1).Caption
			lcdPosition (lcdHandle, 1, 1) : lcdPuts (lcdHandle, ItemDummy)
			ItemDummy = Space(16)
			lcdPosition (lcdHandle, 1, 3) : lcdPuts (lcdHandle, ItemDummy)
		else
			ItemDummy = Space(16): mid(ItemDummy, 1, 14) = _Menu(mnuIndex,ItemID-1).Caption
			lcdPosition (lcdHandle, 1, 1) : lcdPuts (lcdHandle, ItemDummy)
			ItemDummy = Space(16): mid(ItemDummy, 1, 14) = _Menu(mnuIndex,ItemID+1).Caption
			lcdPosition (lcdHandle, 1, 3) : lcdPuts (lcdHandle, ItemDummy)
		end if
End Sub

'Menu "Zeiger" updaten
Sub Menu_Timer_Timer(TimerName as String)
	If _Menu_Encoder_LastState < 0 then
		ItemID -= 1
        
        If ItemID < 0 Then ItemID = 0
	elseif _Menu_Encoder_LastState > 0 then
		ItemID += 1
		
		if ItemID > LastItem(MenuID) then
			ItemID -= 1
		end if
	end if
	
	_Menu_Encoder_LastState = 0
	myEncoder.Value = _Menu_Encoder_LastState
	
	DrawMenu(MenuID)
End Sub

'Encoder Rotator
Sub Menu_Encoder_Rotate()
	_Menu_Encoder_LastState = myEncoder.Value
	
End Sub

'Encoder Button
Sub Menu_Encoder_Pressed()
	Select Case _Menu(MenuID, ItemID).ItemCommand
		Case Radio:
			WhereAmI = Radio
			
		case Player:
			WhereAmI = Player
			
		Case GotoMenu:
			MenuID = cint(_Menu(MenuID, ItemID).ItemData)
			ItemID = 0
			lcdClear(lcdHandle)
			DrawMenu(MenuID)
		Case ShellCmd:
		    Dim ret as string
			lcdClear(lcdHandle)
		
			lcdPosition (lcdHandle, 6, 1) : lcdPuts (lcdHandle, "Wird")
			lcdPosition (lcdHandle, 3, 2) : lcdPuts (lcdHandle, "Ausgef" & chr(245) & "hrt")
			
			ret = ExecWithOutput(_Menu(MenuID,ItemID).ItemData)
            Print ret
		
	End Select
End Sub

'Menü "aufbauen"
Sub FillMenu()
    _Menu(0,0).Caption = "WebRadio"
    _Menu(0,0).ItemCommand = Radio
    
	_Menu(0,1).Caption = "MP3-Player"
    _Menu(0,1).ItemCommand = Player
	
    _Menu(0,2).Caption = "Extras"
    _Menu(0,2).ItemCommand = GotoMenu
    _Menu(0,2).ItemData = "1"
	
    _Menu(0,3).Caption = "Einstellungen"
    _Menu(0,3).ItemCommand = GotoMenu
	_Menu(0,3).ItemData = ""
    
    _Menu(0,4).Caption = "Restart"
	_Menu(0,4).ItemCommand = ShellCmd
	_Menu(0,4).ItemData = "shutdown -r now"
	
	_Menu(0,5).Caption = "Standby"
	_Menu(0,5).ItemCommand = ShellCmd
    _Menu(0,5).ItemData = "shutdown -h now"
	
	
	_Menu(1,0).Caption = "Update MPC"
    _Menu(1,0).ItemCommand = ShellCmd
    _Menu(1,0).ItemData = "mpc update"
	
	_Menu(1,1).Caption = "Restart MPD"
    _Menu(1,1).ItemCommand = ShellCmd
    _Menu(1,1).ItemData = "service mpd restart"
	
	_Menu(1,2).Caption = "Punkt3"
    _Menu(1,2).ItemCommand = ShellCmd
    _Menu(1,2).ItemData = ""
	
	_Menu(1,3).Caption = "Punkt4"
    _Menu(1,3).ItemCommand = ShellCmd
    _Menu(1,3).ItemData = ""
	
	_Menu(1,4).Caption = "Punkt5"
    _Menu(1,4).ItemCommand = ShellCmd
    _Menu(1,4).ItemData = ""
	
	
    _Menu(1,5).Caption = "Zur" & chr(245) & "ck"
    _Menu(1,5).ItemCommand = GotoMenu
    _Menu(1,5).ItemData = "0"
End Sub

'---------------------------Funktionen---------------------------
'Elemente im Menü zähle
Function LastItem(mnuIndex as Integer) as Integer
	For i as integer = 0 to 9
		if _Menu(mnuIndex,i).Caption = "" then
			return i -1
			exit function
		end if
	Next i
End Function
