; Super Metroid ExHiROM patch

exhirom

!SRAM_BANK = #$00A1
!SRAM_BASE = $A16000    ; Select where SRAM is mapped to (default is a0:6000-7FFF)

org $C08000             ; Disable copy protection screen
    db $FF

;========================== SRAM Load/Save Repoint ===============================
org $C08257
    sta !SRAM_BASE+$1FE0,x

org $C0828A
    sta !SRAM_BASE+$1FE0,x

org $C08297
    lda !SRAM_BASE+$1FE0,x

org $C08698
    lda !SRAM_BASE,x

org $C086AA
    sta !SRAM_BASE,x

org $C086B8
    sta !SRAM_BASE,x

org $C086C7
    cmp !SRAM_BASE,x

org $C086D9
    sta !SRAM_BASE,x

org $C18056
    sta !SRAM_BASE,x

org $C1806C
    sta !SRAM_BASE,x
    sta !SRAM_BASE+$1FF0,x
    eor #$FFFF
    sta !SRAM_BASE+$0008,x
    sta !SRAM_BASE+$1FF8,x

org $C180A0
    lda !SRAM_BASE,x

org $C180B9
    cmp !SRAM_BASE,x

org $C180C2
    cmp !SRAM_BASE+$0008,x

org $C180CC
    cmp !SRAM_BASE+$1FF0,x

org $C180D5
    cmp !SRAM_BASE+$1FF8,x

org $C1810B
    sta !SRAM_BASE,x

org $C19ED8
    lda !SRAM_BASE+$1FEC

org $C19EE7
    and !SRAM_BASE+$1FEE

org $C19CCB
    sta !SRAM_BASE,x
    sta !SRAM_BASE+$0008,x
    sta !SRAM_BASE+$1FF0,x
    sta !SRAM_BASE+$1FF8,x

org $C1A23C
    sta !SRAM_BASE+$1FEC

org $C1A243
    sta !SRAM_BASE+$1FEE

org $C19A3B
    lda !SRAM_BANK

org $C19A58
    ldy #$6000

org $C19A61
    cpy #$665C

org $C19A6B
    lda !SRAM_BASE+$1FF0,x
    pha
    lda !SRAM_BASE+$1FF8,X
    pha
    lda !SRAM_BASE,x
    pha
    lda !SRAM_BASE+$0008,x
    pha

org $C19A85
    sta !SRAM_BASE+$0008,x
    pla
    sta !SRAM_BASE,x
    pla
    sta !SRAM_BASE+$1FF8,x
    pla
    sta !SRAM_BASE+$1FF0,x

org $C19CA4
    lda !SRAM_BANK

org $C19CB4
    ldy #$6000

org $C19CBE
    cpy #$665C
;==================================================================================


;========================== Music/SFX Bank Loading ===============================
org $C08044         ; Patch music loading code to load from $0000-7FFF banks
    jmp $FF00

org $C0FF00         ; This patch will subtract $8000 from the initial music bank
    rep #$20        ; address so it correctly loads from the lower bank
    lda $00
    and #$7FFF
    tay
    sep #$20
    lda $02
    jmp $8048

org $C08101         ; These patches adjusts the music loading to wrap to next bank
    bmi nextbank    ; at 0x8000
org $C08104
    bmi nextbank

org $C08107
nextbank:

org $C0810D         ; Start at $0000 in the new bank and not $8000
    ldy #$0000
;==================================================================================


;=========================== Decompression routines ===============================
org $C0B266                         ; Modify the bank wrapping routine to detect if
    jmp wrap_bank                   ; bank >= $C0 and in that case wrap at $8000


org $C0B12F                         ; Modify decompression routines to wrap banks
    jsr check_wrap : nop : nop      ; differently depending on what bank decompression§
                                    ; is done from. This needs a lot of optimization.
org $C0B15A
    jsr check_wrap : nop : nop      ; Decomp > WRAM

org $C0B189
    jsr check_wrap : nop : nop

org $C0B1A0
    jsr check_wrap : nop : nop

org $C0B1B8
    jsr check_wrap : nop : nop

org $C0B1C9
    jsr check_wrap : nop : nop

org $C0B1ED
    jsr check_wrap : nop : nop

org $C0B20E
    jsr check_wrap : nop : nop

org $C0B21F
    jsr check_wrap : nop : nop

org $C0B250
    jsr check_wrap : nop : nop

org $C0B286                         ; Decomp > RAM
    jsr check_wrap : nop : nop

org $C0B2B1
    jsr check_wrap : nop : nop

org $C0B2E3
    jsr check_wrap : nop : nop

org $C0B309
    jsr check_wrap : nop : nop

org $C0B32F
    jsr check_wrap : nop : nop

org $C0B340
    jsr check_wrap : nop : nop

org $C0B380
    jsr check_wrap : nop : nop

org $C0B3AF
    jsr check_wrap : nop : nop

org $C0B3C0
    jsr check_wrap : nop : nop

org $C0B421
    jsr check_wrap : nop : nop

org $C0B123                         ; Check the starting bank and if it's >= $C0
    jmp modify_address_ram          ; then subtract $8000 from the starting address

org $C0B27B
    jmp modify_address_vram
;==================================================================================


;================================ Hud fixes ========================================
org $C09B4A
    jmp fix_hud_digits  ; Make HUD digits load from bank 80 instead of 00
;==================================================================================


;============================== New hook routines =================================
org $C0FE00
wrap_bank:
    pha
    phb
    pla
    cmp #$BF            ; If bank >= $BF, set X to $0000, else $8000
    bcc +
    ldx #$0000
    jmp $B26A
+
    ldx #$8000
    jmp $B26A

check_wrap:
    pha
    phb
    pla
    cmp #$C0            ; If bank >= $C0, check wrap at $8000, else $0000
    bcc +
    cpx #$8000
    bne ++
    jsr $B266
    jmp ++
+
    cpx #$0000
    bne ++
    jsr $B266
    jmp ++
++
    pla
    rts

modify_address_ram:
    pha
    lda $49
    cmp #$C0            ; IF bank >=$C0, set to lower address space
    bcc +
    rep #$20
    lda $47
    and #$7FFF
    sta $47
    sep #$20

+
    pla                 ; Restore A and execute hijacked code
    stz $50
    ldy #$0000
    jmp $B128

modify_address_vram:
    pha
    lda $49
    cmp #$C0            ; IF bank >=$C0, set to lower address space
    bcc +
    rep #$20
    lda $47
    and #$7FFF
    sta $47
    sep #$20

+
    pla                 ; Restore A and execute hijacked code
    stz $50
    ldy $4C
    jmp $B27F

fix_hud_digits:
    sep #$20
    lda #$80
    sta $02
    rep #$30
    jmp $9B4E
;==================================================================================
