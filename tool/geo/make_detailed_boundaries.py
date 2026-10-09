"""Builds the downloadable detailed Bharat boundaries for the backend.

Source: the surveyed Akhand Bharat outline (`akhand_bharat_india_boundaries_updated.json`,
~14 MB, 640k points). It is simplified with Douglas-Peucker at ~30 m
(0.0003 deg), which is invisible at phone zoom levels yet keeps it light
enough to render smoothly, and written in the app's boundary format (a
FeatureCollection with `akhandBharat` + `india`; Bharat's official outline is
taken from the bundled asset, which the source lacks).

  python3 tool/geo/make_detailed_boundaries.py <source.json>

Writes ../marg_backend/assets/geo/bharat_boundaries_detailed.geojson.
"""
import json
import sys
from pathlib import Path

TOLERANCE = 0.0003
HERE = Path(__file__).resolve().parent
APP = HERE.parent.parent
BUNDLED = APP / 'assets' / 'geo' / 'bharat_boundaries.geojson'
OUT = APP.parent / 'marg_backend' / 'assets' / 'geo' / 'bharat_boundaries_detailed.geojson'


def simplify(points, tolerance):
    """Iterative Douglas-Peucker; keeps the ring's endpoints."""
    if len(points) < 5:
        return points
    keep = [False] * len(points)
    keep[0] = keep[-1] = True
    stack = [(0, len(points) - 1)]
    limit = tolerance * tolerance
    while stack:
        a, b = stack.pop()
        ax, ay = points[a]
        bx, by = points[b]
        dx, dy = bx - ax, by - ay
        length = dx * dx + dy * dy
        best, index = -1.0, -1
        for i in range(a + 1, b):
            px, py = points[i]
            if length == 0:
                d = (px - ax) ** 2 + (py - ay) ** 2
            else:
                t = max(0.0, min(1.0, ((px - ax) * dx + (py - ay) * dy) / length))
                d = (px - ax - t * dx) ** 2 + (py - ay - t * dy) ** 2
            if d > best:
                best, index = d, i
        if best > limit:
            keep[index] = True
            stack += [(a, index), (index, b)]
    return [p for p, k in zip(points, keep) if k]


def main(source):
    geometry = json.loads(Path(source).read_text())['geometries'][0]
    polygons = []
    for polygon in geometry['coordinates']:
        rings = [
            [[round(x, 5), round(y, 5)] for x, y in simplify(ring, TOLERANCE)]
            for ring in polygon
        ]
        rings = [r for r in rings if len(r) >= 4]
        if rings:
            polygons.append(rings)
    india = next(f for f in json.loads(BUNDLED.read_text())['features'] if f['properties']['id'] == 'india')
    collection = {
        'type': 'FeatureCollection',
        'features': [
            {
                'type': 'Feature',
                'properties': {'id': 'akhandBharat', 'name': 'Akhand Bharat'},
                'geometry': {'type': 'MultiPolygon', 'coordinates': polygons},
            },
            india,
        ],
    }
    OUT.parent.mkdir(parents=True, exist_ok=True)
    OUT.write_text(json.dumps(collection, separators=(',', ':')))
    points = sum(len(r) for p in polygons for r in p)
    print(f'{OUT} — {len(polygons)} polygons, {points} points, {OUT.stat().st_size} bytes')


if __name__ == '__main__':
    main(sys.argv[1])
