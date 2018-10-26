all:
	rgbgfx -u -o blob.2bpp blob.png
	rgbasm -o main.o main.asm
	rgbasm -o joypad.o joypad.asm
	rgblink -o hello-world.gb main.o joypad.o
	rgbfix -v -p 0 hello-world.gb
