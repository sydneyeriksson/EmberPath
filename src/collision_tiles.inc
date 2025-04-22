;
; CS-240 World 7: Feature Complete
;
; @file collision_tiles.inc
; @authors Asher Kaplan and Sydney Eriksson
; @date April 21, 2025

if !def(COLLISION_TILES_RGBINC)
def COLLISION_TILES_RGBINC equ 1

section "collision tiles", rom0

; sprites do not cause collisions
db %00000000
db %00000000
db %00000000
db %00000000
db %00000000
db %00000000
db %00000000
db %00000000
db %00000000
db %00000000
db %00000000
db %00000000
db %00000000
db %00000000
db %00000000
db %00000000
db %11100001
db %11000000
db %10100001
db %01000000
db %11100001
db %11000000
db %11001111
db %10000111
db %00111110
db %00000000

endc