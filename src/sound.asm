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
    Copy [rNR10], $6D;17
    Copy [rNR11], $00;80
    Copy [rNR12], $F1;F0
    Copy [rNR13], $72;89
    Copy [rNR14], $C6;C5
    ret

player_death_sound:
    Copy [rNR10], $2C;1F
    Copy [rNR11], $C0;80
    Copy [rNR12], $F9;F0
    Copy [rNR13], $27;0B
    Copy [rNR14], $C6;C6
    ret

export torch_light_sound, player_death_sound, door_open_sound