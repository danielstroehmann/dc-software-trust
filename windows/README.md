# Windows

Demo batch scripts for signing on Windows with DigiCert Software Trust Manager: Authenticode (EXE, VBS) and JAR signing. Sample inputs are created in `src/`.

Run the scripts from this directory. Scripts marked `[KP_ALIAS]` take the alias as an argument; the others list the keypairs and prompt for it.

## Scripts

| Script | Purpose |
|---|---|
| `cert-create.bat [KP_ID]` | Issue a certificate for an existing keypair (prompts for certificate profile ID and alias) |
| `cert-import-root.bat` | Import all root and intermediate certificates from `..\pki\root\` and `..\pki\ica\` into the Java `cacerts` trust store, skipping existing aliases |
| `sign-exe.bat [KP_ALIAS]` | Copy `notepad.exe` to `src\`, sync the certificate to the Windows store (`smctl windows certsync`), Authenticode-sign and verify it |
| `sign-vbs.bat [KP_ALIAS]` | Write a Hello World VBScript to `src\`, then Authenticode-sign and verify it |
| `sign-jar-jarsigner.bat` | Sign `src\hello.jar` with `jarsigner` and the SunPKCS11 provider (timestamped); output `src\hello_signed.jar` |
| `sign-jar-smctl.bat` | Sign `src\hello.jar` with `smctl sign` via PKCS#11 |
| `helper-jar-helloworld.bat` | Build and run `src\hello.jar` (Hello World), used by the JAR scripts |

## Prerequisites

- DigiCert One Signing Manager Tools installed (`smctl`, `pkcs11properties.cfg` in `C:\Program Files\DigiCert\DigiCert One Signing Manager Tools\`)
- `smctl` authenticated (`smctl healthcheck`)
- Windows SDK `signtool` for Authenticode signing via `smctl sign`
- JDK (`javac`, `jar`, `jarsigner`, `keytool`) for the JAR scripts
