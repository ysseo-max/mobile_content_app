#!/usr/bin/env python3
"""Generate a polished app icon: rounded-square gradient background with white AI sparkle stars."""

from PIL import Image, ImageDraw, ImageFilter
import math


def create_rounded_rect_mask(size, radius):
    """Create an alpha mask for a rounded rectangle."""
    mask = Image.new("L", size, 0)
    draw = ImageDraw.Draw(mask)
    draw.rounded_rectangle([0, 0, size[0] - 1, size[1] - 1], radius=radius, fill=255)
    return mask


def create_gradient(size):
    """Create a smooth blue-to-purple diagonal gradient."""
    w, h = size
    img = Image.new("RGB", size)
    pixels = img.load()

    # Corner colors for bilinear interpolation
    tl = (0x4A, 0x9F, 0xFF)   # Top-left: bright blue
    tr = (0x5C, 0x7F, 0xFF)   # Top-right: blend
    bl = (0x5E, 0x6A, 0xF0)   # Bottom-left: blend
    br = (0x5B, 0x52, 0xE0)   # Bottom-right: deep purple
    center = (0x6C, 0x63, 0xFF)  # Center emphasis

    for y in range(h):
        ty = y / (h - 1)
        for x in range(w):
            tx = x / (w - 1)

            # Bilinear interpolation of four corners
            r_bi = (1-tx)*(1-ty)*tl[0] + tx*(1-ty)*tr[0] + (1-tx)*ty*bl[0] + tx*ty*br[0]
            g_bi = (1-tx)*(1-ty)*tl[1] + tx*(1-ty)*tr[1] + (1-tx)*ty*bl[1] + tx*ty*br[1]
            b_bi = (1-tx)*(1-ty)*tl[2] + tx*(1-ty)*tr[2] + (1-tx)*ty*bl[2] + tx*ty*br[2]

            # Blend toward center color in the middle
            cx_n = (tx - 0.5) * 2
            cy_n = (ty - 0.5) * 2
            dist = math.sqrt(cx_n**2 + cy_n**2) / math.sqrt(2)
            cw = max(0, 1.0 - dist) * 0.5

            r = r_bi * (1 - cw) + center[0] * cw
            g = g_bi * (1 - cw) + center[1] * cw
            b = b_bi * (1 - cw) + center[2] * cw

            pixels[x, y] = (int(r), int(g), int(b))

    return img


def draw_star_polygon(draw, cx, cy, arm_length, arm_width, fill):
    """Draw a 4-pointed star polygon."""
    points = [
        (cx, cy - arm_length),
        (cx + arm_width, cy - arm_width),
        (cx + arm_length, cy),
        (cx + arm_width, cy + arm_width),
        (cx, cy + arm_length),
        (cx - arm_width, cy + arm_width),
        (cx - arm_length, cy),
        (cx - arm_width, cy - arm_width),
    ]
    draw.polygon(points, fill=fill)


def create_star_glow_layer(size, stars):
    """Create a soft glow layer for the stars."""
    glow = Image.new("RGBA", size, (0, 0, 0, 0))
    draw = ImageDraw.Draw(glow)

    for cx, cy, arm_length, arm_width in stars:
        glow_scale = 1.5
        draw_star_polygon(
            draw, cx, cy,
            int(arm_length * glow_scale),
            int(arm_width * glow_scale),
            fill=(255, 255, 255, 60)
        )

    glow = glow.filter(ImageFilter.GaussianBlur(radius=25))
    glow = glow.filter(ImageFilter.GaussianBlur(radius=15))
    return glow


def create_star_layer(size, stars):
    """Create the crisp white star layer."""
    layer = Image.new("RGBA", size, (0, 0, 0, 0))
    draw = ImageDraw.Draw(layer)

    for cx, cy, arm_length, arm_width in stars:
        draw_star_polygon(draw, cx, cy, arm_length, arm_width, fill=(255, 255, 255, 255))

    return layer


def main():
    SIZE = 1024
    RADIUS = 200

    # Stars: (cx, cy, arm_length, arm_width)
    # arm_width ~17% of arm_length for thin, elegant look
    stars = [
        (380, 380, 160, 27),   # Large star - center-left
        (620, 280, 80, 14),    # Medium star - upper-right
        (560, 560, 50, 9),     # Small star - lower-right
    ]

    print("Creating gradient background...")
    gradient = create_gradient((SIZE, SIZE))

    print("Creating rounded rectangle mask...")
    mask = create_rounded_rect_mask((SIZE, SIZE), RADIUS)

    # Apply rounded rect mask to gradient
    bg = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    gradient_rgba = gradient.convert("RGBA")
    bg.paste(gradient_rgba, (0, 0), mask)

    print("Creating star glow effect...")
    glow_layer = create_star_glow_layer((SIZE, SIZE), stars)
    glow_masked = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    glow_masked.paste(glow_layer, (0, 0), mask)
    bg = Image.alpha_composite(bg, glow_masked)

    print("Drawing crisp stars...")
    star_layer = create_star_layer((SIZE, SIZE), stars)
    star_masked = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    star_masked.paste(star_layer, (0, 0), mask)
    bg = Image.alpha_composite(bg, star_masked)

    output_path = "/home/rebeauty-photos/mobile_content_app/assets/icon/app_icon.png"
    bg.save(output_path, "PNG")
    print(f"Icon saved to: {output_path}")
    print(f"Size: {bg.size[0]}x{bg.size[1]}, Mode: {bg.mode}")


if __name__ == "__main__":
    main()
