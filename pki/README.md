# PKI

Location for the Root and Intermediate CA certificates behind your DigiCert Software Trust Manager keypairs, plus scripts that install them as trusted. Signature verification (Java, Windows, RAUC keyrings) requires these certificates.

## Certificates

Download the Root CA and Intermediate CA (ICA) that issued your signing certificate from the **DigiCert ONE** platform and place them as PEM files here:

    root/   Root CA certificates (*.pem)
    ica/    Intermediate CA certificates (*.pem)

Both directories are empty in the repository (`.gitkeep`); everything else in them is git-ignored and stays local.

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
