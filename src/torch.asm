;
; CS-240 World 8: Final Game
;
; @file torch.asm
; @authors Asher Kaplan and Sydney Eriksson
; @date April 30, 2025
; @brief macros and functions to control the torch sprites
; @license Copyright 2025 Asher Kaplan and Sydney Eriksson

include "src/utils.inc"
include "src/wram.inc"
include "src/sprites.inc"

section "torch", rom0

; adds a number (\1) to hl
; returns sum in hl
macro AddToHL
    ld a, l
    add a, \1
    ld l, a
    ld a, h
    adc a, 0
    ld h, a
endm

; makes the torch flicker
; \1 is the torch sprite ID
macro TorchFlicker
    push af
    ld a, [\1 + TILE_ID]
    cp a, UNLIT_TORCH_TILE_ID
    jr z, .done\@
        ; change between the flickering tileIDs
        inc a
        cp a, END_TORCH_FLICKER_TILE_ID
        jr c, .skip_reset\@
            ld a, START_TORCH_FLICKER_TILE_ID
        .skip_reset\@
        Copy [\1 + OAMA_TILEID], a
    .done\@
    pop af
    endm 

load_torches_into_WRAM:
    LoadWramData WRAM_TORCH_1, [TORCH_1 + OAMA_X], [TORCH_1 + OAMA_Y], [TORCH_1 + OAMA_TILEID], [TORCH_1 + OAMA_FLAGS]
    LoadWramData WRAM_TORCH_2, [TORCH_2 + OAMA_X], [TORCH_2 + OAMA_Y], [TORCH_2 + OAMA_TILEID], [TORCH_2 + OAMA_FLAGS]
    LoadWramData WRAM_TORCH_3, [TORCH_3 + OAMA_X], [TORCH_3 + OAMA_Y], [TORCH_3 + OAMA_TILEID], [TORCH_3 + OAMA_FLAGS]
    LoadWramData WRAM_TORCH_4, [TORCH_4 + OAMA_X], [TORCH_4 + OAMA_Y], [TORCH_4 + OAMA_TILEID], [TORCH_4 + OAMA_FLAGS]
    ret

flicker_torches:
    TorchFlicker WRAM_TORCH_1
    TorchFlicker WRAM_TORCH_2
    TorchFlicker WRAM_TORCH_3
    TorchFlicker WRAM_TORCH_4
    ret

update_torches_from_WRAM:
    LoadSpriteData TORCH_1, [WRAM_TORCH_1 + SPRITE_X], [WRAM_TORCH_1 + SPRITE_Y], [WRAM_TORCH_1 + TILE_ID], [WRAM_TORCH_1 + FLAGS]
    LoadSpriteData TORCH_2, [WRAM_TORCH_2 + SPRITE_X], [WRAM_TORCH_2 + SPRITE_Y], [WRAM_TORCH_2 + TILE_ID], [WRAM_TORCH_2 + FLAGS]
    LoadSpriteData TORCH_3, [WRAM_TORCH_3 + SPRITE_X], [WRAM_TORCH_3 + SPRITE_Y], [WRAM_TORCH_3 + TILE_ID], [WRAM_TORCH_3 + FLAGS]
    LoadSpriteData TORCH_4, [WRAM_TORCH_4 + SPRITE_X], [WRAM_TORCH_4 + SPRITE_Y], [WRAM_TORCH_4 + TILE_ID], [WRAM_TORCH_4 + FLAGS]
    ret

; check all torches (sprites after the doors but before the water?)
; return whichever torch is overlapping in hl
; also returns z if overlapping a torch and nz if not
light_possible:
    push bc
    push de
    ; Get player location
    ld a, [WRAM_PLAYER + SPRITE_X]
    add a, FLOATING_OFFSET
    ld b, a
    ld a, [WRAM_PLAYER + SPRITE_Y]
    add a, FLOATING_OFFSET
    ld c, a

    ; Check each torch to see if overlapping
    ;Copy d, [WRAM_TORCH_1 + SPRITE_X]
    ;Copy e, [WRAM_TORCH_1 + SPRITE_Y]
    FindOverlappingSprite b, c, SPRITE_X, SPRITE_Y, WRAM_TORCH_1
    jp nz, .torch_2
        ld hl, WRAM_TORCH_1
        jp .done

    .torch_2
    ;Copy d, [WRAM_TORCH_2 + SPRITE_X]
    ;Copy e, [WRAM_TORCH_2 + SPRITE_Y]
    FindOverlappingSprite b, c, SPRITE_X, SPRITE_Y, WRAM_TORCH_2
    jp nz, .torch_3
        ld hl, WRAM_TORCH_2
        jp .done

    .torch_3
    ;Copy d, [WRAM_TORCH_3 + SPRITE_X]
    ;Copy e, [WRAM_TORCH_3 + SPRITE_Y]
    FindOverlappingSprite b, c, SPRITE_X, SPRITE_Y, WRAM_TORCH_3
    jp nz, .torch_4
        ld hl, WRAM_TORCH_3
        jp .done

    .torch_4
    ;Copy d, [WRAM_TORCH_4 + SPRITE_X]
    ;Copy e, [WRAM_TORCH_4 + SPRITE_Y]
    FindOverlappingSprite b, c, SPRITE_X, SPRITE_Y, WRAM_TORCH_4
    jr nz, .done
        ld hl, WRAM_TORCH_4

    .done
    pop de
    pop bc
    ret

; lights a torch if the player is in front of an unlit torch and DOWN is being held
light_torch:
    push hl
    ; get the joypad buttons that are being held!
    ld a, [PAD_CURR]

    ; Is DOWN being held?
    bit PADB_DOWN, a
    jr nz, .dont_light
        ; Check if player is infront of a torch
        call light_possible
        jr nz, .dont_light
            call torch_light_sound
            AddToHL TILE_ID
            Copy [hl], START_TORCH_FLICKER_TILE_ID

    .dont_light
    pop hl
    ret

; opens door if all torches lit
check_all_torches_lit:
    Copy a, [LEFT_DOOR + OAMA_TILEID]
    cp a, LEFT_DOOR_OPEN_ID
    jr z, .done
        Copy a, [TORCH_1 + OAMA_TILEID]
        cp a, START_TORCH_FLICKER_TILE_ID
        jr c, .done

        Copy a, [TORCH_2 + OAMA_TILEID]
        cp a, START_TORCH_FLICKER_TILE_ID
        jr c, .done

        Copy a, [TORCH_3 + OAMA_TILEID]
        cp a, START_TORCH_FLICKER_TILE_ID
        jr c, .done

        Copy a, [TORCH_4 + OAMA_TILEID]
        cp a, START_TORCH_FLICKER_TILE_ID
        jr c, .done

    call open_door
    .done
    ret
    
export init_level_1_torches, init_level_2_torches, init_level_3_torches, light_torch, check_all_torches_lit, flicker_torches, load_torches_into_WRAM, update_torches_from_WRAM