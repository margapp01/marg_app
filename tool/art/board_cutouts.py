"""Cut 3D graphics out of the /docs UI boards (GrabCut), upscale, feather and
save transparent PNGs into the app's illustrations folder."""
from pathlib import Path

import cv2
import numpy as np
from PIL import Image, ImageEnhance, ImageFilter

APP = Path(__file__).resolve().parents[2]
B = str(APP.parent / 'docs') + '/'
D = str(APP / 'assets' / 'images' / 'illustrations') + '/'
SCALE = 3
FILL_HOLES = {'checkin_failed.png', 'checkin_success.png', 'medal_trishul.png'}
KEY_BACKGROUND = {'support_headset.png'}  # open shapes enclosing background
JOBS = {  # output: (board, crop box with margin)
    'medal_trishul.png': ('image copy 7.png', (668, 624, 844, 800)),
    'checkin_failed.png': ('image copy 7.png', (1326, 592, 1418, 688)),
    'checkin_success.png': ('image copy 7.png', (1338, 64, 1410, 134)),
    'invite_gift.png': ('image copy 15.png', (372, 118, 518, 252)),
    'points_coins.png': ('image copy 15.png', (1095, 100, 1176, 168)),
    'support_headset.png': ('image copy 4.png', (750, 1548, 842, 1642)),
}

for out, (board, box) in JOBS.items():
    src = Image.open(B + board).convert('RGB').crop(box)
    big = src.resize((src.width * SCALE, src.height * SCALE), Image.LANCZOS).filter(ImageFilter.UnsharpMask(2, 60, 2))
    img = cv2.cvtColor(np.asarray(big), cv2.COLOR_RGB2BGR)
    h, w = img.shape[:2]
    m = int(min(w, h) * 0.06)
    mask = np.zeros((h, w), np.uint8)
    bgd, fgd = np.zeros((1, 65), np.float64), np.zeros((1, 65), np.float64)
    cv2.grabCut(img, mask, (m, m, w - 2 * m, h - 2 * m), bgd, fgd, 6, cv2.GC_INIT_WITH_RECT)
    fg = np.where((mask == cv2.GC_FGD) | (mask == cv2.GC_PR_FGD), 255, 0).astype(np.uint8)
    # keep the largest component (drops stray sparkles), then feather the edge
    n, labels, stats, _ = cv2.connectedComponentsWithStats(fg)
    if n > 1:
        keep = 1 + int(np.argmax(stats[1:, cv2.CC_STAT_AREA]))
        fg = np.where(labels == keep, 255, 0).astype(np.uint8)
    fg = cv2.morphologyEx(fg, cv2.MORPH_CLOSE, np.ones((5, 5), np.uint8))
    if out in FILL_HOLES:
        outside = fg.copy()
        cv2.floodFill(outside, np.zeros((h + 2, w + 2), np.uint8), (0, 0), 255)
        fg = fg | cv2.bitwise_not(outside)
    alpha = cv2.GaussianBlur(fg, (0, 0), 1.6).astype(np.float32)
    if out in KEY_BACKGROUND:
        rgb = np.asarray(big).astype(np.float32)
        border = np.concatenate([rgb[0], rgb[-1], rgb[:, 0], rgb[:, -1]])
        dist = np.linalg.norm(rgb - np.median(border, axis=0), axis=2)
        alpha *= np.clip((dist - 14) / 22, 0, 1)
    alpha = alpha.astype(np.uint8)
    rgba = np.dstack([np.asarray(big), alpha])
    im = Image.fromarray(rgba, 'RGBA')
    bbox = im.getchannel('A').point(lambda a: 255 if a > 8 else 0).getbbox()
    im = im.crop((max(bbox[0] - 6, 0), max(bbox[1] - 6, 0), min(bbox[2] + 6, w), min(bbox[3] + 6, h)))
    im.save(D + out, optimize=True)
    print(f'{out:22} {im.size}')


# Soft scenes (no single object to cut out): upscale, enhance, lift the board's
# paper colour to alpha and feather the borders.
SCENES = {  # output: (board, crop box)
    'setup_complete.webp': ('image copy.png', (56, 492, 808, 711)),
}
SCENE_WIDTH = 1200


def _smooth(t):
    t = np.clip(t, 0, 1)
    return t * t * (3 - 2 * t)


for out, (board, box) in SCENES.items():
    src = Image.open(B + board).convert('RGB').crop(box)
    big = src.resize((src.width * SCALE, src.height * SCALE), Image.LANCZOS)
    big = Image.fromarray(cv2.detailEnhance(np.asarray(big), sigma_s=12, sigma_r=0.1))
    big = ImageEnhance.Color(big.filter(ImageFilter.UnsharpMask(2, 70, 2))).enhance(1.12)
    rgb = np.asarray(big).astype(np.float32)
    paper = np.median(rgb[:8].reshape(-1, 3), axis=0)  # top rows are bare paper
    lift = np.where(rgb > paper, (rgb - paper) / np.maximum(255 - paper, 1), (paper - rgb) / np.maximum(paper, 1))
    alpha = np.clip((lift.max(axis=2) - 0.04) / 0.96, 0, 1)
    colour = paper + (rgb - paper) / np.where(alpha > 0, alpha, 1)[..., None]
    h, w = alpha.shape
    yy, xx = np.mgrid[0:h, 0:w]
    alpha *= _smooth(np.minimum(xx, w - 1 - xx) / (w * 0.12)) * _smooth((h - 1 - yy) / (h * 0.2))
    rgba = np.dstack([np.clip(colour, 0, 255), alpha * 255]).astype(np.uint8)
    im = Image.fromarray(rgba, 'RGBA')
    im = im.resize((SCENE_WIDTH, round(h * SCENE_WIDTH / w)), Image.LANCZOS)
    im.save(D + out, 'WEBP', quality=85, method=6)
    print(f'{out:22} {im.size}')
