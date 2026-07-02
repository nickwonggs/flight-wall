' Double-click to start the Flight Wall proxy silently on Windows.
' No console window appears (pythonw). Photos work without credentials;
' add OpenSky credentials to proxy-config.txt for higher rate limits.
Dim oShell, strDir, oFS
Set oShell = CreateObject("WScript.Shell")
Set oFS = CreateObject("Scripting.FileSystemObject")
strDir = Left(WScript.ScriptFullName, InStrRev(WScript.ScriptFullName, "\"))

Dim proxyPort
proxyPort = "8765"

' Kill any existing proxy listening on the proxy port (by PID from netstat),
' so an updated proxy.py actually takes over. Killing by window title does
' not work for pythonw (it has no window).
oShell.Run "cmd /c for /f ""tokens=5"" %a in ('netstat -aon ^| findstr "":" & proxyPort & " "" ^| findstr LISTENING') do taskkill /f /pid %a >nul 2>&1", 0, True

' Start proxy hidden (pythonw = no console window)
oShell.Run "pythonw """ & strDir & "proxy.py""", 0, False

WScript.Sleep 1500

Dim msg
msg = "Flight Wall proxy started on http://localhost:" & proxyPort & vbCrLf & vbCrLf
If oFS.FileExists(strDir & "proxy-config.txt") Then
    msg = msg & "OpenSky credentials loaded (authenticated mode)." & vbCrLf & vbCrLf
Else
    msg = msg & "Running in anonymous mode — aircraft photos will work." & vbCrLf & _
          "Run setup.bat to add OpenSky credentials for higher rate limits." & vbCrLf & vbCrLf
End If
msg = msg & "In Flight Wall, photos auto-connect to the proxy — no settings" & vbCrLf & _
      "change needed. (Advanced: Proxy URL is http://localhost:" & proxyPort & ")"

MsgBox msg, vbInformation, "Flight Wall Proxy"
