
# .PHONY: all

# all: game.gb

# game.gb: build build/sample.o build/main.o
# 	rgblink --dmg --tiny --map game.map --sym game.sym -o game.gb build/main.o build/sample.o
# 	rgbfix -v -p 0xFF game.gb

# build:
# 	mkdir build

# build/sample.o: build src/sample.asm src/hardware.inc src/utils.inc assets/*.tlm assets/*.chr
# 	rgbasm -o build/sample.o src/sample.asm

# build/main.o: build src/main.asm src/hardware.inc assets/*.tlm assets/*.chr
# 	rgbasm -o build/main.o src/main.asm

.PHONY: all

all: game.gb

game.gb: build/main.o build/graphics.o build/player.o
	rgblink --dmg --map game.map --sym game.sym -o game.gb build/main.o build/graphics.o build/player.o
	rgbfix -v -p 0xFF game.gb

build/main.o: src/main.asm src/*.inc build
	rgbasm -o build/main.o src/main.asm

build/graphics.o: src/graphics.asm src/*.inc assets/*.tlm assets/*.chr build
	rgbasm -o build/graphics.o src/graphics.asm

build/player.o: src/player.asm src/*.inc assets/*.tlm assets/*.chr build
	rgbasm -o build/player.o src/player.asm

build:
	mkdir build
