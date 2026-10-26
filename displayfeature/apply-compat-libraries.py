#!/usr/bin/env python3
# SPDX-License-Identifier: Apache-2.0
"""Copy verified ABI-compatible device inputs to generated vendor trees."""
from pathlib import Path
import hashlib,json,shutil
base=Path(__file__).resolve().parent
root=base.parents[3]
for rel,item in json.loads((base/'compat-provenance.json').read_text())['vendor_targets'].items():
    target=(root/rel).resolve()
    if not target.is_relative_to(root/'vendor/xiaomi'):
        raise ValueError('Unexpected vendor destination')
    current=hashlib.sha256(target.read_bytes()).hexdigest()
    if current not in (item['original_sha256'],item['fixed_sha256']):
        raise ValueError('Unexpected vendor input: '+rel)
    source=base.parent/item['device_source']
    if hashlib.sha256(source.read_bytes()).hexdigest()!=item['fixed_sha256']:
        raise ValueError('Run tools/extract-device-inputs.py first')
    if current!=item['fixed_sha256']:
        shutil.copyfile(source,target)
