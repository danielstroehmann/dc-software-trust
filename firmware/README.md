# Firmware Signing Integrations

Firmware signing integrations for DigiCert Software Trust Manager (`smctl`). The private key always stays in the DigiCert HSM.

| Directory | Target | Mechanism | Entry point |
|---|---|---|---|
| [rauc/](rauc/README.md) | RAUC OTA update bundles (embedded Linux) | OpenSSL PKCS#11 engine (`smpkcs11.so`) | `./create-new`, `./create-resign` |
| [silabs/](silabs/README.md) | Silicon Labs EFR32 Secure Boot images (`.s37`) | `smctl sign sign-hash` + Simplicity Commander | `./sign` |
| [spsdk/](spsdk/README.md) | NXP MCU images built with SPSDK | SPSDK Signature Provider plugin wrapping `smctl sign sign-hash` | `pip install -e .`, `./sign` |

## Common prerequisites

```bash
smctl healthcheck        # smctl installed and authenticated
smctl kp ls              # keypair STATUS must be ONLINE
smctl certificate ls     # certificate must not be expired
```
