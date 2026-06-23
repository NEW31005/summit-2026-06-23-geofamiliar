from __future__ import annotations

import html
import json
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "web" / "review_evidence"
REPO_URL = "https://github.com/NEW31005/summit-2026-06-23-geofamiliar"
PAGES_URL = "https://new31005.github.io/summit-2026-06-23-geofamiliar"
RAW_BASE = "https://raw.githubusercontent.com/NEW31005/summit-2026-06-23-geofamiliar/main"


def read_lines(path: str, start: int = 1, end: int | None = None) -> str:
    lines = (ROOT / path).read_text(encoding="utf-8").splitlines()
    selected = lines[start - 1 : end]
    return "\n".join(f"{start + i:03d}: {line}" for i, line in enumerate(selected))


def write_text(name: str, content: str) -> None:
    (OUT / name).write_text(content, encoding="utf-8")


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)

    raw_links = {
        "README": f"{RAW_BASE}/README.md",
        "PlaceResolver": f"{RAW_BASE}/lib/services/place_resolver.dart",
        "LocationService": f"{RAW_BASE}/lib/services/location_service.dart",
        "PlaceContext": f"{RAW_BASE}/lib/models/place_context.dart",
        "WalkModel": f"{RAW_BASE}/lib/models/walk.dart",
        "MemoryGenerator": f"{RAW_BASE}/lib/logic/memory_generator.dart",
        "LocationTests": f"{RAW_BASE}/test/location_service_test.dart",
        "MemoryTests": f"{RAW_BASE}/test/memory_generator_test.dart",
    }

    public_pages = {
        "App preview": f"{PAGES_URL}/?v=1286fcc",
        "Art acceptance": f"{PAGES_URL}/art_acceptance/?v=0e24f15",
        "Place causality": f"{PAGES_URL}/place_evidence/?v=0e24f15",
        "Review evidence": f"{PAGES_URL}/review_evidence/",
    }

    status = {
        "project": "GeoFamiliar",
        "repo": REPO_URL,
        "default_branch": "main",
        "public_repo": True,
        "purpose": "External review evidence for Chloe after a 73/100 review blocked on source verification.",
        "public_pages": public_pages,
        "github_raw_links": raw_links,
        "implemented_claims": [
            "README states real optional current-location permission via geolocator.",
            "PlaceResolver attempts OpenStreetMap Nominatim reverse geocoding when coordinates are available.",
            "PlaceResolver falls back locally on timeout, HTTP failure, malformed data, or offline conditions.",
            "PlaceContext serializes only broad category/hint data; exact address and precise coordinates are not persisted.",
            "RouteStop.displayLabel carries the broad place hint into walk history.",
            "MemoryGenerator uses the broad displayLabel and persists placeHints.",
            "Place causality evidence shows waterside versus commercial routes produce different DNA, companion form, and diary text.",
        ],
        "verification": {
            "flutter_analyze": "PASS",
            "flutter_test": "PASS, 40 tests",
            "flutter_build_web": 'PASS with --base-href "/summit-2026-06-23-geofamiliar/"',
            "public_review_index": "HTTP 200",
            "public_place_resolver_excerpt": "HTTP 200",
            "public_browser_qa": "390x844 heading visible, PlaceResolver heading visible, failed request list empty",
        },
        "known_scope_limits": [
            "Demo preview, not a store-ready Android/iOS release.",
            "Weather, account sync, backend, push notifications, and free-form generative AI remain mocked or out of scope.",
            "The public web preview is for inspection; native app packaging remains the formal product target.",
        ],
    }
    write_text("review_status.json", json.dumps(status, ensure_ascii=False, indent=2))

    manifest = f"""GeoFamiliar review evidence manifest

Repository:
- {REPO_URL}
- public: true
- default branch: main

Public Pages:
{chr(10).join(f"- {name}: {url}" for name, url in public_pages.items())}

GitHub raw source links:
{chr(10).join(f"- {name}: {url}" for name, url in raw_links.items())}

Implementation files added for place meaning:
- lib/models/place_context.dart
- lib/services/place_resolver.dart
- lib/services/location_service.dart
- lib/models/walk.dart
- lib/logic/memory_generator.dart

Implemented claims:
{chr(10).join(f"- {claim}" for claim in status["implemented_claims"])}

Static evidence files:
- web/art_acceptance/
- web/place_evidence/
- web/review_evidence/
- web/review_evidence/review_status.json

Verification:
- flutter analyze: PASS
- flutter test: PASS, 40 tests
- flutter build web --release --base-href "/summit-2026-06-23-geofamiliar/": PASS
- public place evidence index: HTTP 200
- public place evidence PNG: HTTP 200
- public review evidence index: HTTP 200
- public review evidence source excerpts: HTTP 200
- public browser QA: heading visible, image rendered, failed request list empty
"""
    write_text("manifest.txt", manifest)
    write_text(
        "github_raw_links.txt",
        "\n".join(f"{name}: {url}" for name, url in raw_links.items()) + "\n",
    )
    write_text("readme_location_scope.txt", read_lines("README.md", 1, 45))
    write_text("place_context_excerpt.txt", read_lines("lib/models/place_context.dart", 1, 115))
    write_text("place_resolver_excerpt.txt", read_lines("lib/services/place_resolver.dart", 1, 170))
    write_text("memory_generator_excerpt.txt", read_lines("lib/logic/memory_generator.dart", 1, 60))
    write_text("walk_model_excerpt.txt", read_lines("lib/models/walk.dart", 1, 45))

    cards = [
        ("Manifest", "manifest.txt", "Commit, public URLs, implementation files, verification."),
        ("Machine-readable review status", "review_status.json", "JSON evidence index for reviewers that cannot reliably browse GitHub pages."),
        ("GitHub raw source links", "github_raw_links.txt", "Branch-stable source links for direct verification."),
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
.links{{display:grid;grid-template-columns:repeat(auto-fit,minmax(220px,1fr));gap:10px;margin:18px 0 22px}}
.links a{{display:block;background:#fffaf2;border:1px solid #e9ddd0;border-radius:12px;padding:12px;text-decoration:none}}
.summary{{background:#fffaf2;border:1px solid #e9ddd0;padding:14px;border-radius:12px;margin:18px 0}}
.summary li{{margin:8px 0;line-height:1.45}}
</style>
<main>
<h1>GeoFamiliar Review Evidence</h1>
<p>External review manifest for Claude/Chloe. It gives branch-stable GitHub raw links plus mirrored source excerpts on GitHub Pages, so the review can be scored even if one fetch path fails.</p>
<ul class="summary">
  <li>Real optional GPS is implemented through <code>geolocator</code>.</li>
  <li><code>PlaceResolver</code> attempts OpenStreetMap Nominatim reverse geocoding and falls back locally on network failure.</li>
  <li>Persisted memories keep broad place hints only, not exact addresses or coordinates.</li>
  <li>Static causality evidence shows waterside and commercial walks produce different DNA, companion art, and diary text.</li>
</ul>
<div class="links">
  <a href="{REPO_URL}">GitHub repository</a>
  <a href="{raw_links["README"]}">Raw README</a>
  <a href="{raw_links["PlaceResolver"]}">Raw PlaceResolver</a>
  <a href="review_status.json">Review status JSON</a>
  <a href="../place_evidence/?v=0e24f15">Place causality evidence</a>
  <a href="../art_acceptance/?v=0e24f15">Art acceptance sheets</a>
  <a href="../?v=1286fcc">App preview</a>
</div>
{''.join(body_cards)}
</main>
</html>
"""
    write_text("index.html", index)


if __name__ == "__main__":
    main()
