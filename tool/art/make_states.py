"""Crop the baked-in text off the empty-state illustrations, turn the white
backdrop into alpha (colour-to-alpha against white) and export app WebPs."""
from pathlib import Path

import numpy as np
from PIL import Image

APP = Path(__file__).resolve().parents[2]
SRC = str(APP.parent / "docs" / "empty-states") + "/"
DST = str(APP / "assets" / "images" / "illustrations") + "/"
# source file -> (output, crop bottom in source px = first row of the baked-in title)
JOBS = {
    "journey_awaits.webp": ("state_journey", 850),
    "no_visits_suitcase.webp": ("state_no_visits", 862),
    "nothing_saved_bookmark.webp": ("state_bookmarks", 925),
    "no_results.webp": ("state_no_results", 820),
    "not_found_scroll.webp": ("state_not_found", 806),
    "location.webp": ("state_location", 822),
    "notifications.webp": ("state_notifications", 878),
    "saved_places.webp": ("state_saved_places", 836),
    "Temple Serenity_ No Internet Connection-1.png": ("state_offline", 1058),
    "Coming Soon_ Temple Sanctuary.png": ("state_coming_soon", 1046),
    "No Access Yet_ Temple Treasure Chest-2.png": ("state_permission", 1066),
    "No Invites or Rewards Yet.png": ("state_referrals", 1060),
    "No Passport Certificates Yet.png": ("state_certificates", 840),
    "No Sacred Cards Yet.png": ("state_cards", 1065),
    "Sacred Temple Card Collection.png": ("state_collection", 751),
    "No Upcoming Festivals at the Temple.png": ("state_festivals", 1057),
    "Nothing Here Yet_ Temple Serenity.png": ("state_empty", 1056),
    "Ornate Temple Hourglass Please Wait.png": ("state_timeout", 1057),
    "Something Went Wrong at the Temple.png": ("state_unexpected", 1053),
    "Temple Lamp Error Screen.png": ("state_error", 851),
    "Temple Leaderboard Empty State.png": ("state_leaderboard", 1058),
    "Temple Medal Empty State.png": ("state_achievements", 1035),
    "Temple Wisdom Empty State.png": ("state_knowledge", 1056),
}
FADE = 70  # px of bottom fade so the crop never shows a hard edge


NEAR_WHITE = 0.07  # off-white paper tones count as background


def color_to_alpha(rgb):
    a = (255.0 - rgb).max(axis=2) / 255.0
    a = np.clip((a - NEAR_WHITE) / (1 - NEAR_WHITE), 0, 1)
    safe = np.where(a > 0, a, 1)
    out = 255.0 - (255.0 - rgb) / safe[..., None]
    return np.clip(out, 0, 255), a


for src, (dst, bottom) in JOBS.items():
    im = Image.open(SRC + src).convert("RGBA")
    flat = Image.new("RGBA", im.size, (255, 255, 255, 255))
    flat.alpha_composite(im)
    rgb = np.asarray(flat.convert("RGB")).astype(float)[:bottom]
    col, a = color_to_alpha(rgb)
    # Soft fade at the bottom edge.
    ramp = np.ones(bottom)
    ramp[-FADE:] = np.linspace(1, 0, FADE) ** 1.5
    a = a * ramp[:, None]
    # Elliptical edge vignette removes any residual paper rectangle.
    h, w = a.shape
    yy, xx = np.mgrid[0:h, 0:w]
    r = np.sqrt(((xx - w / 2) / (w / 2)) ** 2 + ((yy - h * 0.55) / (h * 0.62)) ** 2)
    a = a * np.clip((1.08 - r) / 0.22, 0, 1)
    # Feather the left, right and top borders so full-bleed scenes never show
    # a hard edge (white-paper sources are already transparent there).
    edge = np.clip(np.minimum(np.minimum(xx, w - 1 - xx) / (w * 0.08), yy / (h * 0.06)), 0, 1)
    a = a * edge * edge * (3 - 2 * edge)
    rgba = np.dstack([col, a * 255]).astype(np.uint8)
    out = Image.fromarray(rgba, "RGBA")
    # Trim empty margins (keep a little air).
    ys, xs = np.where(a > 0.03)
    pad = 12
    box = (max(xs.min() - pad, 0), max(ys.min() - pad, 0), min(xs.max() + pad, out.width), bottom)
    out = out.crop(box)
    if out.width > 800:
        out = out.resize((800, round(out.height * 800 / out.width)), Image.LANCZOS)
    out.save(DST + dst + ".webp", "WEBP", quality=80, method=6)
    print(f"{dst:22} {out.size}")
