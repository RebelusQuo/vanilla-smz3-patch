; Check for specific door and teleport to ALTTP

org $C2E2FA
    jsl sm_check_teleport

org $F24000
sm_check_teleport:
    phx
    pha
    php
    %ai16()

    ldx #$0000
-
    lda.l sm_teleport_table,x
    beq ++
    cmp $078D
    beq +
    txa
    clc
    adc #$0038
    tax
    bne -
    jmp ++
+
    jmp sm_do_teleport
++
    plp
    pla
    plx
    jsl $8882AC
    rtl

sm_do_teleport:
    lda.l sm_teleport_table+$2,x
    sta !SRAM_ALTTP_EXIT            ; Store ALTTP exit id
    lda.l sm_teleport_table+$4,x
    sta !SRAM_ALTTP_DARKWORLD       ; Store dark world status

    ldy #$0000
-
    lda.l sm_teleport_table+$6,x
    phx
    tyx
    sta.l !SRAM_ALTTP_OVERWORLD_BUF,x
    plx
    inx
    inx
    iny
    iny
    cpy #$0032
    bne -

    lda #$001C                      ; Add transition to ALTTP
    jsl inc_stat

    jsl $8085C6                     ; Save map data

    lda #$0000
    jsl $818000                     ; Save SRAM

    lda #$0000
    sta.l $A16166
    sta.l $A16168                   ; Set these values to 0 to force load from the ship if samus dies
    jsl sm_fix_checksum             ; Fix SRAM checksum (otherwise SM deletes the file on load)

    jml transition_to_zelda         ; Call transition routine to ALTTP

sm_teleport_table:
    ; door_id, cave_id, darkworld, [0x20 bytes from $7EC140-7EC150 (Overworld position / scroll data)]
    ; Crateria map station -> Fortune teller
    dw $8976, $0122, $0000
        db $35, $00, $16, $00, $6A, $0C, $00, $0A, $C8, $0C, $58, $0A, $35, $00, $80, $03
        db $D7, $0C, $7D, $0A, $00, $0C, $1E, $0F, $00, $0A, $00, $0D, $20, $0B, $00, $10
        db $00, $09, $00, $0E, $00, $20, $27, $04, $00, $00, $06, $00, $FA, $FF, $00, $00
        db $00, $00

    ; Norfair map station -> Cave on death mountain             97C2
    dw $9306, $00E5, $0000
        db $03, $00, $16, $01, $26, $02, $1E, $08, $87, $02, $88, $08, $03, $00, $C2, $10
        db $93, $02, $93, $08, $00, $00, $1E, $03, $00, $06, $00, $09, $20, $FF, $00, $04
        db $00, $05, $00, $0A, $00, $20, $22, $10, $00, $00, $08, $00, $F8, $FF, $02, $00
        db $FE, $FF

    ; Maridia missile refill -> Dark world ice rod cave (right) A894
    dw $A8F4, $010E, $0040
        db $77, $00, $16, $00, $00, $0C, $22, $0E, $47, $0C, $98, $0E, $77, $00, $86, $00
        db $6F, $0C, $A3, $0E, $00, $0C, $1E, $0D, $00, $0E, $00, $0F, $20, $0B, $00, $0E
        db $00, $0D, $00, $10, $00, $21, $40, $19, $00, $00, $00, $00, $00, $00, $0E, $00
        db $F2, $FF

    ; LN GT refill -> Misery mire right side fairy              98A6
    dw $9A7A, $0115, $0040
        db $70, $00, $16, $01, $64, $0C, $36, $01, $C7, $0C, $B8, $01, $70, $00, $26, $03
        db $D3, $0C, $C1, $01, $00, $0C, $1E, $0F, $00, $00, $00, $03, $20, $0B, $00, $10
        db $00, $FF, $00, $04, $00, $21, $42, $16, $00, $00, $0A, $00, $F6, $FF, $FA, $FF
        db $06, $00

    dw $0000


; This must be placed below $8000 in a bank due to SM music upload code changes
alttp_spc_data:         ; Upload this data to the SM music engine to kill it and put it back into IPL mode
    dw $002A, $15A0
    db $8F, $6C, $F2
    db $8F, $E0, $F3    ; Disable echo buffer writes and mute amplifier
    db $8F, $7C, $F2
    db $8F, $FF, $F3    ; ENDX
    db $8F, $7D, $F2
    db $8F, $00, $F3    ; Disable echo delay
    db $8F, $4D, $F2
    db $8F, $00, $F3    ; EON
    db $8F, $5C, $F2
    db $8F, $FF, $F3    ; KOFF
    db $8F, $5C, $F2
    db $8F, $00, $F3    ; KOFF
    db $8F, $80, $F1    ; Enable IPL ROM
    db $5F, $C0, $FF    ; jmp $FFC0
    dw $0000, $1500
