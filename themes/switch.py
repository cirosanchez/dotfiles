#!/usr/bin/env python3

from pathlib import Path
import subprocess
import json
import sys

if len(sys.argv) != 2:
    exit(1)

theme = sys.argv[1]

THEMES = Path.home() / ".config/themes"
CURRENT = THEMES / "current"

FILES = [
    "waybar.css",
    "fuzzel.ini",
    "kitty.conf",
    "fastfetch.jsonc",
    "wofi.css",
    "rofi.rasi"
]

# --------------------------------------------------
# Symlink themed files
# --------------------------------------------------

for file in FILES:
    src = THEMES / theme / file
    dst = CURRENT / file

    if src.exists():
        if dst.exists() or dst.is_symlink():
            dst.unlink()

        dst.symlink_to(src)

# --------------------------------------------------
# Apply VSCode theme
# --------------------------------------------------

if theme == "mocha":
    subprocess.run(
        r"""sed -i 's/"workbench.colorTheme":.*/"workbench.colorTheme": "Catppuccin Mocha",/' /home/ciro/.config/Code/User/settings.json""",
        shell=True
    )

elif theme == "nord":
    subprocess.run(
        r"""sed -i 's/"workbench.colorTheme":.*/"workbench.colorTheme": "Nord Dark",/' /home/ciro/.config/Code/User/settings.json""",
        shell=True
    )

elif theme == "gruvbox":
    subprocess.run(
        r"""sed -i 's/"workbench.colorTheme":.*/"workbench.colorTheme": "Gruvbox Dark",/' /home/ciro/.config/Code/User/settings.json""",
        shell=True
    )

elif theme == "nothingos":
    subprocess.run(
        r"""sed -i 's/"workbench.colorTheme":.*/"workbench.colorTheme": "Nothing OS Dark",/' /home/ciro/.config/Code/User/settings.json""",
        shell=True
    )


# --------------------------------------------------
# Restore wallpaper for this theme
# --------------------------------------------------

STATE = THEMES / "state.json"

if STATE.exists():
    with open(STATE) as f:
        state = json.load(f)

    wallpaper = state.get("wallpapers", {}).get(theme)

    if wallpaper:
        subprocess.run([
            "awww",
            "img",
            wallpaper,
            "--transition-type",
            "grow",
            "--transition-duration",
            "1"
        ])

# --------------------------------------------------
# Reload Waybar
# --------------------------------------------------

subprocess.run("pkill waybar", shell=True)

subprocess.Popen([
    "waybar",
    "-c",
    str(Path.home() / ".config/waybar/config.jsonc"),
    "-s",
    str(CURRENT / "waybar.css")
])

# --------------------------------------------------
# Reload Kitty
# --------------------------------------------------

kitty_socket = next(Path("/tmp").glob("kitty.sock-*"), None)

if kitty_socket:
    subprocess.run([
        "kitty",
        "@",
        "--to",
        f"unix:{kitty_socket}",
        "set-colors",
        "-a",
        str(CURRENT / "kitty.conf")
    ])

# --------------------------------------------------
# Apply Obsidian theme
# --------------------------------------------------

obsidian = Path("/home/ciro/Obsidian/.obsidian/appearance.json")

if obsidian.exists():
    with open(obsidian) as f:
        settings = json.load(f)

    if theme == "mocha":
        settings["cssTheme"] = "Catppuccin"

    elif theme == "nord":
        settings["cssTheme"] = "Obsidian Nord"
    
    elif theme == "gruvbox":
        settings["cssTheme"] = "Obsidian gruvbox"

    elif theme == "nothingos":
        settings["cssTheme"] = "Red-Shadow"

    with open(obsidian, "w") as f:
        json.dump(settings, f, indent=4)


# --------------------------------------------------
# Reload SwayNC CSS
# --------------------------------------------------

subprocess.run(
    "swaync-client --reload-css",
    shell=True
)

# --------------------------------------------------
# Apply GTK theme
# --------------------------------------------------

gtk_themes = {
    "mocha": "catppuccin-mocha-sky-standard+default",
    "nord": "Nordic",
    "gruvbox": "gruvbox-dark-gtk",
    "nothingos": "Graphite-red-Dark"
}


subprocess.run(
    f"gsettings set org.gnome.desktop.interface gtk-theme '{gtk_themes[theme]}'",
    shell=True
)