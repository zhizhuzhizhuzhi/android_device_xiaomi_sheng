#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-2.0-only
from pathlib import Path
import hashlib,json
p=Path(__file__).resolve().parent/'build-inputs'
for name,expected in json.loads((p/'manifest.json').read_text())['files'].items():
    if hashlib.sha256((p/name).read_bytes()).hexdigest()!=expected:
        raise SystemExit('Kernel build input mismatch: '+name)
print('Kernel module build inputs verified')
