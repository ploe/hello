assemble = rgbasm -i ./include/

all: gfx asm link fix

asm:
	$(assemble) -o main.o main.asm
	$(assemble) -o joypad.o joypad.asm

clean:
	rm -v *.o *.2bpp

fix:
	rgbfix -v -p 0 hello-world.gb

gfx:
	rgbgfx -u -o blob.2bpp blob.png

link:
	rgblink -o hello-world.gb main.o joypad.o

