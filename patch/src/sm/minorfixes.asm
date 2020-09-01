; Fix music coming into the maridia portal
org $CFD924
    db $1B, $05

; Fix for escape bomb block softlock by Capn
; Hijack the door ASM
org $CFE4CF
base $8FE4CF
    jsr NewShaftDoorASM
    rts

; Free space at EC00
org $CFEC00
base $8FEC00
NewShaftDoorASM:
    ; Start with Original ASM functions
    php
    %a8()
    lda #$01
    sta $7ECD38
    lda #$00
    sta $7ECD39
    ; Set all blocks in RAM to air
    ; Got lucky here that asm code is done after tile loading ^_^
    %a16()
    lda #$00FF
    sta $7F3262
    sta $7F3264
    sta $7F32C2
    sta $7F32C4
    sta $7F3322
    sta $7F3324
    sta $7F3382
    sta $7F3384
    plp
    rts
