# SPSDK

SPSDK Signature Provider plugin for DigiCert smctl. It lets [NXP SPSDK](https://github.com/nxp-mcuxpresso/spsdk) sign MCU images (e.g. LPC55, i.MX RT, MCX) with a key held in DigiCert Software Trust Manager instead of a local key file. Each signing request is forwarded to `smctl sign sign-hash`.

## Usage

Install the plugin (registers the `smctl` signature provider type with SPSDK):

    cd firmware/spsdk
    pip install -e . --break-system-packages

Reference it in the SPSDK YAML config:

    signProvider: "type=smctl;keypair_id=<UUID>;sig_alg=SHA256WithRSA;hash_alg=SHA-256"

Test without a full SPSDK build (signs `firmware_sample.bin` with MLDSA65):

    ./sign

See [Run the test](#run-the-test) for other algorithms.

## Files

| File                           | Purpose                                    |
|--------------------------------|--------------------------------------------|
| smctl_signature_provider.py    | The SPSDK plugin                           |
| pyproject.toml                 | Plugin registration as SPSDK entry point   |
| test_plugin_direct.py          | Functional test (6 steps)                  |
| sign                           | Interactive wrapper for the MLDSA65 test   |
| create_sample_firmware.py      | Creates dummy firmware for testing         |
| firmware_sample.bin            | Ready-made dummy firmware (256 bytes)      |

---

## Known smctl quirks

### Algorithm names are case-sensitive
smctl expects exactly this spelling (capital W):

    SHA256WithRSA   SHA256WithECDSA   MLDSA65   SLHDSA

"SHA256withRSA" (lowercase w) results in "unexpected empty signature returned".

### --file instead of --hash
The plugin passes the raw data to smctl via --file.
smctl computes the hash internally. This is more reliable than --hash.

### "unexpected empty signature returned" = usually an expired certificate
This smctl error gives no information about the actual cause.
Most common causes: expired certificate, key OFFLINE, wrong algorithm.

    smctl kp ls          # STATUS must be ONLINE, CERTIFICATE column populated
    smctl certificate ls # check expiry date

### RSA signature length depends on the key
    RSA-2048 -> 256 bytes
    RSA-3072 -> 384 bytes  (default in this plugin)
    RSA-4096 -> 512 bytes

If the length does not match: adjust _SIGNATURE_LENGTHS in smctl_signature_provider.py.

### ECDSA returns DER-encoded signatures (variable length)
The plugin reports the maximum value: P-256 max 72 B, P-384 max 104 B.

---

## Prerequisites

    smctl --version
    smctl healthcheck
    python3 --version        # >= 3.9
    smctl kp ls              # check UUID and STATUS

---

## Installation

    cd firmware/spsdk
    pip install -e . --break-system-packages

    # Check that the plugin is registered:
    python3 -c "
    from spsdk.crypto.signature_provider import SignatureProvider
    types = SignatureProvider.get_types()
    print('OK' if 'smctl' in str(types) else 'ERROR', types)
    "

On error "externally-managed-environment":

    pip install -e . --break-system-packages --force-reinstall

---

## Run the test

Take the UUID from "smctl kp ls":

    python3 test_plugin_direct.py \
      --keypair-id <UUID> \
      --sig-alg SHA256WithRSA

    python3 test_plugin_direct.py \
      --keypair-id <UUID> \
      --sig-alg SHA256WithECDSA

    python3 test_plugin_direct.py \
      --keypair-id <UUID> \
      --sig-alg MLDSA65

Expected result:

    ============================================================
      ALL STEPS SUCCESSFUL
    ============================================================
      Signature algorithm  : MLDSA65
      Signature length     : 3309 bytes
      Signature file       : firmware_sample.bin.sig

---

## Troubleshooting

### "unexpected empty signature returned"
    smctl kp ls              # CERTIFICATE column must contain a UUID
    smctl certificate ls     # check expiry date
    # Renew the certificate in DigiCert ONE

### "invalid choice: SHA256WithRSA" when running
Old plugin version loaded:
    pip install -e . --break-system-packages --force-reinstall

### "Class SmctlSignatureProvider uses legacy identifier sp_type"
Old smctl_signature_provider.py -- use the file from this package.

### "ModuleNotFoundError: No module named setuptools.backends"
Wrong pyproject.toml -- the one in this package is correct.

---

## Algorithm reference (official smctl spellings)

RSA:
  SHA256WithRSA  SHA384WithRSA  SHA512WithRSA
  SHA256WithRSA/PSS  SHA384WithRSA/PSS  SHA512WithRSA/PSS
  SHA3-256WithRSA  SHA3-384WithRSA  SHA3-512WithRSA

ECDSA:
  SHA256WithECDSA  SHA384WithECDSA  SHA512WithECDSA
  SHA3-256WithECDSA  SHA3-384WithECDSA  SHA3-512WithECDSA

Post-Quantum:
  MLDSA44  MLDSA65  MLDSA87  SLHDSA

EdDSA:
  Ed25519  Ed25519ph

Source: https://docs.digicert.com/en/software-trust-manager/client-tools/
        command-line-interface/smctl/manage-in-toto-signatures/manage-hash-signatures.html
