import os

FOLDER = os.path.dirname(os.path.abspath(__file__))

# ========== FIX 1: XÓA "light of light" ==========
DELETE_LIGHT_OF_LIGHT = [
    "monokai_pro_light_light(light).luau",
    "colorblind_light_light(light).luau",
    "night_owl_light_variant_light(light).luau",
]

# ========== FIX 2: XÓA THEME TRÙNG ==========
DELETE_DUPLICATES = [
    # sherbet_neovim trùng sherbet
    "sherbet_neovim.luau",
    "sherbet_neovim_light(light).luau",
    # arctic_frost trùng arctic
    "arctic_frost.luau",
    "arctic_frost_light(light).luau",
    # adwaita_neovim trùng adwaita
    "adwaita_neovim.luau",
    "adwaita_neovim_light(light).luau",
    # monochrome_hsluv trùng monochrome
    "monochrome_hsluv.luau",
    "monochrome_hsluv_light(light).luau",
    # flexoki_dark trùng flexoki
    "flexoki_dark.luau",
    "flexoki_dark_light(light).luau",
    # palenight_dark trùng palenight
    "palenight_dark.luau",
    "palenight_dark_light(light).luau",
    # oceanic_next_dark trùng oceanic_next
    "oceanic_next_dark.luau",
    "oceanic_next_dark_light(light).luau",
    # zenburn_dark trùng zenburn
    "zenburn_dark.luau",
    "zenburn_dark_light(light).luau",
]

DELETE_ALL = DELETE_LIGHT_OF_LIGHT + DELETE_DUPLICATES

def main():
    print(f"[INFO] Folder: {FOLDER}\n")
    print("=" * 60)
    print(f"[DELETE] {len(DELETE_ALL)} file")
    print("=" * 60)

    deleted = 0
    for fn in DELETE_ALL:
        p = os.path.join(FOLDER, fn)
        if os.path.exists(p):
            os.remove(p)
            print(f"  [DEL] {fn}")
            deleted += 1
        else:
            print(f"  [SKIP] {fn} (không tồn tại)")

    print(f"\n[DONE] Đã xóa {deleted}/{len(DELETE_ALL)} file")

    # Đếm lại
    files = [f for f in os.listdir(FOLDER) if f.endswith(".luau")]
    print(f"[INFO] Còn lại: {len(files)} file .luau")

if __name__ == "__main__":
    main()
