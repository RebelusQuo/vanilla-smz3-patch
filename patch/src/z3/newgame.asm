; When starting a new game, run this code

; Only copies the "new file" SRAM into the ALTTP SRAM slot right now (only file 1 works)

org $5E0000
alttp_new_game:
    pha
    phx
    phy
    php
    %ai16()

    ldx #$0000
-
    lda #$0000
    sta.l $A06000,x
    inx
    inx
    cpx #$2000
    bne -

    ;jsl zelda_fix_checksum

    plp
    ply
    plx
    pla
    rtl

alttp_sram:
    incbin "../data/zelda-sram.bin"
