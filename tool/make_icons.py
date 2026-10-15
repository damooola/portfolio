"""Draws the DN monogram app icons and favicon into web/.

    python tool/make_icons.py
"""
from PIL import Image, ImageDraw, ImageFont

NIGHT = (10, 15, 30)
BLUE_DEEP = (3, 70, 148)
BLUE = (61, 107, 255)
TEXT = (233, 237, 247)
FONT = 'C:/Windows/Fonts/segoeuib.ttf'


def monogram(size, maskable=False):
    scale = 4  # draw big, downsample for smooth edges
    s = size * scale
    img = Image.new('RGBA', (s, s), NIGHT if maskable else (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    # Maskable icons get cropped to a circle by some launchers: keep the
    # mark inside the central 80% safe zone.
    inset = int(s * (0.14 if maskable else 0.0))
    radius = int((s - 2 * inset) * 0.24)
    d.rounded_rectangle([inset, inset, s - inset - 1, s - inset - 1], radius=radius,
                        fill=BLUE_DEEP, outline=BLUE, width=max(scale, s // 64))
    font = ImageFont.truetype(FONT, int((s - 2 * inset) * 0.44))
    box = d.textbbox((0, 0), 'DN', font=font)
    w, h = box[2] - box[0], box[3] - box[1]
    d.text(((s - w) / 2 - box[0], (s - h) / 2 - box[1]), 'DN', font=font, fill=TEXT)
    return img.resize((size, size), Image.LANCZOS)


monogram(32).save('web/favicon.png')
monogram(192).save('web/icons/Icon-192.png')
monogram(512).save('web/icons/Icon-512.png')
monogram(192, maskable=True).save('web/icons/Icon-maskable-192.png')
monogram(512, maskable=True).save('web/icons/Icon-maskable-512.png')
print('wrote favicon and app icons')
