#!/usr/bin/env python3
"""
Direct test of the smctl SPSDK Signature Provider.

Tests the plugin independently of the SPSDK MBI build flow:
  1. smctl Healthcheck
  2. Instantiate plugin (check SPSDK interface)
  3. Read input file
  4. Sign via smctl (DigiCert Cloud)
  5. Validate signature length
  6. Save signature

Usage:
  python3 test_plugin_direct.py --keypair-id <UUID> --sig-alg SHA256WithRSA
  python3 test_plugin_direct.py --keypair-id <UUID> --sig-alg SHA256WithECDSA
  python3 test_plugin_direct.py --keypair-id <UUID> --sig-alg MLDSA65
"""

import argparse
import hashlib
import os
import subprocess
import sys

sys.path.insert(0, os.path.dirname(__file__))
from smctl_signature_provider import SmctlSignatureProvider, _SIGNATURE_LENGTHS


def step(n, text):
    print(f"\n{'='*60}")
    print(f"  Step {n}: {text}")
    print(f"{'='*60}")

def ok(msg):   print(f"  OK  {msg}")
def warn(msg): print(f"  !!  {msg}")
def fail(msg):
    print(f"  ERROR: {msg}")
    sys.exit(1)


def main():
    parser = argparse.ArgumentParser(
        description="Direct test of the smctl SPSDK Signature Provider"
    )
    parser.add_argument("--keypair-id", required=True,
        help="Keypair UUID from 'smctl keypair ls'")
    parser.add_argument("--sig-alg", default="SHA256WithRSA",
        choices=sorted(_SIGNATURE_LENGTHS.keys()),
        help="Signature algorithm (default: SHA256WithRSA)")
    parser.add_argument("--hash-alg", default="SHA-256",
        choices=["SHA-256", "SHA-384", "SHA-512"],
        help="Hash algorithm (default: SHA-256)")
    parser.add_argument("--input", default="firmware_sample.bin",
        help="File to sign (default: firmware_sample.bin)")
    args = parser.parse_args()

    print("\n" + "="*60)
    print("  smctl SPSDK Signature Provider -- Direct Test")
    print("="*60)
    print(f"  keypair_id : {args.keypair_id}")
    print(f"  sig_alg    : {args.sig_alg}")
    print(f"  hash_alg   : {args.hash_alg}")
    print(f"  input      : {args.input}")

    # Step 1: smctl healthcheck
    step(1, "smctl Healthcheck")
    result = subprocess.run(["smctl", "healthcheck"], capture_output=True, text=True)
    if result.returncode != 0:
        fail("smctl healthcheck failed. Environment variables set?\n"
             "  Required: SM_API_KEY, SM_CLIENT_CERT_FILE, SM_CLIENT_CERT_PASSWORD, SM_HOST")
    ok("smctl healthcheck OK")

    # Step 2: Instantiate plugin
    step(2, "Instantiate plugin")
    try:
        sp = SmctlSignatureProvider(
            keypair_id=args.keypair_id,
            sig_alg=args.sig_alg,
            hash_alg=args.hash_alg,
        )
        ok(f"Plugin instantiated: {sp.info()}")
        ok(f"Expected signature length: {sp.signature_length} bytes")
    except Exception as e:
        fail(f"Plugin init failed: {e}")

    # Step 3: Read input file
    step(3, "Read input file")
    if not os.path.exists(args.input):
        fail(f"File not found: {args.input}\n"
             "  Create it with: python3 create_sample_firmware.py")
    with open(args.input, "rb") as f:
        data = f.read()
    ok(f"Read: {args.input} ({len(data)} bytes)")
    ok(f"SHA-256: {hashlib.sha256(data).hexdigest()}")

    # Step 4: Signing
    step(4, "Signing via smctl sign sign-hash")
    print("  (Please wait -- DigiCert cloud signing, approx. 5-30 seconds)")
    try:
        signature = sp.sign(data)
    except RuntimeError as e:
        fail(str(e))
    except FileNotFoundError as e:
        fail(str(e))

    ok("Signing successful")
    ok(f"Signature: {len(signature)} bytes")

    # Step 5: Validate length
    step(5, "Validate signature length")
    expected = sp.signature_length
    if len(signature) != expected:
        warn(f"Got {len(signature)} bytes, expected {expected} bytes")
        warn("For RSA the length depends on the key: 2048=256, 3072=384, 4096=512")
        warn(f"Adjust _SIGNATURE_LENGTHS['{args.sig_alg}'] in smctl_signature_provider.py")
    else:
        ok(f"Length correct: {len(signature)} == {expected} bytes")

    # Step 6: Save signature
    step(6, "Save signature")
    out_file = f"{args.input}.sig"
    with open(out_file, "wb") as f:
        f.write(signature)
    ok(f"Saved: {out_file}")
    print(f"  First 16 bytes (hex): {signature[:16].hex()}")

    # Summary
    print("\n" + "="*60)
    print("  ALL STEPS SUCCESSFUL")
    print("="*60)
    print(f"  Signature algorithm  : {args.sig_alg}")
    print(f"  Signature length     : {len(signature)} bytes")
    print(f"  Signature file       : {out_file}")
    print()


if __name__ == "__main__":
    main()
