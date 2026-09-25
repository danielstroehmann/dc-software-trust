# PKI

Location for the Root and Intermediate CA certificates behind your DigiCert Software Trust Manager keypairs, plus scripts that install them as trusted. Signature verification (Java, Windows, RAUC keyrings) requires these certificates.

## Dummy certificates

**The `demo-*` certificates in this repository are unusable dummies.** They only show which files the scripts expect and where to put them. No keypair in DigiCert Software Trust Manager was issued by them, so signature and chain verification against them will fail. Their private keys were discarded after generation.

For real use, download the Root CA and Intermediate CA (ICA) that issued your signing certificate from the **DigiCert ONE** platform and place them as PEM files next to the dummies:

    root/   Root CA certificates (*.pem)
    ica/    Intermediate CA certificates (*.pem)

Add your own files to `.gitignore` per file so they stay local.

| Dummy | Algorithm |
|---|---|
| `root/demo-rsa-root.pem`, `ica/demo-rsa-ica.pem` | RSA 4096, SHA-384 |
| `root/demo-ecdsa-root.pem`, `ica/demo-ecdsa-ica.pem` | ECDSA P-384, SHA-384 |
| `root/demo-mldsa-root.pem`, `ica/demo-mldsa-ica.pem` | ML-DSA-65 |

## Scripts

| Script | Purpose |
|---|---|
| `select-chain` | Bash helper sourced by other scripts: `select_pki_chain` prompts for a Root CA from `root/` and an Intermediate CA from `ica/` and sets `ROOT_PEM` / `ICA_PEM` |
| `install-trust.sh` | Linux (Ubuntu 24.04): copies all `*.pem` from `root/` and `ica/` into `/usr/local/share/ca-certificates` and runs `update-ca-certificates`, which also syncs the Java trust store |
| `install-trust.bat` | Windows: adds all `*.pem` from `root/` to the OS `Root` store and from `ica/` to the `CA` store, and imports them into the Java `cacerts` of the `keytool` on `PATH` |

## Usage

```bash
sudo ./install-trust.sh          # Linux
```

```bat
install-trust.bat                :: Windows, run as Administrator
```

For Windows Java only, [windows/cert-import-root.bat](../windows/cert-import-root.bat) imports `root/` and `ica/` directly.

The install scripts install every `*.pem` in `root/` and `ica/`, including the dummies. Remove the dummies first if you do not want them in your trust store.
