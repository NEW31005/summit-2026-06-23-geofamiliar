from __future__ import annotations

from pathlib import Path

from PIL import Image, ImageDraw, ImageFont


ROOT = Path(__file__).resolve().parents[1]
ASSET_ROOT = ROOT / "assets" / "companion"
OUT = ROOT / "web" / "place_evidence"

FONT_CANDIDATES = [
    Path("C:/Windows/Fonts/YuGothB.ttc"),
    Path("C:/Windows/Fonts/meiryob.ttc"),
    Path("C:/Windows/Fonts/arialbd.ttf"),
]

TRAITS = [
    ("vitality", "活力", "#ff8a65"),
    ("calm", "静けさ", "#4dd0b1"),
    ("curiosity", "好奇心", "#ffc04d"),
    ("warmth", "ぬくもり", "#ff6f91"),
    ("focus", "集中", "#5c9dff"),
    ("wonder", "不思議", "#b388ff"),
]


def font(size: int) -> ImageFont.ImageFont:
    for candidate in FONT_CANDIDATES:
        if candidate.exists():
            return ImageFont.truetype(str(candidate), size=size)
    return ImageFont.load_default()


TITLE_FONT = font(34)
HEADING_FONT = font(25)
LABEL_FONT = font(18)
SMALL_FONT = font(15)


def load_avatar(trait: str) -> Image.Image:
    image = Image.open(ASSET_ROOT / "kindred" / f"{trait}_normal.png").convert("RGBA")
    image.thumbnail((220, 220), Image.Resampling.LANCZOS)
    return image


def draw_text_box(
    draw: ImageDraw.ImageDraw,
    xy: tuple[int, int],
    width: int,
    text: str,
    fill: str,
    font_obj: ImageFont.ImageFont = SMALL_FONT,
    line_height: int = 24,
) -> None:
    x, y = xy
    line = ""
    cursor_y = y
    for char in text:
        trial = line + char
        if draw.textlength(trial, font=font_obj) <= width:
            line = trial
            continue
        draw.text((x, cursor_y), line, font=font_obj, fill=fill)
        cursor_y += line_height
        line = char
    if line:
        draw.text((x, cursor_y), line, font=font_obj, fill=fill)


def draw_dna(draw: ImageDraw.ImageDraw, x: int, y: int, values: dict[str, float]) -> None:
    max_value = max(values.values())
    for index, (key, label, color) in enumerate(TRAITS):
        yy = y + index * 31
        value = values.get(key, 0)
        draw.text((x, yy), label, font=SMALL_FONT, fill="#514941")
        draw.rounded_rectangle((x + 78, yy + 4, x + 250, yy + 18), radius=7, fill="#efe4d8")
        draw.rounded_rectangle(
            (x + 78, yy + 4, x + 78 + int(172 * value / max_value), yy + 18),
            radius=7,
            fill=color,
        )
        draw.text((x + 262, yy - 1), f"{value:.1f}", font=SMALL_FONT, fill="#514941")


def draw_route_card(
    canvas: Image.Image,
    x: int,
    y: int,
    title: str,
    route: str,
    category: str,
    avatar_trait: str,
    form: str,
    dna: dict[str, float],
    diary: str,
    accent: str,
) -> None:
    draw = ImageDraw.Draw(canvas)
    w, h = 520, 620
    draw.rounded_rectangle((x, y, x + w, y + h), radius=22, fill="#fffaf2", outline="#e9ddd0", width=2)
    draw.rounded_rectangle((x, y, x + w, y + 74), radius=22, fill=accent)
    draw.rectangle((x, y + 48, x + w, y + 74), fill=accent)
    draw.text((x + 22, y + 20), title, font=HEADING_FONT, fill="#2f2a25")
    draw.text((x + 22, y + 92), route, font=LABEL_FONT, fill="#2f2a25")
    draw.text((x + 22, y + 122), f"保存ヒント: {category}", font=SMALL_FONT, fill="#6d6257")

    avatar = load_avatar(avatar_trait)
    canvas.alpha_composite(avatar, (x + 292, y + 142))
    draw.text((x + 22, y + 166), f"結果フォーム: {form}", font=LABEL_FONT, fill="#2f2a25")
    draw.text((x + 22, y + 198), "生活圏DNA", font=SMALL_FONT, fill="#6d6257")
    draw_dna(draw, x + 22, y + 226, dna)

    draw.rounded_rectangle((x + 22, y + 456, x + w - 22, y + h - 28), radius=16, fill="#f7f1e8")
    draw.text((x + 42, y + 474), "生成される記憶", font=LABEL_FONT, fill="#2f2a25")
    draw_text_box(draw, (x + 42, y + 508), w - 84, diary, "#514941")


def make_causality_sheet() -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    canvas = Image.new("RGBA", (1160, 790), "#f7f1e8")
    draw = ImageDraw.Draw(canvas)
    draw.text((46, 34), "Place causality evidence", font=TITLE_FONT, fill="#2f2a25")
    draw_text_box(
        draw,
        (48, 82),
        1030,
        "同じ初期条件から、場所カテゴリだけを変えた時に、生活圏DNA・相棒の姿・記憶文が分岐することを示す静的証跡。",
        "#6d6257",
        LABEL_FONT,
        30,
    )

    draw_route_card(
        canvas,
        46,
        142,
        "Waterside route x5",
        "川沿い / 水辺の近くを5回記録",
        "水辺の近く",
        "calm",
        "しずく灯",
        {
            "vitality": 0.0,
            "calm": 12.5,
            "curiosity": 0.0,
            "warmth": 0.0,
            "focus": 0.0,
            "wonder": 5.0,
        },
        "水辺の近くから水辺の近くまで、ただ息をするだけでよかったです。こんな夕方で十分です。",
        "#9fe6d7",
    )
    draw_route_card(
        canvas,
        594,
        142,
        "Commercial route x5",
        "商業地 / にぎわいの近くを5回記録",
        "商業地の近く",
        "curiosity",
        "まち角ミミ",
        {
            "vitality": 5.0,
            "calm": 0.0,
            "curiosity": 12.5,
            "warmth": 0.0,
            "focus": 0.0,
            "wonder": 0.0,
        },
        "商業地の近くに、今まで気づかなかった角がありました。ほかにも何があるのか気になります。",
        "#ffd675",
    )
    canvas.convert("RGB").save(OUT / "place_causality_waterside_vs_commercial.png", quality=95)


def write_index() -> None:
    (OUT / "index.html").write_text(
        """<!doctype html>
<html lang="ja">
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>GeoFamiliar Place Evidence</title>
<style>
body{margin:0;font-family:system-ui,-apple-system,BlinkMacSystemFont,"Yu Gothic",sans-serif;background:#f7f1e8;color:#2f2a25}
main{max-width:1040px;margin:0 auto;padding:28px 18px 40px}
h1{font-size:28px;margin:0 0 8px}
p{color:#6d6257;line-height:1.6}
img{width:100%;height:auto;border:1px solid #e9ddd0;border-radius:12px;background:white}
</style>
<main>
<h1>GeoFamiliar 場所カテゴリ因果証跡</h1>
<p>同じ初期条件から、水辺カテゴリ5回と商業地カテゴリ5回で、生活圏DNA・相棒の姿・記憶文が分岐することを示します。</p>
<img src="place_causality_waterside_vs_commercial.png" alt="waterside route versus commercial route evidence">
</main>
</html>
""",
        encoding="utf-8",
    )


def main() -> None:
    make_causality_sheet()
    write_index()


if __name__ == "__main__":
    main()
