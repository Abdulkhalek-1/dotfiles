#!/usr/bin/env python3
"""Show an OSD-style popup on keyboard-layout change.

Listens to Hyprland's `activelayout` event on socket2 and fires a transient
notification (HyprPanel renders it). The synchronous hint makes repeated
switches replace each other in place, like the volume/brightness OSD.

This also covers layouts HyprPanel's bar module doesn't know (e.g. Egyptian
Arabic), since the name→code map here is our own.
"""
import os
import re
import socket
import subprocess

# Friendly short codes for the layouts we use; extend as needed.
CODES = {
    "English (US)": "US",
    "Arabic (Egypt)": "EG",
    "Arabic": "AR",
}


def short(name: str) -> str:
    if name in CODES:
        return CODES[name]
    m = re.search(r"\(([^)]+)\)", name)          # "(Country)" -> first 2 letters
    return (m.group(1)[:2] if m else name[:2]).upper()


def osd(name: str) -> None:
    # SwayOSD: a centered OSD pill (like the volume/brightness OSD), not a
    # corner notification. --custom-icon uses a Freedesktop icon name.
    subprocess.run(
        ["swayosd-client", "--custom-message", name,
         "--custom-icon", "input-keyboard"],
        check=False,
    )


def main() -> None:
    his = os.environ["HYPRLAND_INSTANCE_SIGNATURE"]
    runtime = os.environ.get("XDG_RUNTIME_DIR", f"/run/user/{os.getuid()}")
    path = f"{runtime}/hypr/{his}/.socket2.sock"

    s = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
    s.connect(path)

    buf, last = "", None
    while True:
        chunk = s.recv(4096).decode("utf-8", "replace")
        if not chunk:
            break
        buf += chunk
        while "\n" in buf:
            line, buf = buf.split("\n", 1)
            if line.startswith("activelayout>>"):
                name = line[len("activelayout>>"):].split(",", 1)[-1]
                if name != last:
                    last = name
                    osd(name)


if __name__ == "__main__":
    main()
