;
; CS-240 World 6: First Draft
;
; @file player.asm
; @authors Asher Kaplan and Sydney Eriksson
; @date April 14, 2025
include "src/utils.inc"

section "sound", rom0

torch_light_sound:
    Copy [rNR10], $00
    Copy [rNR11], $80
    Copy [rNR12], $F3
    Copy [rNR13], $99
    Copy [rNR14], $87
    ret

door_open_sound:
    Copy [rNR10], $17
    Copy [rNR11], $80
    Copy [rNR12], $F0
    Copy [rNR13], $89
    Copy [rNR14], $C5
    ret

player_death_sound:
    Copy [rNR10], $1F
    Copy [rNR11], $80
    Copy [rNR12], $F0
    Copy [rNR13], $0B
    Copy [rNR14], $C6
    ret

export torch_light_sound, player_death_sound, door_open_sound