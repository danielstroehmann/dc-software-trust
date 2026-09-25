#!/usr/bin/env python3
"""Creates a minimal dummy firmware file for testing."""
import struct

# Minimal ARM Cortex-M image:
# - Stack pointer (4 bytes)
# - Reset vector (4 bytes)
# - Then zeros as padding
data = bytearray(256)

# Stack Pointer: 0x2000_4000 (end of 16KB SRAM)
struct.pack_into("<I", data, 0, 0x20004000)
# Reset Vector: 0x0000_0009 (address 8, Thumb mode)
struct.pack_into("<I", data, 4, 0x00000009)
# NOP loop at address 8 (Thumb2)
# NOP = 0x46C0 (MOV r8, r8)
struct.pack_into("<H", data, 8, 0x46C0)  # NOP
struct.pack_into("<H", data, 10, 0xE7FE)  # B . (infinite loop)

# Fill with recognizable bytes
for i in range(12, 256):
    data[i] = i & 0xFF

with open("firmware_sample.bin", "wb") as f:
    f.write(data)

print(f"firmware_sample.bin created: {len(data)} bytes")
import hashlib
sha = hashlib.sha256(data).hexdigest()
print(f"SHA-256: {sha}")
