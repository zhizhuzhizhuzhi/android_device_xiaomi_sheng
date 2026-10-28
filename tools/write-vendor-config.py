#!/usr/bin/env python3
# SPDX-License-Identifier: Apache-2.0
"""Install Sheng's reviewed metadata from the shared integration repository."""
from pathlib import Path
import subprocess
import sys

tree = Path(__file__).resolve().parents[4]
installer = tree / 'vendor/xiaomi/sm8550-integration/tools/install-vendor-config.py'
if not installer.is_file():
    raise SystemExit('Missing vendor/xiaomi/sm8550-integration; sync the matching Sheng manifest first')
subprocess.run([sys.executable, str(installer), '--tree', str(tree), '--profile', 'sheng', *sys.argv[1:]], check=True)
