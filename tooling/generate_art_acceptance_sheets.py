from __future__ import annotations

from pathlib import Path

from PIL import Image, ImageDraw, ImageFont


ROOT = Path(__file__).resolve().parents[1]
ASSET_ROOT = ROOT / "assets" / "companion"
OUT = ROOT / "web" / "art_acceptance"

FONT_CANDIDATES = [
    Path("C:/Windows/Fonts/YuGothB.ttc"),
    Path("C:/Windows/Fonts/meiryob.ttc"),
    Path("C:/Windows/Fonts/arialbd.ttf"),
]


def font(size: int) -> ImageFont.ImageFont:
    for candidate in FONT_CANDIDATES:
        if candidate.exists():
            return ImageFont.truetype(str(candidate), size=size)
    return ImageFont.load_default()


TITLE_FONT = font(34)
LABEL_FONT = font(22)
SMALL_FONT = font(16)


def asset(stage: str, trait: str, mood: str) -> Image.Image:
    image = Image.open(ASSET_ROOT / stage / f"{trait}_{mood}.png").convert("RGBA")
    image.thumbnail((220, 220), Image.Resampling.LANCZOS)
    return image


def draw_card(
    canvas: Image.Image,
    xy: tuple[int, int],
    title: str,
    subtitle: str,
    image: Image.Image,
    accent: str,
) -> None:
    draw = ImageDraw.Draw(canvas)
    x, y = xy
    w, h = 300, 340
    draw.rounded_rectangle((x, y, x + w, y + h), radius=18, fill="#fffaf2", outline="#e9ddd0", width=2)
    draw.rounded_rectangle((x, y, x + w, y + 58), radius=18, fill=accent)
    draw.rectangle((x, y + 38, x + w, y + 58), fill=accent)
    draw.text((x + 18, y + 15), title, font=LABEL_FONT, fill="#2f2a25")
    draw.text((x + 18, y + 68), subtitle, font=SMALL_FONT, fill="#6d6257")
    ix = x + (w - image.width) // 2
    iy = y + 104 + (190 - image.height) // 2
    canvas.alpha_composite(image, (ix, iy))


def make_sheet(filename: str, title: str, cards: list[tuple[str, str, str, str, str, str]]) -> None:
    width = 80 + len(cards) * 330
    height = 470
    canvas = Image.new("RGBA", (width, height), "#f7f1e8")
    draw = ImageDraw.Draw(canvas)
    draw.text((40, 28), title, font=TITLE_FONT, fill="#2f2a25")
    draw.text(
        (42, 72),
        "GeoFamiliar companion art acceptance sheet",
        font=SMALL_FONT,
        fill="#6d6257",
    )
    for index, (stage, trait, mood, label, subtitle, accent) in enumerate(cards):
        draw_card(canvas, (40 + index * 330, 108), label, subtitle, asset(stage, trait, mood), accent)
    canvas.convert("RGB").save(OUT / filename, quality=95)


def write_index() -> None:
    index = OUT / "index.html"
    index.write_text(
        """<!doctype html>
<html lang="ja">
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>GeoFamiliar Art Acceptance</title>
<style>
body{margin:0;font-family:system-ui,-apple-system,BlinkMacSystemFont,"Yu Gothic",sans-serif;background:#f7f1e8;color:#2f2a25}
main{max-width:980px;margin:0 auto;padding:28px 18px 40px}
h1{font-size:28px;margin:0 0 8px}
p{color:#6d6257;line-height:1.6}
section{margin-top:24px}
img{width:100%;height:auto;border:1px solid #e9ddd0;border-radius:12px;background:white}
</style>
<main>
<h1>GeoFamiliar アート検収シート</h1>
<p>クロエ指摘の受入条件に合わせて、特性差・進化段階差・表情差を同一条件で比較するための静的証跡です。</p>
<section><h2>特性差: hatchling / happy</h2><img src="trait_comparison.png" alt="trait comparison"></section>
<section><h2>進化差: vitality / normal</h2><img src="evolution_vitality.png" alt="evolution comparison"></section>
<section><h2>表情差: hatchling / vitality</h2><img src="mood_vitality.png" alt="mood comparison"></section>
</main>
</html>
""",
        encoding="utf-8",
    )


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    make_sheet(
        "trait_comparison.png",
        "Trait comparison - hatchling / happy",
        [
            ("hatchling", "vitality", "happy", "vitality heavy", "勢い・活動量が強い個体", "#ffb199"),
            ("hatchling", "warmth", "happy", "warmth heavy", "親密さ・ぬくもりが強い個体", "#ffabc0"),
        ],
    )
    make_sheet(
        "evolution_vitality.png",
        "Evolution comparison - vitality / normal",
        [
            ("hatchling", "vitality", "normal", "hatchling", "生まれたばかり", "#ffd0bf"),
            ("wanderer", "vitality", "normal", "wanderer", "外へ出始める", "#ffc0aa"),
            ("kindred", "vitality", "normal", "kindred", "関係が深まる", "#ffae92"),
            ("luminary", "vitality", "normal", "luminary", "成熟した光", "#ff9b7d"),
        ],
    )
    make_sheet(
        "mood_vitality.png",
        "Mood comparison - hatchling / vitality",
        [
            ("hatchling", "vitality", "normal", "normal", "通常の表情", "#ffd0bf"),
            ("hatchling", "vitality", "happy", "happy", "うれしい表情", "#ffc0aa"),
            ("hatchling", "vitality", "rest", "rest", "休んでいる表情", "#ffae92"),
        ],
    )
    write_index()


if __name__ == "__main__":
    main()
