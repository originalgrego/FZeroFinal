SET ROM_DIR=..\SNES_ROMS

del "%ROM_DIR%\F-Zero_Final.sfc"

copy "%ROM_DIR%\F-Zero.sfc" "%ROM_DIR%\F-Zero_Final.sfc"

xkas.exe F-Zero_Final.asm "%ROM_DIR%\F-Zero_Final.sfc"
