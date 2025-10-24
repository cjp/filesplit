# filesplit.ps1

Simple PowerShell functions for efficiently splitting and joining large binary
files using streaming and buffers.

## Features
- Split any large binary file into smaller chunks.
- Join split chunks back into the original file.
- Batch split or join files in a directory (optionally recursively).

## Function Documentation

### Split-BinaryFile
Splits a single binary file into chunks of a specified size.

**Parameters:**
- `-inputFile <string>`: Path to the file to split.
- `-chunkSizeMB <int>`: Size of each chunk in megabytes (default: 40).

**Usage:**
```powershell
Split-BinaryFile -inputFile "largefile.bin" -chunkSizeMB 20
```
Output files will be named as `largefile.bin.1`, `largefile.bin.2`, etc.

---

### Join-BinaryFiles
Joins previously split chunks into a single file using streaming (no full file
loaded in RAM).

**Parameters:**
- `-outputFile <string>`: The name of the reassembled file.

**Usage:**
```powershell
Join-BinaryFiles -outputFile "largefile.bin"
```
Reads files named `largefile.bin.1`, `largefile.bin.2`, etc., and combines them
into `largefile.bin`.

---

### Split-BinaryFilesInDirectory

Splits all files in a directory (optionally recursively) that are larger than
the specified chunk size.

Supports a `-DryRun` switch to preview actions without making changes.

**Parameters:**
- `-directory <string>`: Path to the directory to scan for large files.
- `-chunkSizeMB <int>`: Size threshold for splitting (default: 40).
- `-Recurse <bool>`: Whether to process subdirectories (default: `$false`).
- `-DryRun`: If specified, only prints which files would be split and renamed.
- `-RenameSourceToBak <bool>`: If `$true` (default), renames the source file to `.bak` after splitting. Set to `$false` to disable.

**Usage:**
```powershell
# Perform actual split and rename source files to .bak
Split-BinaryFilesInDirectory -directory "C:\path\to\folder" -chunkSizeMB 40 -Recurse $true
# Split but do NOT rename source files
Split-BinaryFilesInDirectory -directory "C:\path\to\folder" -chunkSizeMB 40 -Recurse $true -RenameSourceToBak $false
# Preview only (dry run, shows split and rename actions)
Split-BinaryFilesInDirectory -directory "C:\path\to\folder" -chunkSizeMB 40 -Recurse $true -DryRun
```

---

### Join-BinaryFilesInDirectory

Joins all split files in a directory (optionally recursively) by looking for
files ending in `.1` and reassembling them.

Supports a `-DryRun` switch to preview actions without making changes.

**Parameters:**
- `-directory <string>`: Path to the directory to scan for split files.
- `-Recurse <bool>`: Whether to process subdirectories (default: `$false`).
- `-DryRun`: If specified, only prints which files would be reassembled.

**Usage:**
```powershell
# Perform actual join
Join-BinaryFilesInDirectory -directory "C:\path\to\folder" -Recurse $true
# Preview only (dry run)
Join-BinaryFilesInDirectory -directory "C:\path\to\folder" -Recurse $true -DryRun
```

---

## Notes
- All functions use streaming and buffers for efficient memory usage; files are never fully loaded into RAM.
- Output and input chunk files must be in the same directory as the script or specify full paths.
- The script prints progress to the console for each chunk processed.

## Requirements
- Windows PowerShell
- No external dependencies
