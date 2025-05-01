.PHONY: all

all: game.gb

game.gb: build/main.o build/graphics.o build/player.o build/door.o build/collision.o build/torch.o build/water.o build/sound.o build/timer.o build/level_1.o build/level_2.o build/level_3.o
	rgblink --dmg --map game.map --sym game.sym -o game.gb build/main.o build/graphics.o build/player.o build/door.o build/collision.o build/torch.o build/water.o build/sound.o build/timer.o build/level_1.o build/level_2.o build/level_3.o
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

build/water.o: src/water.asm src/*.inc assets/*.tlm assets/*.chr build
	rgbasm -o build/water.o src/water.asm

build/sound.o: src/sound.asm src/*.inc assets/*.tlm assets/*.chr build
	rgbasm -o build/sound.o src/sound.asm

build/timer.o: src/timer.asm src/*.inc assets/*.tlm assets/*.chr build
	rgbasm -o build/timer.o src/timer.asm

build/level_1.o: src/level_1.asm src/*.inc assets/*.tlm assets/*.chr build
	rgbasm -o build/level_1.o src/level_1.asm

build/level_2.o: src/level_2.asm src/*.inc assets/*.tlm assets/*.chr build
	rgbasm -o build/level_2.o src/level_2.asm

build/level_3.o: src/level_3.asm src/*.inc assets/*.tlm assets/*.chr build
	rgbasm -o build/level_3.o src/level_3.asm


build:
	mkdir build
