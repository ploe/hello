all:
	rgbgfx -u -o blob.2bpp blob.png
	rgbasm -o main.o main.asm
	rgblink -o hello-world.gb main.o
	rgbfix -v -p 0 hello-world.gb
