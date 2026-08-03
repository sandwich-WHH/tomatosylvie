"""
心叶心情图标 - 背景抠图脚本
将白色背景的 PNG 转为透明背景,并自动裁剪留白

Usage:
    python remove-bg.py                          # 处理当前目录所有心情图
    python remove-bg.py --input <dir>            # 指定输入目录
    python remove-bg.py --threshold 240          # 自定义白点阈值
    python remove-bg.py --padding 20             # 自定义裁剪 padding
"""
from PIL import Image
import os
import argparse
import glob


DEFAULT_MOOD_FILES = [
    "01_开心_太阳小人.png",
    "02_平静_茶杯小人.png",
    "03_焦虑_乱线小人.png",
    "04_愤怒_闪电小人.png",
    "05_疲惫_云朵小人.png",
    "06_低落_雨伞小人.png",
]


def remove_white_bg(input_path, output_path, threshold=240, crop_padding=20):
    """
    1. 白色/近白色像素 -> 完全透明
    2. 边缘半透明像素根据亮度做羽化
    3. 自动裁剪到内容区域(留 padding)
    """
    img = Image.open(input_path).convert("RGBA")
    pixels = img.load()
    width, height = img.size

    # Step 1: 遍历每个像素,根据亮度调整 alpha
    for y in range(height):
        for x in range(width):
            r, g, b, a = pixels[x, y]
            # 计算感知亮度
            brightness = 0.299 * r + 0.587 * g + 0.114 * b
            if brightness >= threshold:
                # 完全白/近白 -> 全透明
                pixels[x, y] = (255, 255, 255, 0)
            elif brightness >= threshold - 15:
                # 边缘半透明区 -> 羽化
                fade = int(255 * (brightness - (threshold - 15)) / 15)
                fade = max(0, min(fade, 255))
                pixels[x, y] = (r, g, b, fade)

    # Step 2: 自动裁剪到内容区域
    alpha = img.split()[3]
    bbox = alpha.getbbox()

    if bbox:
        left = max(0, bbox[0] - crop_padding)
        top = max(0, bbox[1] - crop_padding)
        right = min(width, bbox[2] + crop_padding)
        bottom = min(height, bbox[3] + crop_padding)
        img_cropped = img.crop((left, top, right, bottom))
    else:
        img_cropped = img

    # Step 3: 保存为 PNG(保留 alpha 通道)
    img_cropped.save(output_path, "PNG", optimize=True)

    return img_cropped.size


def process_directory(input_dir, output_dir=None, threshold=240, padding=20):
    """处理目录中所有默认心情文件"""
    if output_dir is None:
        output_dir = input_dir

    if not os.path.exists(input_dir):
        print(f"[ERROR] Input directory not found: {input_dir}")
        return

    os.makedirs(output_dir, exist_ok=True)

    # 先尝试默认文件列表
    files_to_process = []
    for filename in DEFAULT_MOOD_FILES:
        path = os.path.join(input_dir, filename)
        if os.path.exists(path):
            files_to_process.append(path)

    # 如果没找到默认文件,处理目录所有 PNG
    if not files_to_process:
        files_to_process = sorted(glob.glob(os.path.join(input_dir, "*.png")))

    if not files_to_process:
        print(f"[WARN] No PNG files found in {input_dir}")
        return

    print("=" * 60)
    print("Heart Leaf - Background Removal Tool")
    print("=" * 60)
    print(f"Input:   {input_dir}")
    print(f"Output:  {output_dir}")
    print(f"Files:   {len(files_to_process)}")
    print("=" * 60)

    for input_path in files_to_process:
        filename = os.path.basename(input_path)
        name, ext = os.path.splitext(filename)

        # 跳过已经是 _透明 后缀的文件
        if name.endswith("_透明"):
            print(f"[SKIP] Already transparent: {filename}")
            continue

        output_filename = f"{name}_透明{ext}"
        output_path = os.path.join(output_dir, output_filename)

        size = remove_white_bg(input_path, output_path, threshold, padding)
        original_size = Image.open(input_path).size
        print(f"[OK]   {filename}")
        print(f"       {original_size[0]}x{original_size[1]} -> {size[0]}x{size[1]}")
        print(f"       Saved as: {output_filename}")

    print("=" * 60)
    print(f"Done! {len(files_to_process)} file(s) processed.")
    print("=" * 60)


def main():
    parser = argparse.ArgumentParser(
        description="心叶心情图标 - 背景抠图工具"
    )
    parser.add_argument(
        "--input", "-i",
        default=".",
        help="输入图片所在目录(默认:当前目录)"
    )
    parser.add_argument(
        "--output", "-o",
        default=None,
        help="输出目录(默认:与输入相同)"
    )
    parser.add_argument(
        "--threshold", "-t",
        type=int,
        default=240,
        help="白点阈值 0-255(默认:240,越大越激进)"
    )
    parser.add_argument(
        "--padding", "-p",
        type=int,
        default=20,
        help="裁剪后保留的边距像素(默认:20)"
    )

    args = parser.parse_args()
    process_directory(args.input, args.output, args.threshold, args.padding)


if __name__ == "__main__":
    main()
