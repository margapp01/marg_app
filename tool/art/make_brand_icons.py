"""Builds MARG's icon family from the official logo (tool/art/icon/marg_source.png).

The source is the mark on a cream rounded tile with a drop shadow, on a
transparent 1024² canvas. Used as-is it reads as a "tile inside a tile" with
gaps all round. This script crops it to the tile, lifts the mark off the tile
(colour-to-alpha against the tile's cream) and composes:

  assets/branding/logo/marg.png               512² full-bleed logo (tile edge to edge, square corners)
  assets/branding/logo/marg_mark.png          mark only, transparent, tight crop
  tool/art/icon/app_icon.png                  1024² opaque cream icon (iOS / legacy Android)
  tool/art/icon/app_icon_foreground.png       1024² adaptive-icon foreground (safe zone)
  tool/art/icon/app_icon_monochrome.png       1024² Android 13 themed-icon silhouette
  (icon sources live outside assets/ so they aren't bundled; then run
   `dart run flutter_launcher_icons`)
  android/.../drawable-*/ic_stat_marg.png     white status-bar notification silhouette
  android/.../drawable-*/android12splash.png  Android 12+ splash icon (mark in the 2/3 circle)
  android/.../drawable-*/splash.png           pre-12 native splash (mark only)
  ios/.../LaunchImage*.png                    iOS launch image (mark only)

Run from marg_app/:  python3 tool/art/make_brand_icons.py
"""
from pathlib import Path

from statistics import median

from PIL import Image, ImageChops, ImageFilter

ROOT = Path(__file__).resolve().parents[2]
LOGO = ROOT / 'tool/art/icon/marg_source.png'
OUT_LOGO = ROOT / 'assets/branding/logo'
OUT_ICON = ROOT / 'tool/art/icon'
RES = ROOT / 'android/app/src/main/res'
IOS_LAUNCH = ROOT / 'ios/Runner/Assets.xcassets/LaunchImage.imageset'

CREAM = (253, 249, 243)  # AppColors.background — icon + splash canvas
DENSITIES = {'mdpi': 1, 'hdpi': 1.5, 'xhdpi': 2, 'xxhdpi': 3, 'xxxhdpi': 4}


def full_bleed_logo(size: int) -> Image.Image:
    """The tile alone, edge to edge: no shadow, no padding, square corners."""
    src = Image.open(LOGO).convert('RGBA')
    # Tile body with holes closed, anti-aliased rim + edge highlight eroded.
    body = src.split()[3].point(lambda v: 255 if v > 128 else 0)
    body = body.filter(ImageFilter.MaxFilter(15)).filter(ImageFilter.MinFilter(15))
    body = body.filter(ImageFilter.MinFilter(7))
    box = body.getbbox()
    tile, mask = src.crop(box), body.crop(box)
    side = max(tile.size)
    ox, oy = (side - tile.width) // 2, (side - tile.height) // 2

    # Translucent glyph-edge pixels are composited over the local cream.
    cream = tile.convert('RGB').filter(ImageFilter.MedianFilter(9))
    flat = Image.new('RGB', (side, side))
    flat.paste(Image.composite(tile.convert('RGB'), cream, tile.split()[3]), (ox, oy))
    known = Image.new('L', (side, side), 0)
    known.paste(mask, (ox, oy))

    # Rounded corners + square padding: walk toward the centre to the first
    # tile pixel, step a little further in, and take a 5x5 average — so the
    # fill follows the tile's own edge shading with no visible seam.
    fp, kp = flat.load(), known.load()
    c = side / 2
    for y in range(side):
        for x in range(side):
            if kp[x, y]:
                continue
            n = max(abs(c - x), abs(c - y))
            sx, sy = (c - x) / n, (c - y) / n
            t = 0
            while not kp[int(x + sx * t), int(y + sy * t)]:
                t += 1
            px, py = int(x + sx * (t + 4)), int(y + sy * (t + 4))
            win = [fp[i, j] for i in range(px - 2, px + 3) for j in range(py - 2, py + 3) if kp[i, j]]
            fp[x, y] = tuple(sum(p[k] for p in win) // len(win) for k in range(3))
    return flat.resize((size, size), Image.LANCZOS).convert('RGBA')


def lift_mark() -> Image.Image:
    """The mark on transparent: colour-to-alpha against the tile's cream."""
    src = Image.open(LOGO).convert('RGBA')
    w, h = src.size
    # The tile: its opaque body with holes closed (a few glyph-edge pixels in
    # the source are semi-transparent), then the anti-aliased rim eroded.
    body = src.split()[3].point(lambda v: 255 if v > 128 else 0)
    body = body.filter(ImageFilter.MaxFilter(15)).filter(ImageFilter.MinFilter(15))
    rim = body.filter(ImageFilter.MinFilter(9))

    px = list(src.getdata())
    tile = list(rim.getdata())
    bright = [p for p, t in zip(px, tile) if t and p[3] > 250 and min(p[:3]) > 235]
    c = tuple(median(p[i] for p in bright) for i in range(3))

    # Colour-to-alpha against the cream, darker-than-tile direction only: the
    # mark is navy + saffron (both darker in some channel), while the tile's
    # own glow is *brighter* than its median and must not be lifted.
    out = []
    for p, t in zip(px, tile):
        if not t:
            out.append((0, 0, 0, 0))
            continue
        k = p[3] / 255  # flatten any translucent source pixel onto the cream
        q = tuple(p[i] * k + c[i] * (1 - k) for i in range(3))
        darker = [(c[i] - q[i]) / c[i] for i in range(3) if q[i] < c[i]]
        a = max(darker) if darker else 0.0
        if a < 0.1:  # tile grain / warm gradient
            out.append((0, 0, 0, 0))
            continue
        a = min(a, 1.0)
        rgb = tuple(int(max(0, min(255, c[i] - (c[i] - q[i]) / a))) for i in range(3))
        out.append((*rgb, int(a * 255)))
    img = Image.new('RGBA', (w, h))
    img.putdata(out)
    img.putalpha(img.split()[3].filter(ImageFilter.MedianFilter(3)))  # lone grain specks
    return img.crop(img.split()[3].getbbox())


def fade_tail(mark: Image.Image, start: float = 0.86) -> Image.Image:
    """The path is cut by the tile's bottom edge — dissolve it softly instead."""
    w, h = mark.size
    s = int(h * start)
    ramp = Image.new('L', (w, h), 255)
    for y in range(s, h):
        t = (y - s) / max(h - 1 - s, 1)
        v = int(255 * (1 - t) ** 1.4)
        ramp.paste(v, (0, y, w, y + 1))
    mark = mark.copy()
    mark.putalpha(ImageChops.multiply(mark.split()[3], ramp))
    return mark


def place(mark: Image.Image, canvas: int, height_frac: float, bg=None, y_bias: float = 0.0) -> Image.Image:
    """[mark] scaled to [height_frac] of a square canvas, centred."""
    h = int(canvas * height_frac)
    w = int(mark.width * h / mark.height)
    m = mark.resize((w, h), Image.LANCZOS)
    out = Image.new('RGBA', (canvas, canvas), (*bg, 255) if bg else (0, 0, 0, 0))
    out.alpha_composite(m, ((canvas - w) // 2, (canvas - h) // 2 + int(canvas * y_bias)))
    return out


def shape_of(mark: Image.Image) -> Image.Image:
    """The mark's shape in white on transparent (status bar / themed icons)."""
    a = mark.split()[3].point(lambda v: 255 if v > 90 else 0)
    shape = Image.new('RGBA', mark.size, (255, 255, 255, 0))
    shape.putalpha(a)
    return shape


def silhouette(mark: Image.Image, px: int) -> Image.Image:
    """White status-bar icon, fitted inside the 24dp grid."""
    return place(shape_of(mark), px, 0.92)


def main():
    OUT_ICON.mkdir(parents=True, exist_ok=True)
    full_bleed_logo(512).save(OUT_LOGO / 'marg.png', optimize=True)
    mark = fade_tail(lift_mark())
    mark.save(OUT_LOGO / 'marg_mark.png')

    place(mark, 1024, 0.80, bg=CREAM).convert('RGB').save(OUT_ICON / 'app_icon.png')
    # Adaptive icons show the centre 72/108 of the canvas (66/108 always safe).
    place(mark, 1024, 0.60).save(OUT_ICON / 'app_icon_foreground.png')
    place(shape_of(mark), 1024, 0.60).save(OUT_ICON / 'app_icon_monochrome.png')

    for d, s in DENSITIES.items():
        folder = RES / f'drawable-{d}'
        folder.mkdir(parents=True, exist_ok=True)
        silhouette(mark, int(24 * s)).save(folder / 'ic_stat_marg.png')
        # Android 12 splash icon: 288dp canvas, content inside the 192dp circle.
        splash12 = place(mark, int(288 * s), 0.56)
        splash12.save(folder / 'android12splash.png')
        night = RES / f'drawable-night-{d}'
        if night.exists():
            splash12.save(night / 'android12splash.png')
        place(mark, int(256 * s / 1.0 * 0.75), 0.9).save(folder / 'splash.png')

    for name, scale in [('LaunchImage.png', 1), ('LaunchImage@2x.png', 2), ('LaunchImage@3x.png', 3)]:
        place(mark, int(160 * scale), 0.95).save(IOS_LAUNCH / name)
    print('mark', mark.size)


if __name__ == '__main__':
    main()
