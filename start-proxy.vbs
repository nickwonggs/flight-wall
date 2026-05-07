Dim oShell, strDir
Set oShell = CreateObject("WScript.Shell")
strDir = Left(WScript.ScriptFullName, InStrRev(WScript.ScriptFullName, "\"))

' Check proxy-config.txt exists
Dim oFS
Set oFS = CreateObject("Scripting.FileSystemObject")
If Not oFS.FileExists(strDir & "proxy-config.txt") Then
    MsgBox "proxy-config.txt not found." & vbCrLf & vbCrLf & _
           "Create it in the flight-wall folder with:" & vbCrLf & _
           "Line 1: your OpenSky username" & vbCrLf & _
           "Line 2: your OpenSky password", _
           vbExclamation, "Flight Wall Proxy"
    WScript.Quit
End If

' Kill any existing proxy on port 8888
oShell.Run "cmd /c taskkill /f /fi ""WINDOWTITLE eq FlightWallProxy*"" >nul 2>&1", 0, True

' Start proxy hidden (pythonw = no console window)
oShell.Run "pythonw """ & strDir & "proxy.py""", 0, False

WScript.Sleep 1200

MsgBox "Flight Wall proxy started silently." & vbCrLf & vbCrLf & _
       "Set Proxy URL to: http://localhost:8888" & vbCrLf & _
       "in the Flight Wall settings (gear icon).", _
       vbInformation, "Flight Wall Proxy"
