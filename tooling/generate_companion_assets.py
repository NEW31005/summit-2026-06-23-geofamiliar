from __future__ import annotations

import argparse
from collections import deque
from pathlib import Path

from PIL import Image, ImageChops, ImageDraw, ImageEnhance, ImageFilter


TRAITS = [
    ("vitality", "#ff8a65"),
    ("calm", "#4dd0b1"),
    ("curiosity", "#ffc04d"),
    ("warmth", "#ff6f91"),
    ("focus", "#5c9dff"),
    ("wonder", "#b388ff"),
]

STAGES = [
    ("hatchling", 0.82),
    ("wanderer", 0.9),
    ("kindred", 0.97),
    ("luminary", 1.0),
]

MOODS = ["normal", "happy", "rest"]


def _is_background(pixel: tuple[int, int, int, int]) -> bool:
    r, g, b, _ = pixel
    # The AI reference uses a warm cream paper background. Restrict removal to
    # edge-connected bright cream pixels so white fur inside line art remains.
    return r > 205 and g > 195 and b > 168 and max(r, g, b) - min(r, g, b) < 76


def remove_edge_background(cell: Image.Image) -> Image.Image:
    rgba = cell.convert("RGBA")
    width, height = rgba.size
    pixels = rgba.load()
    visited = set()
    queue: deque[tuple[int, int]] = deque()

    for x in range(width):
        queue.append((x, 0))
        queue.append((x, height - 1))
    for y in range(height):
        queue.append((0, y))
        queue.append((width - 1, y))

    while queue:
        x, y = queue.popleft()
        if (x, y) in visited or x < 0 or y < 0 or x >= width or y >= height:
            continue
        visited.add((x, y))
        if not _is_background(pixels[x, y]):
            continue
        pixels[x, y] = (255, 255, 255, 0)
        queue.extend(((x + 1, y), (x - 1, y), (x, y + 1), (x, y - 1)))

    alpha = rgba.getchannel("A")
    alpha = alpha.filter(ImageFilter.GaussianBlur(0.55))
    rgba.putalpha(alpha)
    bbox = alpha.getbbox()
    if bbox is None:
        return rgba
    pad = 16
    left = max(0, bbox[0] - pad)
    top = max(0, bbox[1] - pad)
    right = min(width, bbox[2] + pad)
    bottom = min(height, bbox[3] + pad)
    return rgba.crop((left, top, right, bottom))


def crop_reference_forms(source: Image.Image) -> list[Image.Image]:
    width, height = source.size
    cell_w = width // 3
    cell_h = height // 2
    crops: list[Image.Image] = []
    for row in range(2):
        for col in range(3):
            left = col * cell_w
            upper = row * cell_h
            right = width if col == 2 else (col + 1) * cell_w
            lower = height if row == 1 else (row + 1) * cell_h
            cell = source.crop((left, upper, right, lower))
            crops.append(remove_edge_background(cell))
    return crops


def contain(subject: Image.Image, size: int, scale: float) -> Image.Image:
    canvas = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    subj = subject.copy()
    bbox = subj.getchannel("A").getbbox()
    if bbox:
        subj = subj.crop(bbox)
    max_side = int(size * scale)
    subj.thumbnail((max_side, max_side), Image.Resampling.LANCZOS)
    x = (size - subj.width) // 2
    y = int((size - subj.height) * 0.56)
    canvas.alpha_composite(subj, (x, y))
    return canvas


def add_stage_overlay(sprite: Image.Image, stage: str, trait_color: str) -> Image.Image:
    out = sprite.copy()
    draw = ImageDraw.Draw(out, "RGBA")
    color = tuple(int(trait_color[i : i + 2], 16) for i in (1, 3, 5))

    if stage in {"wanderer", "kindred", "luminary"}:
        draw.arc((54, 54, 458, 458), 205, 332, fill=(*color, 90), width=7)
        draw.ellipse((242, 420, 270, 448), fill=(255, 255, 255, 170), outline=(*color, 170), width=3)
    if stage in {"kindred", "luminary"}:
        draw.rounded_rectangle((158, 394, 354, 428), radius=18, fill=(35, 43, 56, 150))
        draw.rounded_rectangle((174, 400, 338, 420), radius=12, fill=(*color, 205))
        draw.ellipse((238, 392, 274, 428), fill=(255, 240, 160, 230), outline=(120, 83, 25, 150), width=2)
    if stage == "luminary":
        glow = Image.new("RGBA", out.size, (0, 0, 0, 0))
        g = ImageDraw.Draw(glow, "RGBA")
        g.ellipse((38, 38, 474, 474), outline=(*color, 105), width=9)
        g.ellipse((78, 78, 434, 434), outline=(255, 255, 255, 92), width=5)
        for x, y in [(128, 118), (388, 122), (422, 316), (92, 330)]:
            g.polygon(
                [(x, y - 17), (x + 6, y - 6), (x + 17, y), (x + 6, y + 6), (x, y + 17), (x - 6, y + 6), (x - 17, y), (x - 6, y - 6)],
                fill=(255, 242, 160, 220),
            )
        out = Image.alpha_composite(glow.filter(ImageFilter.GaussianBlur(0.2)), out)
    return out


def add_mood_overlay(sprite: Image.Image, mood: str, trait_color: str) -> Image.Image:
    out = sprite.copy()
    color = tuple(int(trait_color[i : i + 2], 16) for i in (1, 3, 5))
    if mood == "happy":
        out = ImageEnhance.Brightness(out).enhance(1.06)
        out = ImageEnhance.Color(out).enhance(1.08)
        draw = ImageDraw.Draw(out, "RGBA")
        for x, y, r in [(118, 154, 10), (382, 142, 8), (410, 258, 7), (92, 282, 7)]:
            draw.ellipse((x - r, y - r, x + r, y + r), fill=(255, 226, 92, 210))
            draw.ellipse((x - r // 2, y - r // 2, x + r // 2, y + r // 2), fill=(255, 255, 255, 180))
    elif mood == "rest":
        subject_alpha = out.getchannel("A")
        veil = Image.new("RGBA", out.size, (80, 98, 150, 30))
        veil.putalpha(subject_alpha.point(lambda a: min(30, a * 30 // 255)))
        out = Image.alpha_composite(out, veil)
        draw = ImageDraw.Draw(out, "RGBA")
        draw.arc((366, 98, 420, 150), 90, 285, fill=(255, 255, 255, 185), width=7)
        draw.ellipse((178, 88, 192, 102), fill=(*color, 130))
        draw.ellipse((202, 70, 214, 82), fill=(255, 255, 255, 150))
    return out


def save_assets(source_path: Path, out_dir: Path, size: int) -> None:
    source = Image.open(source_path).convert("RGBA")
    forms = crop_reference_forms(source)

    for trait_index, (trait, color) in enumerate(TRAITS):
        base = forms[trait_index]
        for stage, scale in STAGES:
            stage_dir = out_dir / stage
            stage_dir.mkdir(parents=True, exist_ok=True)
            for mood in MOODS:
                sprite = contain(base, size=size, scale=scale)
                sprite = add_stage_overlay(sprite, stage, color)
                sprite = add_mood_overlay(sprite, mood, color)
                sprite.save(stage_dir / f"{trait}_{mood}.png")


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--source", required=True, type=Path)
    parser.add_argument("--out", required=True, type=Path)
    parser.add_argument("--size", default=512, type=int)
    args = parser.parse_args()

    save_assets(args.source, args.out, args.size)


if __name__ == "__main__":
    main()
