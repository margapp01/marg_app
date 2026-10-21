"""Builds the Yatra scratch-card artwork from the owner's generated images.

Sources (docs/rewards in the MARG root):
  teaser — wide shot: T-shirt, gift box and a recharge phone, calm on the left.
  won    — square flat-lay of the same prizes, for the revealed card.

Every output is 16:10 so the scratch card keeps one shape in all its states:
  yatra_reward_both.jpg    teaser, both prizes (locked card)
  yatra_reward_won.jpg     flat-lay cropped to 16:10 (revealed card, both prizes)
  yatra_reward_tshirt.jpg  teaser cropped left of the phone (T-shirt-only routes)

  python3 tool/art/make_reward_art.py [teaser.png] [won.png]
"""
import sys
from pathlib import Path

from PIL import Image

HERE = Path(__file__).resolve().parent
APP = HERE.parent.parent
SOURCES = APP.parent / 'docs' / 'rewards'
OUT = APP / 'assets' / 'images' / 'rewards'
SIZE = (1280, 800)  # 16:10
QUALITY = 80


def crop_to_ratio(img, box=None, anchor_y=0.5):
    """Crops [box] (or the whole image) to 16:10, keeping full width."""
    img = img.crop(box) if box else img
    w, h = img.size
    target_h = round(w * SIZE[1] / SIZE[0])
    if target_h <= h:
        top = round((h - target_h) * anchor_y)
        return img.crop((0, top, w, top + target_h))
    target_w = round(h * SIZE[0] / SIZE[1])
    left = (w - target_w) // 2
    return img.crop((left, 0, left + target_w, h))


def save(img, name):
    OUT.mkdir(parents=True, exist_ok=True)
    path = OUT / name
    img.convert('RGB').resize(SIZE, Image.LANCZOS).save(path, 'JPEG', quality=QUALITY, optimize=True, progressive=True)
    print(f'{path.relative_to(APP)} — {path.stat().st_size // 1024} KB')


def main(teaser_path, won_path):
    teaser = Image.open(teaser_path)
    won = Image.open(won_path)
    save(crop_to_ratio(teaser), 'yatra_reward_both.jpg')
    # The flat-lay is square: keep the band with the T-shirt, gift and phone.
    save(crop_to_ratio(won, anchor_y=0.5), 'yatra_reward_won.jpg')
    # Left of the phone (it starts ~80% across): T-shirt + gift box only.
    w, h = teaser.size
    save(crop_to_ratio(teaser, (0, 0, round(w * 0.79), h), anchor_y=0.55), 'yatra_reward_tshirt.jpg')


if __name__ == '__main__':
    args = sys.argv[1:]
    main(args[0] if args else SOURCES / 'image.png', args[1] if len(args) > 1 else SOURCES / 'image copy.png')
