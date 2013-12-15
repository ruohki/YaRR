'Conf Modul
Const MAX_SECTIONS = 10
Const MAX_ELEMENTS = 10

Type _Node
	_Name As String
	_Value As String
End Type

Type _Section
	_Name As String
	_Elements As Integer = -1 
	_Nodes(MAX_ELEMENTS) As _Node
End Type

Type ConfigurationManager
	Private:
		_Sections(MAX_SECTIONS) As _Section
		
		_Elements As Integer = -1 
		
	Public:
		Declare Sub ReadConf(Filename As String)
		Declare Sub WriteConf(Filename As String)
		
		Declare Sub WriteValue(Section As String, KeyName As String, KeyValue As String)
		Declare Function ReadValue(Section As String, KeyName As String, DefaultValue As String = Chr(0) & Chr(255)) As String
End Type

Sub ConfigurationManager.ReadConf(Filename As String)
	Dim _Lines() As String
	Dim _FileNr As Integer = FreeFile
	
	Dim As String CurrentLine, DummyA, DummyB
	Dim As Integer DummyC, DummyD
	
	Dim ActiveSec As Integer = -1
	Dim ActiveEle As Integer = -1
	
	Open Filename For Input As #_FileNr
		Do Until Eof(_FileNr)
				ReDim Preserve _Lines(UBound(_Lines)+1)
				Line Input #_FileNr, _Lines( UBound (_Lines))
				
				_Lines( UBound (_Lines)) = RTrim(LTrim(_Lines(UBound (_Lines)),any "	 "),any "	 ")
		Loop
	Close #_FileNr
	

	For i As Integer = 0 To UBound(_Lines)
		CurrentLine = _Lines(i)
		
		
		If Mid(CurrentLine,1,1) = "[" Then
			ActiveSec += 1
			_Elements = ActiveSec 
			ActiveEle = -1
		
			DummyC = InStr(CurrentLine, "]")
			DummyA = Mid(CurrentLine, 2, DummyC - 2)
			
			_Sections(ActiveSec)._Name = DummyA
			
		ElseIf (ActiveSec > -1) And (InStr(CurrentLine, "=") > 0) Then
			ActiveEle += 1
			DummyA = Mid(CurrentLine, 1, InStr(CurrentLine, "=") - 1)
			DummyB = Mid(CurrentLine, InStr(CurrentLine, "=") + 1, Len(CurrentLine) - InStr(CurrentLine, "="))
			_Sections(ActiveSec)._Nodes(ActiveEle)._Name = DummyA
			_Sections(ActiveSec)._Nodes(ActiveEle)._Value = DummyB
			
			_Sections(ActiveSec)._Elements = ActiveEle
		End If
	Next 
End Sub

Sub ConfigurationManager.WriteConf(Filename As String)
	Dim _FileNr As Integer = FreeFile
	Dim As Integer _Is, _Ie
	
	Open Filename For Output As #_FileNr
		For _Is = 0 To _Elements 
			Print #1 , "[" & _Sections(_Is)._Name & "]"
			For _Ie = 0 To _Sections(_Is)._Elements 
				Print #1 , _Sections(_Is)._Nodes(_Ie)._Name & "=" & _Sections(_Is)._Nodes(_Ie)._Value
			Next
			Print #1 , ""
		Next
	Close #_FileNr
End Sub

Function ConfigurationManager.ReadValue(Section As String, KeyName As String, DefaultValue As String = Chr(0) & Chr(255)) As String
	Dim As Integer _Is, _Ie
	Dim ReturnCode As String
	
	For _Is = 0 To _Elements
		If LCase(_Sections(_Is)._Name) = LCase(Section) Then
			For _Ie = 0 To _Sections(_Is)._Elements
				If LCase(_Sections(_Is)._Nodes(_Ie)._Name) = LCase(KeyName) Then
					Return _Sections(_Is)._Nodes(_Ie)._Value
					Exit function
				EndIf
			Next
			
			ReturnCode = Chr(255)
		EndIf
	Next
	
	If Not DefaultValue = Chr(0) & Chr(255) Then
		Return DefaultValue
		Exit Function
	EndIf
	
	If ReturnCode = Chr(255) Then
		Return ReturnCode
	Else
		Return Chr(0)
	End If
End Function

Sub ConfigurationManager.WriteValue(Section As String, KeyName As String, KeyValue As String)
	Dim As Integer _Is, _Ie
	
	Select case ReadValue(Section,KeyName)
		Case Chr(255):
			For _Is = 0 To _Elements
				If LCase(_Sections(_Is)._Name) = LCase(Section) Then
					_Sections(_Is)._Elements += 1
					_Sections(_Is)._Nodes(_Sections(_Is)._Elements)._Name = KeyName
					_Sections(_Is)._Nodes(_Sections(_Is)._Elements)._Value = KeyValue
				End If
			Next
		Case Chr(0):
			_Elements += 1
			_Sections(_Elements)._Elements = 0
			_Sections(_Elements)._Name = Section
			_Sections(_Elements)._Nodes(0)._Name = KeyName
			_Sections(_Elements)._Nodes(0)._Value = KeyValue
		Case Else:
			For _Is = 0 To _Elements
				If LCase(_Sections(_Is)._Name) = LCase(Section) Then
					For _Ie = 0 To _Sections(_Is)._Elements
						If LCase(_Sections(_Is)._Nodes(_Ie)._Name) = LCase(KeyName) Then
							_Sections(_Is)._Nodes(_Ie)._Name = KeyName
							_Sections(_Is)._Nodes(_Ie)._Value = KeyValue
						EndIf
					Next
				End If
			Next
	End Select
End Sub


	