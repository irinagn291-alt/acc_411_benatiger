"""Restore the iOS icon selected in Gambling Factory."""
from pathlib import Path
import json
import shutil

project = Path(__file__).resolve().parents[1]
catalog = project / "Game/Resources/Assets.xcassets/AppIcon.appiconset"
catalog.mkdir(parents=True, exist_ok=True)
filename = "benatiger_AppIcon.png"
original = project.parents[1] / "artifacts/genesis/com.tigerbureau.luckytiger/assets/normalized" / filename
shutil.copyfile(original, catalog / filename)
contents = {"images": [{"filename": filename, "idiom": "universal", "platform": "ios", "size": "1024x1024"}],
            "info": {"author": "xcode", "version": 1}}
(catalog / "Contents.json").write_text(json.dumps(contents, indent=2) + "\n")
