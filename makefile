.PHONY: all

all: game.gb

game.gb: build/main.o build/graphics.o build/player.o build/door.o build/collision.o build/torch.o
	rgblink --dmg --map game.map --sym game.sym -o game.gb build/main.o build/graphics.o build/player.o build/door.o build/collision.o build/torch.o
	rgbfix -v -p 0xFF game.gb

build/main.o: src/main.asm src/*.inc build
	rgbasm -o build/main.o src/main.asm

build/graphics.o: src/graphics.asm src/*.inc assets/*.tlm assets/*.chr build
	rgbasm -o build/graphics.o src/graphics.asm

build/player.o: src/player.asm src/*.inc assets/*.tlm assets/*.chr build
	rgbasm -o build/player.o src/player.asm

build/door.o: src/door.asm src/*.inc assets/*.tlm assets/*.chr build
	rgbasm -o build/door.o src/door.asm

build/collision.o: src/collision.asm src/*.inc assets/*.tlm assets/*.chr build
	rgbasm -o build/collision.o src/collision.asm

build/torch.o: src/torch.asm src/*.inc assets/*.tlm assets/*.chr build
	rgbasm -o build/torch.o src/torch.asm


build:
	mkdir build
