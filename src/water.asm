;
; CS-240 World 8: Final Game
;
; @file water.asm
; @authors Asher Kaplan and Sydney Eriksson
; @date April 30, 2025

include "src/utils.inc"
include "src/wram.inc"
include "src/sprites.inc"
include "src/hardware.inc"
include "src/joypad.inc"
include "src/graphics.inc"

section "water", rom0

macro WaterMove
    push af
    push de
    ld a, d
    cp a, 1
    jr z, .done\@
        ld a, [\1 + OAMA_TILEID]
        cp a, END_WATER_TILE_ID
        jr nc, .done\@
            ; change between the flickering tileIDs
            inc a
            cp a, END_WATER_TILE_ID
            jr c, .skip_reset\@
                ld a, WATER_ID
            .skip_reset\@
            Copy [\1 + OAMA_TILEID], a
    .done\@
    pop de
    pop af 
    endm 

move_water:
    WaterMove WATER_1
    WaterMove WATER_2
    WaterMove WATER_3
    WaterMove WATER_4
    WaterMove WATER_5 
    ret


; check if the player is touching any of the water sprite tiles
; return z if touching, nz if not
evaporate_possible:
    push bc
    push de
    push hl
    ; get the player location
    ld a, [WRAM_PLAYER + SPRITE_X]
    add a, FLOATING_OFFSET
    ld b, a
    ld a, [WRAM_PLAYER + SPRITE_Y]
    add a, FLOATING_OFFSET
    ld c, a

    ;check if player is touching any of the water sprites
    Copy d, [WATER_1 + OAMA_X]
    Copy e, [WATER_1 + OAMA_Y]
    FindOverlappingSprite b, c, d, e
    jp z, .done

    Copy d, [WATER_2 + OAMA_X]
    Copy e, [WATER_2 + OAMA_Y]
    FindOverlappingSprite b, c, d, e
    jp z, .done
    
    Copy d, [WATER_3 + OAMA_X]
    Copy e, [WATER_3 + OAMA_Y]
    FindOverlappingSprite b, c, d, e
    jp z, .done

    Copy d, [WATER_4 + OAMA_X]
    Copy e, [WATER_4 + OAMA_Y]
    FindOverlappingSprite b, c, d, e
    jp z, .done

    Copy d, [WATER_5 + OAMA_X]
    Copy e, [WATER_5 + OAMA_Y]
    FindOverlappingSprite b, c, d, e
    jp z, .done

    Copy d, [LARGE_SPIKE_1 + OAMA_X]
    Copy e, [LARGE_SPIKE_1 + OAMA_Y]
    FindOverlappingSprite b, c, d, e
    jp z, .done

    Copy d, [LARGE_SPIKE_2 + OAMA_X]
    Copy e, [LARGE_SPIKE_2 + OAMA_Y]
    FindOverlappingSprite b, c, d, e
    jp z, .done

    Copy d, [SMALL_SPIKE_1 + OAMA_X]
    Copy e, [SMALL_SPIKE_1 + OAMA_Y]
    FindOverlappingSprite b, c, d, e
    jp z, .done

    Copy d, [SMALL_SPIKE_2 + OAMA_X]
    Copy e, [SMALL_SPIKE_2 + OAMA_Y]
    FindOverlappingSprite b, c, d, e
    jp z, .done

    Copy d, [SMALL_SPIKE_3 + OAMA_X]
    Copy e, [SMALL_SPIKE_3 + OAMA_Y]
    FindOverlappingSprite b, c, d, e

    .done
    pop hl
    pop de
    pop bc
    ret

; causes the player to die if it touches 
;       the water, and goes to the game over screen
fire_evaporate:
    call evaporate_possible
    jr nz, .stay_alive
        call player_death_sound
        ; if the player is touching the water, load the game_over screen
        call game_over
    .stay_alive
    ret

export fire_evaporate, init_waters, move_water