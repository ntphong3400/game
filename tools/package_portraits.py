"""Package original image_gen triptychs and build a local review gallery.

Run with Python 3 after image generation; requires cwebp in PATH.
This only encodes the original art, without retouching or inventing portraits.
"""

import hashlib
import html
import json
import shutil
import struct
import subprocess
from collections import Counter
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OUTPUT = ROOT / "output/avatar-generation"
ASSETS = ROOT / "assets/images/portraits"


def main():
    spec = json.loads((OUTPUT / "prompts.json").read_text())
    members = spec["specs"]
    assert len(members) == 91
    assert Counter(s["group"] for s in members) == {
        "emperor": 1, "official": 60, "harem": 30
    }
    encoder = shutil.which("cwebp")
    if not encoder:
        raise SystemExit("cwebp is required to encode WebP assets")
    ASSETS.mkdir(parents=True, exist_ok=True)
    report, seen = [], set()
    for member in members:
        identity = member["id"]
        original = OUTPUT / "source" / f"{identity}.png"
        data = original.read_bytes()
        assert data[:8] == b"\x89PNG\r\n\x1a\n", identity
        width, height = struct.unpack(">II", data[16:24])
        # image_gen may round the canvas by a few pixels; allow <= 2% before
        # normalizing the whole triptych to the exact runtime 3:1 layout.
        assert abs(width / height - 3) < 0.06, (identity, width, height)
        digest = hashlib.sha256(data).hexdigest()
        assert digest not in seen, f"Duplicate source art: {identity}"
        seen.add(digest)
        asset = ASSETS / f"{identity}.webp"
        if not asset.exists() or original.stat().st_mtime > asset.stat().st_mtime:
            subprocess.run([
                encoder, "-quiet", "-q", "85", "-resize", "1536", "512",
                str(original), "-o", str(asset)
            ], check=True)
        report.append({
            "id": identity, "group": member["group"],
            "sourceSize": [width, height], "sourceSha256": digest,
            "asset": str(asset.relative_to(ROOT)), "bytes": asset.stat().st_size,
            "sha256": hashlib.sha256(asset.read_bytes()).hexdigest(),
        })
    expected = {f"{s['id']}.webp" for s in members}
    assert {p.name for p in ASSETS.glob("*.webp")} == expected
    summary = {
        "method": "built-in image_gen", "identities": 91, "agePortraits": 273,
        "assetBytes": sum(s["bytes"] for s in report),
        "ageThresholds": [35, 55], "assetSize": [1536, 512], "assets": report,
    }
    (OUTPUT / "manifest.json").write_text(json.dumps(summary, indent=2) + "\n")
    gallery = []
    for member in members:
        identity, group = member["id"], member["group"]
        frames = "".join(
            f'<div><div class="face" style="background-image:url(../../assets/images/portraits/{identity}.webp);background-position:{i * 50}% center"></div><small>{age}</small></div>'
            for i, age in enumerate(["Trẻ · 25", "Trung niên · 45", "Lão niên · 65"])
        )
        gallery.append(f'<article data-group="{group}"><h2>{html.escape(identity)}</h2><div class="frames">{frames}</div></article>')
    page = '''<!doctype html><html lang="vi"><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>Vạn Tuế · 91 diện mạo</title><style>
*{box-sizing:border-box}body{margin:0;background:#ede5d2;color:#263d33;font:16px system-ui}header{position:sticky;top:0;background:#16372ff5;color:#fff1ce;padding:22px 4vw;z-index:1;box-shadow:0 4px 15px #0002}h1{font:30px Georgia;margin:0 0 8px}p{margin:6px 0 16px}nav{display:flex;gap:8px;flex-wrap:wrap}button{border:1px solid #d9b873;background:transparent;color:inherit;padding:8px 15px;border-radius:20px;cursor:pointer}button.active{background:#d9b873;color:#16372f}main{padding:24px 3vw;display:grid;grid-template-columns:repeat(auto-fit,minmax(380px,1fr));gap:18px}article{padding:12px;background:#fff8e9;border:1px solid #c9b18a;border-radius:10px}article[hidden]{display:none}h2{font-size:14px;letter-spacing:1px;margin:0 0 10px}.frames{display:grid;grid-template-columns:repeat(3,1fr);gap:6px}.face{width:100%;aspect-ratio:1;background-size:300% 100%;border-radius:5px}small{display:block;text-align:center;font-size:12px;padding:7px 0 0;color:#665b46}@media(max-width:450px){main{grid-template-columns:1fr;padding:12px}}
</style><header><h1>Vạn Tuế · Chân dung theo tuổi</h1><p>91 diện mạo · 273 chân dung — Trẻ dưới 35 · Trung niên 35–54 · Lão niên từ 55</p><nav><button class="active" data-filter="all">Tất cả · 91</button><button data-filter="emperor">Hoàng đế · 1</button><button data-filter="official">Triều thần · 60</button><button data-filter="harem">Hậu cung · 30</button></nav></header><main>'''
    page += "\n".join(gallery)
    page += '''</main><script>document.querySelectorAll('button').forEach(b=>b.onclick=()=>{document.querySelectorAll('button').forEach(x=>x.classList.toggle('active',x===b));document.querySelectorAll('article').forEach(a=>a.hidden=b.dataset.filter!=='all'&&a.dataset.group!==b.dataset.filter)});</script></html>'''
    (OUTPUT / "review.html").write_text(page)
    print(f"Packaged {len(report)} identities / 273 age portraits; {summary['assetBytes'] / 1024 / 1024:.2f} MiB")
    print(f"Gallery: {OUTPUT / 'review.html'}")


if __name__ == "__main__":
    main()
