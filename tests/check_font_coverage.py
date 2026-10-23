#!/usr/bin/env python3
"""Check installed Fontconfig glyph coverage for the typography sample."""

from pathlib import Path
import subprocess
import sys


def main():
    sample = Path(__file__).with_name("typography.txt")
    missing = []
    for line in sample.read_text(encoding="utf-8").splitlines():
        label, text = line.split(":", 1)
        codepoints = sorted({ord(char) for char in text if not char.isspace()})
        absent = []
        for codepoint in codepoints:
            result = subprocess.run(
                ["fc-list", f":charset={codepoint:04x}", "-f", "%{family}\n"],
                capture_output=True,
                text=True,
                check=True,
            )
            if not result.stdout:
                absent.append(f"U+{codepoint:04X}")
        print(f"{label}: " + ("covered" if not absent else "missing " + ", ".join(absent)))
        missing.extend(absent)
    return 1 if missing else 0


if __name__ == "__main__":
    sys.exit(main())
