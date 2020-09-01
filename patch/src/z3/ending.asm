; prevent ending without beating both games

; Hook Link entering triforce room
org $02B797
    jml alttp_check_ending

org $0EE645
    jml alttp_setup_credits

org $F7FE00
base $B7FE00
alttp_check_ending:
    lda.b #$01
    sta.l !SRAM_ALTTP_COMPLETED
    lda.l !SRAM_SM_COMPLETED
    bne .sm_completed
    lda.b #$08 : sta $010C
    lda.b #$0F : sta $10
    lda.b #$20 : sta $A0
    lda.b #$00 : sta $A1

    stz $11
    stz $B0

    jsl $09AC57                 ; Ancilla_TerminateSelectInteractives
    lda $0362 : beq .exit
    stz $4D : stz $46
    lda.b #$FF : sta $29 : sta $C7
    stz $3D : stz $5E : stz $032B : stz $0372
    lda.b #$00 : sta $5D

    lda.b #$00 : sta $0ABD      ; Set Link to not use alternate palette
    bra .exit

.sm_completed
    lda.b #$19 : sta $10
    stz $11 : stz $B0

.exit
    plb
    rtl

alttp_setup_credits:
    %ai16()
    sei
    lda #$0000
    sta $4200

    %a8()
    jsl $00894A                 ; Save ALTTP SRAM so stats are updated

    ; Reset SPC and put it into upload mode
    jsl sm_spc_reset

    ; Call credits
    jml credits_init
