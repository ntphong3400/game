"""Copy image_gen outputs and encode runtime WebP without changing proportions."""
import argparse
import hashlib
import json
from pathlib import Path
import shutil
import struct
import subprocess

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / 'output/meeting-generation'

parser = argparse.ArgumentParser()
parser.add_argument('identity')
parser.add_argument('source', type=Path)
args = parser.parse_args()
specs = json.loads((OUT / 'prompts.json').read_text())['specs']
spec = next(s for s in specs if s['id'] == args.identity)
data = args.source.read_bytes()
assert data[:8] == b'\x89PNG\r\n\x1a\n', 'Expected PNG'
width, height = struct.unpack('>II', data[16:24])
assert abs(width / height - 2/3) < 0.03, (width, height)
assert data[25] == 6, 'Expected PNG with alpha'
original = OUT / 'source' / f"{args.identity}-v{spec.get('version', 2)}.png"
original.parent.mkdir(parents=True, exist_ok=True)
shutil.copy2(args.source, original)
asset = ROOT / spec['asset']
subprocess.run(['/opt/homebrew/bin/cwebp', '-quiet', '-q', '88',
                '-alpha_q', '100', str(original), '-o', str(asset)], check=True)
receipt = {'id': args.identity, 'source': str(original.relative_to(ROOT)),
           'generation': str(args.source), 'asset': spec['asset'],
           'sourceSize': [width, height], 'bytes': asset.stat().st_size,
           'sourceSha256': hashlib.sha256(data).hexdigest(),
           'sha256': hashlib.sha256(asset.read_bytes()).hexdigest()}
(OUT / 'receipts' / f'{args.identity}.json').write_text(json.dumps(receipt, indent=2))
print(json.dumps(receipt))
