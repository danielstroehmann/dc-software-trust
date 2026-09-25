import os
import subprocess
import tempfile

from spsdk.crypto.signature_provider import SignatureProvider


# Official smctl algorithm names and signature lengths
# Source: https://docs.digicert.com/en/software-trust-manager/client-tools/
#         command-line-interface/smctl/manage-in-toto-signatures/manage-hash-signatures.html
#
# RSA:   key length determines signature size — adjust if not RSA-3072!
#        RSA-2048 → 256 Bytes, RSA-3072 → 384 Bytes, RSA-4096 → 512 Bytes
# ECDSA: DER-encoded, variable — maximum value given
_SIGNATURE_LENGTHS = {
    # --- RSA (default: RSA-3072 = 384 bytes) ---
    "NONEWithRSA"           : 384,
    "SHA1WithRSA"           : 384,
    "SHA224WithRSA"         : 384,
    "SHA256WithRSA"         : 384,
    "SHA384WithRSA"         : 384,
    "SHA512WithRSA"         : 384,
    "SHA3-224WithRSA"       : 384,
    "SHA3-256WithRSA"       : 384,
    "SHA3-384WithRSA"       : 384,
    "SHA3-512WithRSA"       : 384,
    "NONEwithRSASSA-PSS"    : 384,
    "SHA1WithRSA/PSS"       : 384,
    "SHA224WithRSA/PSS"     : 384,
    "SHA256WithRSA/PSS"     : 384,
    "SHA384WithRSA/PSS"     : 384,
    "SHA512WithRSA/PSS"     : 384,
    "SHA3-224WithRSA/PSS"   : 384,
    "SHA3-256WithRSA/PSS"   : 384,
    "SHA3-384WithRSA/PSS"   : 384,
    "SHA3-512WithRSA/PSS"   : 384,

    # --- ECDSA (DER-encoded, maximum per curve) ---
    # P-256: max 72, P-384: max 104, P-521: max 139
    "NONEWithECDSA"         : 72,
    "SHA1WithECDSA"         : 72,
    "SHA224WithECDSA"       : 72,
    "SHA256WithECDSA"       : 72,
    "SHA384WithECDSA"       : 104,
    "SHA512WithECDSA"       : 139,
    "SHA3-224WithECDSA"     : 72,
    "SHA3-256WithECDSA"     : 72,
    "SHA3-384WithECDSA"     : 104,
    "SHA3-512WithECDSA"     : 139,

    # --- EdDSA ---
    "Ed25519"               : 64,
    "Ed25519ph"             : 64,

    # --- ML-DSA (FIPS 204) ---
    "MLDSA44"               : 2420,
    "MLDSA65"               : 3309,
    "MLDSA87"               : 4627,

    # --- SLH-DSA / SPHINCS+ (FIPS 205) ---
    # smctl accepts "SLHDSA" as a generic identifier;
    # specific variants if supported:
    "SLHDSA"                : 7856,   # Fallback — actual length depends on parameter set
    "SLHDSA-SHA2-128s"      : 7856,
    "SLHDSA-SHA2-128f"      : 17088,
    "SLHDSA-SHA2-192s"      : 16224,
    "SLHDSA-SHA2-192f"      : 35664,
    "SLHDSA-SHA2-256s"      : 29792,
    "SLHDSA-SHA2-256f"      : 49856,
    "SLHDSA-SHAKE-128s"     : 7856,
    "SLHDSA-SHAKE-128f"     : 17088,
    "SLHDSA-SHAKE-192s"     : 16224,
    "SLHDSA-SHAKE-192f"     : 35664,
    "SLHDSA-SHAKE-256s"     : 29792,
    "SLHDSA-SHAKE-256f"     : 49856,
}


class SmctlSignatureProvider(SignatureProvider):
    """SPSDK Signature Provider via DigiCert smctl sign sign-hash (headless/automated).

    Flow:
      1. SPSDK passes raw data
      2. Write raw data to a temporary file
      3. smctl sign sign-hash --file <tmpfile> --binary → raw signature bytes
      4. Return signature bytes (no CMS/PKCS#7 parsing needed)

    smctl computes the hash internally from --file.
    """

    identifier = "smctl"

    def __init__(
        self,
        keypair_id: str,
        sig_alg: str = "SHA256WithRSA",
        hash_alg: str = "SHA-256",
    ) -> None:
        """
        :param keypair_id:  Keypair UUID from 'smctl keypair ls'
        :param sig_alg:     Signature algorithm (official smctl spelling), e.g.:
                              SHA256WithRSA, SHA256WithECDSA,
                              MLDSA44, MLDSA65, MLDSA87, SLHDSA, Ed25519
        :param hash_alg:    Hash algorithm for smctl: SHA-256 | SHA-384 | SHA-512
                            (passed to --hash-algorithm)
        """
        self.keypair_id = keypair_id
        self.sig_alg    = sig_alg
        self.hash_alg   = hash_alg

        if sig_alg not in _SIGNATURE_LENGTHS:
            raise ValueError(
                f"Unknown sig_alg: '{sig_alg}'.\n"
                f"Allowed: {sorted(_SIGNATURE_LENGTHS.keys())}"
            )

    def sign(self, data: bytes) -> bytes:
        """
        :param data:  Raw data from SPSDK
        :return:      Raw signature bytes
        """
        with tempfile.TemporaryDirectory() as tmpdir:
            in_file  = os.path.join(tmpdir, "data.bin")
            sig_file = os.path.join(tmpdir, "data.sig")

            with open(in_file, "wb") as f:
                f.write(data)

            result = subprocess.run(
                [
                    "smctl", "sign", "sign-hash",
                    "--file",                in_file,
                    "--hash-algorithm",      self.hash_alg,
                    "--signature-algorithm", self.sig_alg,
                    "--signature-file",      sig_file,
                    "--binary",
                    self.keypair_id,
                ],
                capture_output=True,
                text=True,
            )

            if result.returncode != 0:
                raise RuntimeError(
                    f"smctl sign sign-hash failed (exit {result.returncode}):\n"
                    f"stdout: {result.stdout}\n"
                    f"stderr: {result.stderr}"
                )

            if not os.path.exists(sig_file):
                raise FileNotFoundError(
                    f"Signature file not created: {sig_file}\n"
                    f"smctl output: {result.stdout}"
                )

            with open(sig_file, "rb") as f:
                return f.read()

    @property
    def signature_length(self) -> int:
        return _SIGNATURE_LENGTHS[self.sig_alg]

    def info(self) -> str:
        return (
            f"DigiCert smctl Signature Provider  "
            f"sig={self.sig_alg}  hash={self.hash_alg}  "
            f"keypair_id={self.keypair_id}  "
            f"sig_len={self.signature_length} B"
        )


# -----------------------------------------------------------------------------
# Registration as SPSDK plugin via pyproject.toml:
#
# [project.entry-points."spsdk.sp"]
# smctl = "smctl_signature_provider:SmctlSignatureProvider"
#
# Then: pip install -e . --break-system-packages
#
# Usage in SPSDK YAML:
#   signProvider: "type=smctl;keypair_id=<UUID>;sig_alg=SHA256WithRSA;hash_alg=SHA-256"
#   signProvider: "type=smctl;keypair_id=<UUID>;sig_alg=SHA256WithECDSA;hash_alg=SHA-256"
#   signProvider: "type=smctl;keypair_id=<UUID>;sig_alg=MLDSA65;hash_alg=SHA-256"
#
# Get keypair_id: smctl keypair ls
# -----------------------------------------------------------------------------
