"""Measure the box outline and inset from the unscaled simulator frames."""
from collections import deque
from pathlib import Path
import sys

import numpy as np
from PIL import Image, ImageFilter

folder = Path(sys.argv[1])
room_y = (0.45, 0.82) if folder.parent.name.endswith(('fullscreen', '-final')) else (0.20, 0.44)
for name, color, crop in [
    ('02-reception', (36, 24, 23), (0.13, room_y[0], 0.87, room_y[1])),
    ('05-opened-paper-shim', (43, 35, 27), (0.0, 0.12, 1.0, 0.83)),
]:
    im = Image.open(folder / f'{name}.png').convert('RGB')
    w, h = im.size
    x0, y0, x1, y1 = (int(n * dimension) for n, dimension in zip(crop, (w, h, w, h)))
    mask = np.all(np.array(im.crop((x0, y0, x1, y1))) == color, axis=2)
    thick = Image.fromarray(np.uint8(mask) * 255).filter(ImageFilter.MaxFilter(5))
    points = set(zip(*np.nonzero(np.array(thick))))
    boxes = []
    while points:
        start = points.pop()
        frontier = deque([start])
        group = [start]
        while frontier:
            y, x = frontier.popleft()
            for after in ((y - 1, x), (y + 1, x), (y, x - 1), (y, x + 1)):
                if after in points:
                    points.remove(after)
                    frontier.append(after)
                    group.append(after)
        if len(group) > 200:
            ys, xs = zip(*group)
            boxes.append((len(group), min(xs)+x0+2, min(ys)+y0+2, max(xs)+x0-2, max(ys)+y0-2))
    boxes.sort(reverse=True)
    print(f'{name}: screenshot {w}×{h}px')
    for count, left, top, right, bottom in boxes[:3]:
        print(f'  {count} mask px: {right-left+1}×{bottom-top+1}px at ({left}, {top})')
