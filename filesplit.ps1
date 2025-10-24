function Join-BinaryFilesInDirectory {
    param (
        [string]$directory,
        [bool]$Recurse = $false,
        [switch]$DryRun
    )
    $files = Get-ChildItem -Path $directory -Filter '*.1' -File -Recurse:$Recurse
    foreach ($file in $files) {
        $baseFile = $file.FullName -replace '\.1$',''
        if (Test-Path "$baseFile.1") {
            if ($DryRun) {
                Write-Host "[DryRun] Would reassemble $baseFile from chunks"
            } else {
                Write-Host "Reassembling $baseFile from chunks"
                Join-BinaryFiles -outputFile $baseFile
            }
        }
    }
}

# Usage: Split-BinaryFile -inputFile "largefile.bin" -outputPrefix "chunk_" -chunkSizeMB 100
function Split-BinaryFile {
   param (
       [string]$inputFile,
       [int]$chunkSizeMB = 40
   )
   $chunkSizeBytes = $chunkSizeMB * 1MB
   $fileStream = [System.IO.File]::OpenRead($inputFile)
   $buffer = New-Object byte[] $chunkSizeBytes
   $chunkNumber = 1
   while ($bytesRead = $fileStream.Read($buffer, 0, $chunkSizeBytes)) {
       $outputFile = "${inputFile}.${chunkNumber}"
       $outputStream = [System.IO.File]::OpenWrite($outputFile)
       $outputStream.Write($buffer, 0, $bytesRead)
       $outputStream.Close()
       Write-Host "Wrote $outputFile"
       $chunkNumber++
   }
   $fileStream.Close()
}

# Usage: Join-BinaryFiles -outputFile "combinedfile.bin"
function Join-BinaryFiles {
   param (
       [string]$outputFile
   )
   $outputStream = [System.IO.File]::OpenWrite($outputFile)
   $chunkNumber = 1
   $bufferSize = 4MB
   $buffer = New-Object byte[] $bufferSize
   while (Test-Path "${outputFile}.${chunkNumber}") {
       $inputFile = "${outputFile}.${chunkNumber}"
       $inputStream = [System.IO.File]::OpenRead($inputFile)
       while (($bytesRead = $inputStream.Read($buffer, 0, $bufferSize)) -gt 0) {
           $outputStream.Write($buffer, 0, $bytesRead)
       }
       $inputStream.Close()
       Write-Host "Read $inputFile"
       $chunkNumber++
   }
   $outputStream.Close()
}

# Usage: Split-BinaryFilesInDirectory -directory "C:\path" -chunkSizeMB 40 -Recurse $true
function Split-BinaryFilesInDirectory {
    param (
        [string]$directory,
        [int]$chunkSizeMB = 40,
        [bool]$Recurse = $false,
        [switch]$DryRun,
        [bool]$RenameSourceToBak = $true
    )
    $files = Get-ChildItem -Path $directory -File -Recurse:$Recurse
    foreach ($file in $files) {
        $fileSize = $file.Length
        $chunkSizeBytes = $chunkSizeMB * 1MB
        if ($fileSize -gt $chunkSizeBytes) {
            if ($DryRun) {
                Write-Host "[DryRun] Would split $($file.FullName) ($fileSize bytes)"
                if ($RenameSourceToBak) {
                    Write-Host "[DryRun] Would rename $($file.FullName) to $($file.FullName).bak"
                }
            } else {
                Write-Host "Splitting $($file.FullName) ($fileSize bytes)"
                Split-BinaryFile -inputFile $file.FullName -chunkSizeMB $chunkSizeMB
                if ($RenameSourceToBak) {
                    $bakName = "$($file.FullName).bak"
                    Rename-Item -Path $file.FullName -NewName $bakName
                    Write-Host "Renamed $($file.FullName) to $bakName"
                }
            }
        }
    }
}
