#!/usr/bin/env python3
# SPDX-License-Identifier: Apache-2.0
"""Use the SM8550 shared input validator with this device's manifest."""
from pathlib import Path
import runpy
import sys
device = Path(__file__).resolve().parents[1]
sys.argv[1:1] = ['--manifest', str(device / 'device-inputs.json')]
runpy.run_path(str(device.parent / 'sm8550-platform-common/tools/extract-device-inputs.py'), run_name='__main__')
