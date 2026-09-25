# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Purpose

This repo contains scripts and tooling for signing firmware using **DigiCert Software Trust Manager (smctl)** via PKCS#11. It covers two firmware targets and one SPSDK plugin:

| Directory | Purpose |
|---|---|
| `firmware/rauc/` | Sign/resign RAUC OTA bundles via PKCS#11 + OpenSSL |
| `firmware/silabs/` | Sign Silabs EFR32 `.s37` firmware via smctl + commander-cli |
| `firmware/spsdk/` | SPSDK SignatureProvider plugin for DigiCert smctl |
| `pki/` | Root CAs in `root/`, Intermediate CAs in `ica/`, selection helper `select-chain`. Only the `demo-*` dummy certificates are tracked; real certificates are git-ignored per file |

## Prerequisites

All workflows require `smctl` (DigiCert Software Trust Manager CLI) to be installed and authenticated:

```bash
smctl --version
smctl healthcheck
smctl kp ls              # Lists keypairs — note UUID and STATUS (must be ONLINE)
smctl certificate ls     # Check certificate expiry
```

For RAUC signing, also requires:
- `rauc` installed
- OpenSSL with PKCS#11 engine configured (see `firmware/rauc/README.md`)
- `smpkcs11.so` placed and `OPENSSL_CONF` pointing to a valid `openssl.cnf`

## Commands

### RAUC firmware bundle (Linux)

```bash
cd firmware/rauc

# Create and sign a new bundle
./create-new [KP_ALIAS]          # prompts for alias if omitted

# Create, sign, then re-sign (demonstrates resign workflow)
./create-resign [KP_ALIAS]
```

Both scripts prompt for the Root CA and Intermediate CA, download the certificate from smctl, build a bundle, sign via PKCS#11, and verify with `rauc info`.

### Silabs EFR32 firmware (Linux)

```bash
cd firmware/silabs
./sign [KP_ALIAS]                # prompts for alias if omitted
```

Steps: `commander-cli convert` (extract hash) → `smctl sign sign-hash` → verify → `commander-cli convert` (inject signature) → output `firmware.signed.s37`.

### SPSDK plugin — install and test

```bash
cd firmware/spsdk
pip install -e . --break-system-packages

# Verify plugin registration
python3 -c "
from spsdk.crypto.signature_provider import SignatureProvider
types = SignatureProvider.get_types()
print('OK' if 'smctl' in str(types) else 'ERROR', types)
"

# Run test (get UUID from: smctl kp ls)
python3 test_plugin_direct.py --keypair-id <UUID> --sig-alg SHA256WithRSA
python3 test_plugin_direct.py --keypair-id <UUID> --sig-alg SHA256WithECDSA
python3 test_plugin_direct.py --keypair-id <UUID> --sig-alg MLDSA65
```

## Architecture

### smctl sign-hash flow (Silabs + SPSDK plugin)

The `smctl sign sign-hash` command takes raw file bytes (`--file`), computes the hash internally, and returns a raw binary signature (`--binary`). This is more reliable than passing a pre-computed hash via `--hash`.

### PKCS#11 flow (RAUC)

RAUC uses OpenSSL with the PKCS#11 engine (`smpkcs11.so`) so that the private key never leaves the DigiCert HSM. The key URI format is `pkcs11:object=<KP_ALIAS>;type=private`.

### Trust chain

`pki/select-chain` provides `select_pki_chain`, which prompts for a Root CA from `pki/root/` and an Intermediate CA from `pki/ica/` and sets `ROOT_PEM` / `ICA_PEM`. It is sourced by the RAUC scripts, `linux/cert-import-root` and `mac/sign-jar`. For RAUC, both are concatenated into `keyring.pem` — Intermediate CA first, then Root CA.

### SPSDK plugin

`SmctlSignatureProvider` in [firmware/spsdk/smctl_signature_provider.py](firmware/spsdk/smctl_signature_provider.py) wraps `smctl sign sign-hash` as an SPSDK `SignatureProvider`. It is registered via the `spsdk.sp` entry-point in `pyproject.toml`.

Usage in SPSDK YAML:
```
signProvider: "type=smctl;keypair_id=<UUID>;sig_alg=SHA256WithRSA;hash_alg=SHA-256"
```

## smctl Gotchas

- **Algorithm names are case-sensitive**: use `SHA256WithRSA` (capital W), not `SHA256withRSA`
- **"unexpected empty signature returned"**: usually means expired certificate, keypair OFFLINE, or wrong algorithm — check `smctl kp ls` and `smctl certificate ls`
- **RSA signature length depends on key size**: RSA-2048=256B, RSA-3072=384B (default), RSA-4096=512B — update `_SIGNATURE_LENGTHS` in the plugin if needed

## IMPORTANT

- **Security First** - Nothing in this repository should contain any kind of credentials, if so refactor until in .env files that are excluded from git.
- **No boilerplate** - No unnecessary code, only what is needed, clear naming structures and readable code.

