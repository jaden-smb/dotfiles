"""Regression tests run with fake desktop commands and isolated home directories."""
import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
WALLPAPER = ROOT / 'config/hypr/scripts/wallpaper.sh'
PICKER = ROOT / 'config/hypr/scripts/wofi-wallpaper-selector.sh'


class DotfilesTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.base = Path(self.temp.name)
        self.home = self.base / 'home'
        self.home.mkdir()
        self.bin = self.base / 'bin'
        self.bin.mkdir()
        self.env = dict(os.environ, HOME=str(self.home),
                        XDG_CONFIG_HOME=str(self.home / '.config'),
                        XDG_CACHE_HOME=str(self.home / '.cache'),
                        XDG_STATE_HOME=str(self.home / '.local/state'),
                        PATH=str(self.bin) + ':' + os.environ['PATH'],
                        TEST_LOG=str(self.base / 'commands.jsonl'),
                        TEST_DAEMON=str(self.base / 'daemon'))
        mock = '''#!/usr/bin/env python3
import json, os, pathlib, sys
name = pathlib.Path(sys.argv[0]).name
args = sys.argv[1:]
with open(os.environ['TEST_LOG'], 'a') as f:
    f.write(json.dumps([name, *args]) + '\\n')
if name == 'awww' and args == ['query']:
    sys.exit(0 if pathlib.Path(os.environ['TEST_DAEMON']).exists() else 1)
if name == 'awww-daemon': pathlib.Path(os.environ['TEST_DAEMON']).touch()
if name == 'awww' and args and args[0] == 'img': sys.exit(int(os.getenv('TEST_IMG_FAILURE', '0')))
if name == 'wal': sys.exit(int(os.getenv('TEST_WAL_FAILURE', '0')))
if name == 'magick': pathlib.Path(args[-1]).touch()
if name == 'wofi':
    pathlib.Path(os.environ['TEST_MENU']).write_text(sys.stdin.read())
    if os.getenv('TEST_CANCEL'): sys.exit(1)
    print(os.getenv('TEST_CHOICE', '1'))
'''
        for name in ['awww', 'awww-daemon', 'wal', 'hyprctl', 'pgrep', 'pkill', 'magick', 'wofi']:
            p = self.bin / name
            p.write_text(mock)
            p.chmod(0o755)

    def run_script(self, script, *args, success=True):
        result = subprocess.run(['bash', str(script), *args], env=self.env,
                                capture_output=True, text=True, timeout=15)
        self.assertEqual(result.returncode == 0, success, result.stderr)
        return result

    def commands(self):
        log = self.base / 'commands.jsonl'
        return [json.loads(line) for line in log.read_text().splitlines()] if log.exists() else []

    def image(self, name='image with spaces.jpg'):
        p = self.home / 'Pictures/Wallpapers' / name
        p.parent.mkdir(parents=True, exist_ok=True)
        p.touch()
        return p

    def state(self):
        return self.home / '.local/state/hypr/wallpaper'

    def test_set_persist_and_restore(self):
        image = self.image('image $(touch should-not-exist).jpg')
        self.run_script(WALLPAPER, str(image))
        self.assertEqual(self.state().read_text(), str(image) + '\n')
        cmds = self.commands()
        self.assertIn(['wal', '--cols16', '-n', '-e', '-q', '-i', str(image)], cmds)
        self.assertEqual(sum(c[0] == 'awww-daemon' for c in cmds), 1)
        before = len(cmds)
        self.run_script(WALLPAPER, '--restore')
        restored = self.commands()[before:]
        self.assertTrue(any(c[:2] == ['awww', 'img'] for c in restored))
        self.assertFalse(any(c[0] in ['wal', 'awww-daemon', 'hyprctl'] for c in restored))

    def test_failures_do_not_replace_saved_selection(self):
        old = self.image('old.jpg')
        self.run_script(WALLPAPER, str(old))
        new = self.image('new.png')
        for failure in ['TEST_WAL_FAILURE', 'TEST_IMG_FAILURE']:
            self.env[failure] = '1'
            self.run_script(WALLPAPER, str(new), success=False)
            self.assertEqual(self.state().read_text().strip(), str(old))
            self.env.pop(failure)

    def test_empty_restore_and_missing_image(self):
        self.run_script(WALLPAPER, '--restore')
        self.assertFalse(self.state().exists())
        self.run_script(WALLPAPER, str(self.home / 'missing.png'), success=False)
        self.assertFalse(self.state().exists())
        self.assertFalse(any(c[0] == 'wal' for c in self.commands()))

    def test_random_and_picker_duplicate_basenames(self):
        first = self.image('first/same.jpg')
        second = self.image('second/same.jpg')
        self.env['TEST_MENU'] = str(self.base / 'menu')
        self.env['TEST_CHOICE'] = '2'
        self.run_script(PICKER)
        self.assertEqual(self.state().read_text().strip(), str(second))
        menu = Path(self.env['TEST_MENU']).read_text().splitlines()
        self.assertEqual(len(menu), 3)
        self.assertNotEqual(menu[1].split(':text:')[0], menu[2].split(':text:')[0])
        self.run_script(WALLPAPER, '--random')
        self.assertIn(self.state().read_text().strip(), [str(first), str(second)])
        self.env['TEST_CANCEL'] = '1'
        before = self.state().read_text()
        self.run_script(PICKER)
        self.assertEqual(self.state().read_text(), before)

    def test_installer_backup_xdg_and_idempotency(self):
        repo = self.base / 'repo'
        repo.mkdir()
        shutil.copy2(ROOT / 'install.sh', repo / 'install.sh')
        (repo / 'config').symlink_to(ROOT / 'config')
        (repo / 'home').symlink_to(ROOT / 'home')
        target = Path(self.env['XDG_CONFIG_HOME'])
        target.mkdir()
        (target / 'hypr').mkdir()
        (target / 'hypr/old.conf').write_text('old settings')
        self.run_script(repo / 'install.sh')
        self.assertTrue((target / 'hypr').is_symlink())
        self.assertTrue((target / 'wal/templates/colors-hyprland.conf').exists())
        self.assertTrue((target / 'fastfetch').is_symlink())
        self.assertFalse((target / 'nvim').exists())
        saved = list((repo / '.backup').glob('*/**/old.conf'))
        self.assertEqual(len(saved), 1)
        self.assertEqual(saved[0].read_text(), 'old settings')
        palette = Path(self.env['XDG_CACHE_HOME']) / 'wal/colors-rofi-dark.rasi'
        palette.write_text('existing palette')
        backups = list((repo / '.backup').iterdir())
        self.run_script(repo / 'install.sh')
        self.assertEqual(palette.read_text(), 'existing palette')
        self.assertEqual(list((repo / '.backup').iterdir()), backups)

    def test_config_formats_and_shell_syntax(self):
        import tomllib
        for p in list((ROOT / 'config').rglob('*.json')) + list((ROOT / 'config').rglob('*.jsonc')):
            json.loads(p.read_text())
        for p in (ROOT / 'config').rglob('*.toml'):
            tomllib.loads(p.read_text())
        scripts = [ROOT / 'install.sh', *(ROOT / 'config').rglob('*.sh')]
        for p in scripts:
            subprocess.run(['bash', '-n', str(p)], check=True)

    def test_palette_templates(self):
        class Color:
            strip = 'aabbcc'

            def __format__(self, spec):
                return '#aabbcc'

        values = {name: Color() for name in ['background', 'foreground', 'color1', 'color2', 'color8']}
        for p in (ROOT / 'config/wal/templates').iterdir():
            rendered = p.read_text().format(**values)
            self.assertIn('aabbcc', rendered)

    def test_lua_modules_and_palette_fallback(self):
        import ctypes
        import ctypes.util
        from unittest.mock import patch

        library = ctypes.util.find_library('lua5.4')
        if not library:
            self.skipTest('Lua 5.4 shared library is not installed')
        lib = ctypes.CDLL(library)
        lib.luaL_newstate.restype = ctypes.c_void_p
        lib.luaL_openlibs.argtypes = [ctypes.c_void_p]
        lib.luaL_loadfilex.argtypes = [ctypes.c_void_p, ctypes.c_char_p, ctypes.c_char_p]
        lib.lua_pcallk.argtypes = [ctypes.c_void_p, ctypes.c_int, ctypes.c_int, ctypes.c_int, ctypes.c_ssize_t, ctypes.c_void_p]
        lib.lua_tolstring.argtypes = [ctypes.c_void_p, ctypes.c_int, ctypes.c_void_p]
        lib.lua_tolstring.restype = ctypes.c_char_p
        lib.lua_close.argtypes = [ctypes.c_void_p]
        palette = Path(self.env['XDG_CACHE_HOME']) / 'wal/colors-hyprland.conf'
        fixtures = [('', 'rgba(33ccffee)', 'rgba(595959aa)'),
                    ('$color2 = rgb(aabbcc)\n$color8 = rgba(112233ee)\n', 'rgb(aabbcc)', 'rgba(112233ee)'),
                    ('$color2 = os.execute("false")\n$color8 = invalid\n', 'rgba(33ccffee)', 'rgba(595959aa)')]
        for content, active, inactive in fixtures:
            if content:
                palette.parent.mkdir(parents=True, exist_ok=True)
                palette.write_text(content)
            with patch.dict(os.environ, dict(self.env, TEST_ACTIVE=active, TEST_INACTIVE=inactive)):
                state = lib.luaL_newstate()
                try:
                    lib.luaL_openlibs(state)
                    # loadfile in the harness resolves the repository's relative modules.
                    old_cwd = Path.cwd()
                    try:
                        os.chdir(ROOT)
                        status = lib.luaL_loadfilex(state, b'tests/check_hypr.lua', None)
                        if not status:
                            status = lib.lua_pcallk(state, 0, -1, 0, 0, None)
                        error = lib.lua_tolstring(state, -1, None) if status else b''
                        self.assertEqual(status, 0, error.decode())
                    finally:
                        os.chdir(old_cwd)
                finally:
                    lib.lua_close(state)


if __name__ == '__main__':
    unittest.main()
