"""Run Lua syntax and mock-API tests using the system Lua 5.4 shared library."""
# WoW reads source text as UTF-8. Validate bytes before executing any Lua.
from pathlib import Path
for source in Path(__file__).resolve().parents[1].glob('*'):
    if source.suffix in ('.lua', '.toc', '.txt'):
        source.read_bytes().decode('utf-8', errors='strict')
print('PASS: source text is valid UTF-8.')

import ctypes
from pathlib import Path
import os
import sys

# Optional portable runner for Windows; retain the system-library path on Linux.
try:
    from lupa.lua54 import LuaRuntime
except ImportError:
    LuaRuntime = None
if LuaRuntime:
    root = Path(__file__).resolve().parents[1]
    os.chdir(root)
    lua = LuaRuntime()
    for path in root.glob('*.lua'):
        lua.execute('assert(loadfile(...))', path.as_posix())
        print('Syntax OK:', path.name)
    lua.execute('dofile("tests/mock.lua")')
    LuaRuntime().execute('dofile("tests/phasing.lua")')
    LuaRuntime().execute('dofile("tests/quests.lua")')
    sys.exit(0)

lib = ctypes.CDLL('liblua5.4.so.0')
lib.luaL_newstate.restype = ctypes.c_void_p
lib.luaL_openlibs.argtypes = [ctypes.c_void_p]
lib.luaL_loadfilex.argtypes = [ctypes.c_void_p, ctypes.c_char_p, ctypes.c_char_p]
lib.lua_pcallk.argtypes = [ctypes.c_void_p, ctypes.c_int, ctypes.c_int, ctypes.c_int, ctypes.c_longlong, ctypes.c_void_p]
lib.lua_tolstring.argtypes = [ctypes.c_void_p, ctypes.c_int, ctypes.c_void_p]
lib.lua_tolstring.restype = ctypes.c_char_p
lib.lua_settop.argtypes = [ctypes.c_void_p, ctypes.c_int]
lib.lua_close.argtypes = [ctypes.c_void_p]
state = lib.luaL_newstate()
lib.luaL_openlibs(state)
root = Path(__file__).resolve().parents[1]
for path in root.glob('*.lua'):
    result = lib.luaL_loadfilex(state, str(path).encode(), None)
    if result:
        raise RuntimeError(lib.lua_tolstring(state, -1, None).decode())
    lib.lua_settop(state, 0)
    print('Syntax OK:', path.name)
import os
os.chdir(root)
result = lib.luaL_loadfilex(state, str(root / 'tests/mock.lua').encode(), None)
if not result:
    result = lib.lua_pcallk(state, 0, 0, 0, 0, None)
if result:
    raise RuntimeError(lib.lua_tolstring(state, -1, None).decode())
lib.lua_close(state)
state = lib.luaL_newstate()
lib.luaL_openlibs(state)
result = lib.luaL_loadfilex(state, str(root / 'tests/quests.lua').encode(), None)
if not result:
    result = lib.lua_pcallk(state, 0, 0, 0, 0, None)
if result:
    raise RuntimeError(lib.lua_tolstring(state, -1, None).decode())
lib.lua_close(state)
state = lib.luaL_newstate()
lib.luaL_openlibs(state)
result = lib.luaL_loadfilex(state, str(root / 'tests/phasing.lua').encode(), None)
if not result:
    result = lib.lua_pcallk(state, 0, 0, 0, 0, None)
if result:
    raise RuntimeError(lib.lua_tolstring(state, -1, None).decode())
lib.lua_close(state)
