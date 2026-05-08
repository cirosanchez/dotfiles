from pathlib import Path

current = Path.home() / ".config/themes/current/waybar.css"

print(current.resolve().parent.name)