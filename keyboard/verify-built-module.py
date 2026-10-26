#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-2.0-only
"""Validate the locally rebuilt module against the recorded ABI contract."""
import argparse
import hashlib
import json
from pathlib import Path
import struct


def validate(path, contract_path=None):
    base = Path(__file__).resolve().parent
    contract = json.loads((contract_path or base / 'build-inputs/abi.json').read_text())
    if hashlib.sha256((base / 'hid-nanosic-capslock.c').read_bytes()).hexdigest() != contract['source_sha256']:
        raise ValueError('Driver source differs from the reviewed ABI contract')
    data = Path(path).read_bytes()
    if data[:6] != b'\x7fELF\x02\x01' or struct.unpack_from('<H', data, 18)[0] != 183:
        raise ValueError('Expected AArch64 ELF64 module')
    offset = struct.unpack_from('<Q', data, 40)[0]
    size, count, index = struct.unpack_from('<HHH', data, 58)
    headers = [struct.unpack_from('<IIQQQQIIQQ', data, offset + i * size) for i in range(count)]
    header = headers[index]
    strings = data[header[4]:header[4] + header[5]]
    sections = {}
    for header in headers:
        name = strings[header[0]:].split(b'\0', 1)[0].decode()
        sections[name] = data[header[4]:header[4] + header[5]]
    info = [x.decode() for x in sections['.modinfo'].split(b'\0') if x]
    for prefix in ('license=', 'description=', 'vermagic=', 'name=', 'depends=', 'alias='):
        if sorted(x for x in info if x.startswith(prefix)) != sorted(x for x in contract['modinfo'] if x.startswith(prefix)):
            raise ValueError('Module metadata mismatch: ' + prefix)
    if hashlib.sha256(sections['__versions']).hexdigest() != contract['versions_sha256']:
        raise ValueError('Kernel symbol version contract mismatch')
    return {'sha256': hashlib.sha256(data).hexdigest(), 'reference_byte_identical': hashlib.sha256(data).hexdigest() == contract['reference_module_sha256'], 'abi_verified': True}


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('module', type=Path)
    print(json.dumps(validate(parser.parse_args().module), indent=2))
