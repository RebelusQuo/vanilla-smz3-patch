exhirom

; --- Macros and stuff ---
incsrc "macros.asm"                         ; Useful macros
incsrc "sram.asm"                           ; SRAM Variable definitions

; --- Common code ---
incsrc "common.asm"                         ; Common routines
incsrc "credits.asm"                        ; Common credits scroller
incsrc "spc_play.asm"                       ; Common SPC player

; --- Super Metroid code ---
incsrc "sm/hirom.asm"                       ; Super Metroid ExHiROM patch
incsrc "sm/transition.asm"                  ; Super Metroid Transition patch
incsrc "sm/teleport.asm"                    ; Super Metroid Teleport patch
incsrc "sm/randomizer/randomizer.asm"       ; Super Metroid Randomizer patches
; Skipped Super Metroid ALTTP Items patch
incsrc "sm/ending.asm"                      ; Super Metroid Ending conditions
incsrc "sm/newgame.asm"                     ; Super Metroid New Game Initialization
; Skipped Super Metroid Remove Item fanfares
incsrc "sm/minorfixes.asm"                  ; Super Metroid some softlock removals etc
incsrc "sm/demofix.asm"                     ; Super Metroid Stop demos from playing
incsrc "sm/maps.asm"                        ; Super Metroid map pause screen and HUD changes
incsrc "sm/max_ammo.asm"                    ; Super Metroid max ammo patch by personitis, adapted by Leno for Crossover

; --- ALTTP code ---
incsrc "z3/hirom.asm"                       ; ALTTP ExHiROM patch
incsrc "z3/transition.asm"                  ; ALTTP Transition patch
incsrc "z3/teleport.asm"                    ; ALTTP Teleport patch
; Skipped ALTTP Randomizer patches (github.com/mmxbass/z3randomizer)
; Skipped ALTTP Super Metroid Items
incsrc "z3/ending.asm"                      ; ALTTP Ending Conditions
incsrc "z3/newgame.asm"                     ; ALTTP New Game Initialization


org $C7FA00
base $87FA00
FrameHookAction:
    JSL $0080B5     ; Module_MainRouting
    RTL
