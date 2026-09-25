# RAUC

Creates and signs [RAUC](https://rauc.io) OTA update bundles through the OpenSSL PKCS#11 engine. RAUC passes a `pkcs11:` key URI to OpenSSL, and `smpkcs11.so` forwards the signing operation to DigiCert Software Trust Manager.

## Usage

```bash
cd firmware/rauc
./create-new [KP_ALIAS]       # build and sign src/seed.raucb
./create-resign [KP_ALIAS]    # build, sign, then re-sign into src/seed_resign.raucb
```

Without `KP_ALIAS`, the scripts list the keypairs and prompt for an alias. They then prompt for the Root CA (`pki/root/`) and Intermediate CA (`pki/ica/`) of the keypair's trust chain.

Each script:
1. Writes a dummy `rootfs.img` and `manifest.raucm` to `src/content/`
2. Builds `src/keyring.pem` from the selected Intermediate CA followed by the Root CA
3. Downloads the signing certificate with `smctl certificate download`
4. Signs with `rauc bundle --key "pkcs11:object=<KP_ALIAS>;type=private"`
5. Verifies with `rauc info --keyring src/keyring.pem`

`create-resign` also runs `rauc resign` on the first bundle. This shows how an existing bundle is re-signed, e.g. after a certificate rotation.

## Prerequisites

- Linux with `rauc` and `smctl` installed
- OpenSSL PKCS#11 engine configured as described below

### OpenSSL PKCS#11 setup

* Download the Software Trust Manager PKCS#11 library (`smpkcs11.so`) from DigiCert ONE: **Software Trust Manager → Resources → Client tool repository**. Place it in any directory, e.g. `/etc/digicert/signing/smpkcs11.so`
* Locate your system's OpenSSL PKCS#11 engine (see your distribution's docs; on Ubuntu 22+ e.g. `/usr/lib/x86_64-linux-gnu/engines-3/libpkcs11.so`)
* Combine both paths in an `openssl.cnf`, e.g. `/etc/digicert/signing/openssl.cnf` (template: [openssl-exsample/openssl.cnf](openssl-exsample/openssl.cnf))

```
openssl_conf = openssl_init
[openssl_init]
engines = engine_section
[engine_section]
pkcs11 = pkcs11_section
[pkcs11_section]

#Path to the OpenSSL PKCS11 Engine
dynamic_path = /usr/lib/x86_64-linux-gnu/engines-3/libpkcs11.so
MODULE_PATH = /etc/digicert/signing/smpkcs11.so
```

* Extend your `.bashrc`:

```
export OPENSSL_CONF="/etc/digicert/signing/openssl.cnf"
```

Reference: https://docs.digicert.com/en/software-trust-manager/client-tools/signing-tools/third-party-signing-tool-integrations/configure-openssl-for-signing-with-pkcs11.html
