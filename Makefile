assemble = rgbasm -i ./include/

all: gfx asm link fix

asm:
	$(assemble) -o blob.o ./src/blob.asm
	$(assemble) -o hram.o ./src/hram.asm
	$(assemble) -o joypad.o ./src/joypad.asm
	$(assemble) -o main.o ./src/main.asm
	$(assemble) -o screen.o ./src/screen.asm
	$(assemble) -o vram.o ./src/vram.asm
	$(assemble) -o wram0.o ./src/wram0.asm

clean:
	rm -v *.o *.2bpp

fix:
	rgbfix -v -p 0 hello-world.gb

gfx:
	rgbgfx -u -o blob.2bpp ./png/blob.png
	rgbgfx -u -o stick.2bpp ./png/stick.png

link:
	rgblink -n hello-world.sym -o hello-world.gb blob.o hram.o joypad.o main.o screen.o vram.o wram0.o
