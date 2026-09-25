# DigiCert Software Trust Manager — Signing Examples

Scripts and integrations for code and firmware signing with DigiCert Software Trust Manager (`smctl`). Private keys stay in the DigiCert HSM. Signing runs through `smctl`, PKCS#11, JCE or the OpenSSL provider.

| Directory | Content |
|---|---|
| [firmware/](firmware/README.md) | Firmware signing integrations: RAUC OTA bundles, Silicon Labs EFR32, NXP SPSDK plugin |
| [linux/](linux/README.md) | JAR, JavaScript, OpenSSL provider and CycloneDX SBOM signing on Linux |
| [mac/](mac/README.md) | JAR and CycloneDX SBOM signing on macOS |
| [windows/](windows/README.md) | Authenticode (EXE, VBS) and JAR signing on Windows |
| [pqc/](pqc/README.md) | Post-quantum ML-DSA hash signing of arbitrary files (Bash and PowerShell) |
| [pki/](pki/README.md) | Root and intermediate CA certificates and scripts to install them as trusted |

## Prerequisites

`smctl` installed and authenticated:

```bash
smctl healthcheck
smctl kp ls              # keypair STATUS must be ONLINE
smctl certificate ls     # certificate must not be expired
```

Each directory's README lists any additional tools it needs. Third-party and DigiCert binaries (Simplicity Commander, SEGGER J-Link, `smpkcs11.so`) are not included; the READMEs link to their download sources.

## License

[Apache License 2.0](LICENSE). Provided "as is", without warranties or liability of any kind (see sections 7 and 8 of the license).
