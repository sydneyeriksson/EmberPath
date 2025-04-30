;
; CS-240 World 7: Feature Complete
;
; @file sound.asm
; @authors Asher Kaplan and Sydney Eriksson
; @date April 21, 2025
include "src/utils.inc"

section "sound", rom0

torch_light_sound:
    Copy [rNR10], $35;00
    Copy [rNR11], $0B;80
    Copy [rNR12], $F9;F3
    Copy [rNR13], $27;99
    Copy [rNR14], $C6;87
    ret

door_open_sound:
    Copy [rNR10], $5B;17
    Copy [rNR11], $11;80
    Copy [rNR12], $F9;F0
    Copy [rNR13], $27;89
    Copy [rNR14], $C6;C5
    ret

player_death_sound:
    Copy [rNR10], $7A;1F
    Copy [rNR11], $80;80
    Copy [rNR12], $F8;F0
    Copy [rNR13], $42;0B
    Copy [rNR14], $C6;C6
    ret

next_level_sound:
    Copy [rNR10], $75;1F
    Copy [rNR11], $11;80
    Copy [rNR12], $F8;F0
    Copy [rNR13], $13;0B
    Copy [rNR14], $C6;C6
    ret

export torch_light_sound, player_death_sound, door_open_sound, next_level_sound