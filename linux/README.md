# Linux

Demo scripts for signing artifacts on Linux with DigiCert Software Trust Manager: JAR files, JavaScript, arbitrary files via OpenSSL, and CycloneDX SBOMs. Each script creates a small sample input in `src/`, signs it and prints the result.

Run the scripts from this directory. Each lists the keypairs (`smctl kp ls`) and prompts for the alias or UUID.

## Scripts

| Script | Purpose |
|---|---|
| `cert-create` | Issue a certificate for an existing keypair (prompts for keypair ID, certificate profile ID and alias) |
| `cert-import-root` | Prompt for a Root CA and Intermediate CA from `../pki/root/` and `../pki/ica/` and import them into the Java `cacerts` trust store (uses `sudo` and `$JAVA_HOME`) |
| `sign-jar-jarsigner` | Sign `src/hello.jar` with `jarsigner` and the DigiCert JCE provider, timestamped; prints the signature file from `META-INF` |
| `sign-jar-smctl` | Sign `src/SIGNED_hello.jar` with `smctl sign` via PKCS#11; prints the signature file from `META-INF` |
| `sign-js` | Sign `src/hello.js` with `smctl sign` (embedded signature block) |
| `sign-openssl-mod` | Sign `src/hello.jar` with `openssl dgst` and the `digicert_stm` OpenSSL provider (`stm://<alias>`), export the public key, verify |
| `sign-sbom` | Sign `src/sbom.json` as a CycloneDX in-toto attestation (`smctl sign in-toto cyclonedx`); takes the keypair UUID |
| `helper-jar-helloworld` | Build and run `src/hello.jar` (Hello World), used by the JAR scripts |
| `helper-sbom-create` | Write a minimal CycloneDX `src/sbom.json`, used by `sign-sbom` |

`src/signed_sbom.json` is a sample output of `sign-sbom`.

## Prerequisites

- `smctl` installed and authenticated (`smctl healthcheck`)
- JDK (`javac`, `jar`, `jarsigner`, `keytool`) for the JAR scripts
- For `sign-jar-jarsigner`: `digicert-jce-1.0.jar` and `bcprov-jdk18on-1.77.jar`
- For `sign-jar-smctl` and `sign-js`: a `pkcs11properties.cfg`
- For `sign-openssl-mod`: OpenSSL 3 with the DigiCert STM provider (`digicert_stm`)

The JCE jars and `pkcs11properties.cfg` are expected in `$SIGNING_DIR` (default `~/signing`).
