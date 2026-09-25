# Sign a file using ML-DSA hash signing via smctl (DigiCert Software Trust Manager).
# Fully interactive: all options are selected via prompts.

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function die { param($msg) Write-Error "error: $msg"; exit 1 }

if (-not (Get-Command smctl -ErrorAction SilentlyContinue))   { die "smctl not found" }
if (-not (Get-Command openssl -ErrorAction SilentlyContinue)) { die "openssl not found" }

# --- select file to sign ---
$TargetFile = Read-Host "File to sign"
if (-not $TargetFile) { die "no file specified" }
if (-not (Test-Path $TargetFile -PathType Leaf)) { die "file not found: $TargetFile" }

# --- list keypairs and select one ---
Write-Host ""
Write-Host "=== Available keypairs ==="
smctl keypair list
if ($LASTEXITCODE -ne 0) { die "smctl keypair list failed" }
Write-Host ""
$KeypairId = Read-Host "Keypair ID"
if (-not $KeypairId) { die "no keypair ID provided" }

# --- select signature algorithm ---
Write-Host ""
Write-Host "Signature algorithm:"
Write-Host "  1) MLDSA44"
Write-Host "  2) MLDSA65  (default)"
Write-Host "  3) MLDSA87"
$SigChoice = Read-Host "Choice [1-3]"
$SigAlg = switch ($SigChoice) {
    "1" { "MLDSA44" }
    "3" { "MLDSA87" }
    default { "MLDSA65" }
}

# --- select hash algorithm ---
Write-Host ""
Write-Host "Hash algorithm:"
Write-Host "  1) SHA-256"
Write-Host "  2) SHA-384"
Write-Host "  3) SHA-512  (default)"
Write-Host "  4) SHA3-256"
Write-Host "  5) SHA3-512"
$HashChoice = Read-Host "Choice [1-5]"
$HashAlg, $OpensslAlg = switch ($HashChoice) {
    "1" { "SHA-256",  "sha256"   }
    "2" { "SHA-384",  "sha384"   }
    "4" { "SHA3-256", "sha3-256" }
    "5" { "SHA3-512", "sha3-512" }
    default { "SHA-512", "sha512" }
}

# --- select output format ---
Write-Host ""
Write-Host "Signature output format:"
Write-Host "  1) Base64  (default)"
Write-Host "  2) Binary"
$FmtChoice = Read-Host "Choice [1-2]"
$UseBinary = $FmtChoice -eq "2"

# --- output file ---
Write-Host ""
$DefaultSig = "$TargetFile.sig"
$SigFile = Read-Host "Signature output file [$DefaultSig]"
if (-not $SigFile) { $SigFile = $DefaultSig }

# --- compute hash locally for transparency ---
Write-Host ""
$HashOutput = openssl dgst "-$OpensslAlg" -hex $TargetFile
$FileHash = ($HashOutput -split ' ')[-1]
Write-Host "${HashAlg}: $FileHash"
Write-Host ""

# --- sign ---
$SmctlArgs = @(
    "sign", "sign-hash",
    "--file", $TargetFile,
    "--hash-algorithm", $HashAlg,
    "--signature-algorithm", $SigAlg,
    "--signature-file", $SigFile,
    $KeypairId
)
if ($UseBinary) { $SmctlArgs += "--binary" }

Write-Host "Running: smctl $($SmctlArgs -join ' ')"
smctl @SmctlArgs
if ($LASTEXITCODE -ne 0) { die "smctl sign sign-hash failed" }
Write-Host "Signature written to: $SigFile"

# --- optional verification ---
Write-Host ""
$Verify = Read-Host "Verify signature now? [Y/n]"
if (-not $Verify -or $Verify -match '^[yYjJ]$') {
    $VerifySig = $SigFile

    if (-not $UseBinary) {
        $VerifySig = [System.IO.Path]::GetTempFileName()
        Write-Host "Note: smctl verify-hash requires binary input — decoding Base64 signature to temp file"
        Write-Host "Running: openssl enc -base64 -d -A -in $SigFile -out $VerifySig"
        openssl enc -base64 -d -A -in $SigFile -out $VerifySig
        if ($LASTEXITCODE -ne 0) { die "failed to decode base64 signature" }
    }

    try {
        $VerifyArgs = @(
            "sign", "verify-hash",
            "--file", $TargetFile,
            "--hash-algorithm", $HashAlg,
            "--signature-algorithm", $SigAlg,
            "--signature-file", $VerifySig,
            $KeypairId
        )
        Write-Host "Running: smctl $($VerifyArgs -join ' ')"
        smctl @VerifyArgs
        if ($LASTEXITCODE -ne 0) { die "verification failed" }
        Write-Host "Signature verified."
    } finally {
        if (-not $UseBinary -and (Test-Path $VerifySig)) { Remove-Item $VerifySig }
    }
}
