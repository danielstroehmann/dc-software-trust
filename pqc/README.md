# PQC

Interactive scripts that sign any file with a post-quantum ML-DSA (FIPS 204) key via `smctl sign sign-hash` and optionally verify the signature with `smctl sign verify-hash`.

## Scripts

| Script | Platform |
|---|---|
| `sign-hash-mldsa` | Bash (Linux/macOS) |
| `sign-hash-mldsa-fancy` | Bash, same flow with colored and sectioned output |
| `sign-hash-mldsa.ps1` | PowerShell (Windows) |

## Usage

```bash
./sign-hash-mldsa
```

```powershell
.\sign-hash-mldsa.ps1
```

The script prompts for:
1. File to sign
2. Keypair ID (from the listed keypairs)
3. Signature algorithm: `MLDSA44`, `MLDSA65` (default) or `MLDSA87`
4. Hash algorithm: `SHA-256`, `SHA-384`, `SHA-512` (default), `SHA3-256` or `SHA3-512`
5. Output format: Base64 (default) or binary
6. Signature file (default `<file>.sig`)

It prints the locally computed file hash, signs, and optionally verifies. A Base64 signature is decoded to a temp file for verification because `verify-hash` expects binary input.

## Prerequisites

- `smctl` installed and authenticated, with an ML-DSA keypair ONLINE
- `openssl` (local hash and Base64 decoding)
