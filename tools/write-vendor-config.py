#!/usr/bin/env python3
# SPDX-License-Identifier: Apache-2.0
"""Write this device's reviewed extraction metadata and textual blob fixups."""
from pathlib import Path
import hashlib
import json

device=Path(__file__).resolve().parents[1]
tree=device.parents[2]
rows=json.loads((device/'build/vendor-config.json').read_text())['files']
actions=[]
for row in rows:
    source=device/'build/vendor-config'/row['template']
    target=(tree/row['path']).resolve()
    if not target.is_relative_to(tree/'vendor/xiaomi'):
        raise ValueError('Invalid vendor target')
    data=source.read_bytes()
    if hashlib.sha256(data).hexdigest()!=row['sha256']:
        raise ValueError('Unexpected reviewed metadata hash')
    actions.append((target,data))
for target,data in actions:
    target.parent.mkdir(parents=True,exist_ok=True)
    if not target.is_file() or target.read_bytes()!=data:
        target.write_bytes(data)
print('Wrote',len(actions),'reviewed vendor metadata files')
