"""Copy named screenshots from finished xcresult attachment exports."""
from pathlib import Path
import json
import re
import shutil
import sys

source = Path(sys.argv[1]) / "attachments"
frames = source.parent / "frames"
frames.mkdir(exist_ok=True)
for test in json.loads((source / "manifest.json").read_text()):
    for attachment in test["attachments"]:
        name = attachment["suggestedHumanReadableName"]
        match = re.fullmatch(r"((?:\d\d|campaign-|locale-|deduction-|motion-)[a-zA-Z0-9-]+)_\d+_[A-F0-9-]+\.png", name)
        if match and not attachment["isAssociatedWithFailure"]:
            shutil.copy2(source / attachment["exportedFileName"], frames / (match[1] + ".png"))
