;
; CS-240 World 7: Feature Complete
;
; @file timer.inc
; @authors Asher Kaplan and Sydney Eriksson
; @date April 21, 2025

def HALTS_PER_SECOND        equ 60
def HALTS_IN_MAIN_LOOP      equ 5
def LOOPS_PER_SECOND        equ (HALTS_PER_SECOND / HALTS_IN_MAIN_LOOP)

def LEVEL_1                 equ 1
def LEVEL_2                 equ 2
def LEVEL_3                 equ 3
def GAME_OVER               equ 4