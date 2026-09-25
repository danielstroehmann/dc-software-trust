# macOS

Demo scripts for DigiCert Software Trust Manager on macOS: certificate creation, JAR signing and CycloneDX SBOM signing.

Run the scripts from this directory. Each lists the keypairs (`smctl kp ls`) and prompts for the ID or alias.

## Scripts

| Script | Purpose |
|---|---|
| `cert-create` | Issue a certificate for an existing keypair (prompts for keypair ID, certificate profile ID and alias) |
| `sign-jar [KP_ALIAS]` | Build `src/hello.jar`, prompt for a Root CA and Intermediate CA from `../pki/root/` and `../pki/ica/` and import them into Java `cacerts` (uses `sudo`), sign with `jarsigner` and the DigiCert JCE provider (timestamped), print the signature file |
| `sign-sbom` | Write a minimal CycloneDX `src/sbom.json` and sign it as an in-toto attestation (`smctl sign in-toto cyclonedx`); takes the keypair UUID |

`src/sbom.json` and `src/signed_sbom.json` are sample input and output.

## Prerequisites

- `smctl` installed and authenticated (`smctl healthcheck`)
- JDK with `$JAVA_HOME` set, for `sign-jar`
- DigiCert JCE provider (`digicert-jce-1.0.jar`, `bcprov-jdk18on-1.77.jar`) in `~/.digicert-ucpc/applications/smjce/1.0/`
