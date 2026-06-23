from __future__ import annotations

import html
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "web" / "review_evidence"


def read_lines(path: str, start: int = 1, end: int | None = None) -> str:
    lines = (ROOT / path).read_text(encoding="utf-8").splitlines()
    selected = lines[start - 1 : end]
    return "\n".join(f"{start + i:03d}: {line}" for i, line in enumerate(selected))


def write_text(name: str, content: str) -> None:
    (OUT / name).write_text(content, encoding="utf-8")


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)

    manifest = """GeoFamiliar review evidence manifest

Source commit: 9814f5c
Pages deploy commit: 0e24f15

Public URLs:
- App preview: https://new31005.github.io/summit-2026-06-23-geofamiliar/?v=9814f5c
- Art acceptance: https://new31005.github.io/summit-2026-06-23-geofamiliar/art_acceptance/?v=0e24f15
- Place causality: https://new31005.github.io/summit-2026-06-23-geofamiliar/place_evidence/?v=0e24f15
- Review evidence: https://new31005.github.io/summit-2026-06-23-geofamiliar/review_evidence/?v=0e24f15

Implementation files added for place meaning:
- lib/models/place_context.dart
- lib/services/place_resolver.dart
- lib/services/location_service.dart
- lib/models/walk.dart
- lib/logic/memory_generator.dart

Static evidence files:
- web/art_acceptance/
- web/place_evidence/
- web/review_evidence/

Verification:
- flutter analyze: PASS
- flutter test: PASS, 40 tests
- flutter build web --release --base-href "/summit-2026-06-23-geofamiliar/": PASS
- public place evidence index: HTTP 200
- public place evidence PNG: HTTP 200
- public browser QA: heading visible, image rendered, failed request list empty
"""
    write_text("manifest.txt", manifest)
    write_text("readme_location_scope.txt", read_lines("README.md", 1, 45))
    write_text("place_context_excerpt.txt", read_lines("lib/models/place_context.dart", 1, 115))
    write_text("place_resolver_excerpt.txt", read_lines("lib/services/place_resolver.dart", 1, 170))
    write_text("memory_generator_excerpt.txt", read_lines("lib/logic/memory_generator.dart", 1, 60))
    write_text("walk_model_excerpt.txt", read_lines("lib/models/walk.dart", 1, 45))

    cards = [
        ("Manifest", "manifest.txt", "Commit, public URLs, implementation files, verification."),
        ("README location scope", "readme_location_scope.txt", "Real optional GPS, Nominatim, fallback, persistence boundary."),
        ("PlaceContext source", "place_context_excerpt.txt", "Broad category model and no coordinate persistence in toJson."),
        ("PlaceResolver source", "place_resolver_excerpt.txt", "Nominatim reverse geocode, timeout, cache, offline fallback."),
        ("Walk model source", "walk_model_excerpt.txt", "RouteStop carries PlaceContext and displayLabel."),
        ("Memory generator source", "memory_generator_excerpt.txt", "Memory text uses RouteStop.displayLabel and saves placeHints."),
    ]

    body_cards = []
    for title, filename, note in cards:
        text = (OUT / filename).read_text(encoding="utf-8")
        body_cards.append(
            f"""
<section>
  <h2>{html.escape(title)}</h2>
  <p>{html.escape(note)} <a href="{filename}">plain text</a></p>
  <pre>{html.escape(text)}</pre>
</section>
"""
        )

    index = f"""<!doctype html>
<html lang="ja">
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>GeoFamiliar Review Evidence</title>
<style>
body{{margin:0;font-family:system-ui,-apple-system,BlinkMacSystemFont,"Yu Gothic",sans-serif;background:#f7f1e8;color:#2f2a25}}
main{{max-width:1040px;margin:0 auto;padding:28px 18px 48px}}
h1{{font-size:30px;margin:0 0 8px}}
h2{{font-size:20px;margin:28px 0 8px}}
p{{color:#6d6257;line-height:1.6}}
a{{color:#1c7f6a;font-weight:700}}
pre{{white-space:pre-wrap;overflow:auto;background:#fffaf2;border:1px solid #e9ddd0;border-radius:12px;padding:14px;font-size:12.5px;line-height:1.45;color:#3d352f}}
.links{{display:grid;gap:10px;margin:18px 0 22px}}
.links a{{display:block;background:#fffaf2;border:1px solid #e9ddd0;border-radius:12px;padding:12px;text-decoration:none}}
</style>
<main>
<h1>GeoFamiliar Review Evidence</h1>
<p>Claude/Chloe review用の検証マニフェストです。GitHub raw が取得できない場合でも、Pages上でREADME範囲・実装ファイル抜粋・検証URLを確認できます。</p>
<div class="links">
  <a href="../place_evidence/?v=0e24f15">Place causality evidence</a>
  <a href="../art_acceptance/?v=0e24f15">Art acceptance sheets</a>
  <a href="../?v=9814f5c">App preview</a>
</div>
{''.join(body_cards)}
</main>
</html>
"""
    write_text("index.html", index)


if __name__ == "__main__":
    main()
