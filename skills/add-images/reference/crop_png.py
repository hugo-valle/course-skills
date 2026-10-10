#!/usr/bin/env python3
"""Crop a rendered page to its content: crop_png.py in.pnm out.png  (PNM/PPM/PGM in, PNG out)."""
import struct, sys, zlib
import numpy as np

def read_pnm(path):
    data = open(path, "rb").read()
    parts, i = [], 0
    while len(parts) < 4:
        while data[i:i + 1].isspace():
            i += 1
        j = i
        while not data[j:j + 1].isspace():
            j += 1
        parts.append(data[i:j]); i = j
    magic, w, h, _ = parts[0], int(parts[1]), int(parts[2]), parts[3]
    ch = 3 if magic == b"P6" else 1
    return np.frombuffer(data[i + 1:], np.uint8).reshape(h, w, ch)

def write_png(path, img):
    h, w, ch = img.shape
    raw = b"".join(b"\x00" + img[y].tobytes() for y in range(h))
    def chunk(t, d):
        c = struct.pack(">I", len(d)) + t + d
        return c + struct.pack(">I", zlib.crc32(t + d) & 0xFFFFFFFF)
    ctype = 2 if ch == 3 else 0
    open(path, "wb").write(b"\x89PNG\r\n\x1a\n" + chunk(b"IHDR", struct.pack(">IIBBBBB", w, h, 8, ctype, 0, 0, 0))
                           + chunk(b"IDAT", zlib.compress(raw)) + chunk(b"IEND", b""))

img = read_pnm(sys.argv[1])
ys, xs = np.where((img < 250).any(axis=2))
pad = 12
y0, y1 = max(ys.min() - pad, 0), min(ys.max() + pad, img.shape[0])
x0, x1 = max(xs.min() - pad, 0), min(xs.max() + pad, img.shape[1])
write_png(sys.argv[2], np.ascontiguousarray(img[y0:y1, x0:x1]))
