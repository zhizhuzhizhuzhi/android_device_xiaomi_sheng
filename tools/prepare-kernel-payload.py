#!/usr/bin/env python3
# SPDX-License-Identifier: Apache-2.0
"""Prepare hash-pinned Sheng kernel inputs from unpacked stock images."""
import argparse
import gzip
import hashlib
import json
from pathlib import Path
import struct
import subprocess


def unpack(data, lz4):
    if data[:2] == b'\x1f\x8b':
        return gzip.decompress(data)
    if data[:4] in (bytes.fromhex('04224d18'), bytes.fromhex('02214c18')):
        if not lz4:
            raise ValueError('Compressed ramdisk requires --lz4')
        return subprocess.run([str(lz4), '-d', '-c'], input=data, capture_output=True, check=True).stdout
    return data


def cpio_files(data):
    offset = 0
    while offset + 110 <= len(data):
        if data[offset:offset + 6] not in (b'070701', b'070702'):
            raise ValueError('Unsupported ramdisk CPIO header')
        fields = [int(data[offset + 6 + i * 8:offset + 14 + i * 8], 16) for i in range(13)]
        size, namesize = fields[6], fields[11]
        name = data[offset + 110:offset + 110 + namesize - 1].decode()
        begin = (offset + 110 + namesize + 3) & ~3
        end = begin + size
        if end > len(data):
            raise ValueError('Truncated ramdisk')
        if name == 'TRAILER!!!':
            return
        p = Path(name)
        if p.is_absolute() or '..' in p.parts:
            raise ValueError('Unsafe CPIO member')
        if fields[1] & 0o170000 == 0o100000:
            yield name, data[begin:end]
        offset = (end + 3) & ~3


def split_dtbs(data):
    offset = 0
    while offset < len(data):
        start = data.find(bytes.fromhex('d00dfeed'), offset)
        if start < 0:
            if any(data[offset:]):
                raise ValueError('Nonzero trailing DTB bytes')
            return
        if any(data[offset:start]):
            raise ValueError('Unexpected DTB padding')
        size = struct.unpack_from('>I', data, start + 4)[0]
        if size < 40 or start + size > len(data):
            raise ValueError('Truncated DTB')
        yield data[start:start + size]
        offset = start + size


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--images', type=Path, required=True, help='Stock fastboot images directory, containing dtbo.img')
    parser.add_argument('--boot-unpacked', type=Path, required=True, help='AOSP unpack_bootimg output for stock boot.img')
    parser.add_argument('--vendor-boot-unpacked', type=Path, required=True, help='AOSP unpack_bootimg output for stock vendor_boot.img')
    parser.add_argument('--dump', type=Path, required=True, help='Extracted stock partitions, including system_dlkm and vendor_dlkm')
    parser.add_argument('--output', type=Path, required=True)
    parser.add_argument('--manifest', type=Path, default=Path(__file__).resolve().parents[1] / 'device-inputs.json')
    parser.add_argument('--lz4', type=Path)
    args = parser.parse_args()
    index = {}

    def add(data):
        index[hashlib.sha256(data).hexdigest()] = data

    add(unpack((args.boot_unpacked / 'kernel').read_bytes(), args.lz4))
    add((args.images / 'dtbo.img').read_bytes())
    for data in split_dtbs((args.vendor_boot_unpacked / 'dtb').read_bytes()):
        add(data)
    for p in sorted(args.vendor_boot_unpacked.glob('vendor_ramdisk*')):
        if p.is_file():
            for _, data in cpio_files(unpack(p.read_bytes(), args.lz4)):
                add(data)
    for partition in ('system_dlkm', 'vendor_dlkm'):
        for p in sorted((args.dump / partition).rglob('*.ko')):
            add(p.read_bytes())
    prefix = 'device/xiaomi/sheng/kernel/prebuilt/'
    rows = [x for x in json.loads(args.manifest.read_text())['files'] if x['destination'].startswith(prefix)]
    missing, copied = [], 0
    root = args.output.resolve()
    for row in rows:
        if row['destination'].endswith('/hid-nanosic-capslock.ko'):
            continue  # Built from the included GPL module source.
        relative = Path(row['destination'].removeprefix(prefix))
        dest = (root / relative).resolve()
        if not dest.is_relative_to(root):
            raise ValueError('Unsafe kernel destination')
        data = index.get(row['sha256'])
        if data is None:
            missing.append(str(relative))
            continue
        if dest.exists() and dest.read_bytes() != data:
            raise ValueError('Refusing to overwrite a different kernel input')
        dest.parent.mkdir(parents=True, exist_ok=True)
        dest.write_bytes(data)
        copied += 1
    print(json.dumps({'copied': copied, 'missing': missing}, indent=2))
    if missing:
        raise SystemExit(2)


if __name__ == '__main__':
    main()
