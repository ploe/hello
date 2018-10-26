assemble = rgbasm -i ./include/

all: gfx asm link fix

asm:
	$(assemble) -o main.o ./src/main.asm
	$(assemble) -o joypad.o ./src/joypad.asm
	$(assemble) -o blob.o ./src/blob.asm

clean:
	rm -v *.o *.2bpp

fix:
	rgbfix -v -p 0 hello-world.gb

gfx:
	rgbgfx -u -o blob.2bpp ./png/blob.png

link:
	rgblink -o hello-world.gb blob.o joypad.o main.o
