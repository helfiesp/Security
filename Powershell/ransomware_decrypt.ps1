$users = "IY3S601", "Customer Support" | ForEach-Object {
    
    $userDesk = [Environment]::GetFolderPath("Desktop")
    $directorypath = "C:\Users\$_\Documents"
    $key = Get-Content "C:\Users\$_\Desktop\ransom.key" -Encoding byte
    $AES = New-Object System.Security.Cryptography.AesManaged
    Write-Host "AES Key: $key"
    $AES.Key = $key
    $AES.Padding = [System.Security.Cryptography.PaddingMode]::PKCS7


    Get-ChildItem $directorypath -Recurse -Filter *.enc | ForEach-Object {
        $fullname = $_.FullName
        $bytes = Get-Content "$($_.FullName)" -Encoding byte
        $oriname = "$($_.FullName)" -replace '\.enc$','' 
        $iv = $bytes[0..15]
        $AES.iv = $iv
        Write-Host "IV: $iv"
        $decryptor = $AES.CreateDecryptor()
        $unencryptedData = $decryptor.TransformFinalBlock($bytes, 16, $bytes.Length - 16)
        Set-Content -Value $unencryptedData -LiteralPath $oriname -Encoding byte
        Write-Host (Get-Content $oriname)   
        rm $fullname
    }
    del $directorypath\*.enc
}

Read-Host -Prompt "Press Enter to exit"
