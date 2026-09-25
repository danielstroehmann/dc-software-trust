# Silicon Labs

Signs Silicon Labs EFR32 Secure Boot firmware images (`.s37`) with an ECDSA P-256 key in DigiCert Software Trust Manager. Simplicity Commander (`commander-cli`) prepares the image and injects the signature. `smctl` does the signing.

## Usage

```bash
cd firmware/silabs
./sign [KP_ALIAS]
```

Without `KP_ALIAS`, the script lists the keypairs and prompts for an alias. Input is `firmware.s37`; output is `firmware.signed.s37`.

The script:
1. `commander-cli convert --secureboot --extsign` extracts the data to sign into `firmware.extsign`
2. `smctl sign sign-hash --signature-algorithm SHA256WithECDSA --binary` signs it, then `smctl sign verify-hash` checks the signature
3. Downloads the certificate and extracts the public key with `openssl`
4. `commander-cli convert --signature … --verify <pubkey>` injects and verifies the signature, then writes `firmware.signed.s37`
5. Removes the intermediate files

## Prerequisites

- Linux x86-64
- [Simplicity Commander](https://www.silabs.com/developer-tools/simplicity-studio/simplicity-commander) for Linux (tested with 1.22.0), extracted so that `src/tools/commander-cli` exists. `src/tools/` is in `.gitignore`.
- [SEGGER J-Link Software](https://www.segger.com/downloads/jlink/), required by Simplicity Commander
- `smctl` and `openssl` installed
- ECDSA P-256 keypair ONLINE (`smctl kp ls`)
