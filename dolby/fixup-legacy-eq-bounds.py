from pathlib import Path
import sys, hashlib
p=Path(sys.argv[1]);data=bytearray(p.read_bytes())
before='e72977b6d1cc8b1a9ec8c9cbad64e314fd8343430f63f7ee5636e538a6883d2b'
after='2bdd308921248504295a8a710ddbc47a94b33f5e7bc3c5e0dfdb471af2835594'
if hashlib.sha256(data).hexdigest() == after:
    sys.exit(0)
assert hashlib.sha256(data).hexdigest() == before, "Unexpected libhwdap build"
for offset, old, new in [(95456, '090580b9', '2a3a0014'), (155016, '1f2003d5', '090580b9'), (155020, '1f2003d5', '05000014'), (155040, '1f2003d5', '3f4100f1'), (155044, '1f2003d5', '05000014'), (155064, '1f2003d5', 'e898f854'), (155068, '1f2003d5', 'cac5ff17')]:
    assert data[offset:offset+4] == bytes.fromhex(old)
    data[offset:offset+4] = bytes.fromhex(new)
assert hashlib.sha256(data).hexdigest() == after
p.write_bytes(data)
