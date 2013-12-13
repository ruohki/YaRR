'Timer.cls
Dim Shared _Timer as Sub(TimerName as String)

Type udtTimer
    Private:
        _Timer_Old as Double

        _TimerName as String

        _TimerCallBack as Any Ptr
        _Interval as Double
		
		
    Public:
		Declare Constructor()
        Declare Constructor(TimerName as String, Interval as Integer, CallBack as Any Ptr)
        Declare Sub DoEvents()
		Declare Sub EnableTimer()
		Declare Sub DisableTimer()
		Declare Sub ResetTimer()
		
		_Enabled as Integer
		
End Type

Constructor udtTimer()
	DisableTimer()
	ResetTimer()
End Constructor

Constructor udtTimer(TimerName as String, TimerInterval as Integer, CallBack as Any Ptr)
    _Interval = TimerInterval / 1000
    _TimerCallBack = CallBack
    _TimerName = TimerName
	_Enabled = 1
	
End Constructor

Sub udtTimer.EnableTimer()
	_Enabled = 1
	
End Sub

Sub udtTimer.DisableTimer()
	_Enabled = 0
	_Timer_Old = 0
End Sub

Sub udtTimer.ResetTimer()
	_Timer_Old = Timer
End Sub

Sub udtTimer.DoEvents()
    If _Enabled = 1 then
		If _Timer_Old = 0 Then
			_Timer_Old = Timer
		End If

		Dim _Timer_Now as Double = Timer

		If _Timer_Now >= _Timer_Old + _Interval Then
			_Timer_Old = Timer

			_Timer = _TimerCallBack
			_Timer(_TimerName)


		End If
	End If
End Sub