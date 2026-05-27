Output demo.gif

Set FontSize 16
Set FontFamily "Cascadia Code"
Set Theme "Dracula"
Set Width 1000
Set Height 600
Set PlaybackSpeed 1.5
Set Padding 20
Set Framerate 30

Sleep 500ms

Type "cls"
Sleep 50ms
Enter
Sleep 200ms

Require pwsh

Type "pwsh -NoLogo"
Sleep 50ms
Enter
Sleep 1500ms

Type "cd $env:USERPROFILE\windows-profile-setup"
Sleep 50ms
Enter
Sleep 800ms

Type "ls"
Sleep 200ms
Enter
Sleep 2000ms

Type "ll"
Sleep 200ms
Enter
Sleep 2000ms

Type "cat README.md --line-range 1:5"
Sleep 200ms
Enter
Sleep 2000ms

Type "git log --oneline -3"
Sleep 200ms
Enter
Sleep 2000ms

Type "which pwsh"
Sleep 200ms
Enter
Sleep 1500ms

Type "exit"
Sleep 50ms
Enter
Sleep 1000ms

Require cmd

Type "cmd"
Sleep 50ms
Enter
Sleep 1000ms

Type "ls %USERPROFILE%\windows-profile-setup"
Sleep 50ms
Enter
Sleep 1500ms

Type "echo --- Aliases are ready! Type ps to launch Starship ---"
Sleep 50ms
Enter
Sleep 1500ms

Type "exit"
Sleep 50ms
Enter
Sleep 500ms

Sleep 1s
