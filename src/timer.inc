;
; CS-240 World 8: Final Game
;
; @file timer.inc
; @authors Asher Kaplan and Sydney Eriksson
; @date April 30, 2025
; @brief math to determine game levels and loops per second
; @license Copyright 2025 Asher Kaplan and Sydney Eriksson

def HALTS_PER_SECOND        equ 60
def HALTS_IN_MAIN_LOOP      equ 4
def LOOPS_PER_SECOND        equ (HALTS_PER_SECOND / HALTS_IN_MAIN_LOOP)

def LEVEL_1                 equ 1
def LEVEL_2                 equ 2
def LEVEL_3                 equ 3
def GAME_OVER               equ 4