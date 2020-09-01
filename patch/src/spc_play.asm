org $F57E00
incbin "data/spc-header.bin"
org $F57F00
incbin "data/spc-dmaregs.bin"
org $F60000
incbin "data/spc-lo.bin"
org $F70000
incbin "data/spc-hi.bin"

!AUDIO_R0 = $2140
!AUDIO_R1 = $2141
!AUDIO_R2 = $2142
!AUDIO_R3 = $2143

!XY_8BIT = $10
!A_8BIT = $20

!waitforaudio = "- : cmp !AUDIO_R0 : bne -"
!spcfreeaddr = $FF80

; Set up labels for use in code
org $F57E25
audiopc:
org $F57E27
audioa:
org $F57E28
audiox:
org $F57E29
audioy:
org $F57E2A
audiopsw:
org $F57E2B
audiosp:
org $F60000
musicdata1:
org $F70000
musicdata2:
org $F57F00
dspdata:

org $F50000
playmusic:
    phx
    phy
    pha
    php
    phb

    ; Set bank to 80 for easier access to SMP registers
    pea $8080
    plb
    plb

    sep #$20
    rep #$10

    ; Send $00 to SMP to stop music
    ;lda #$00
    ;sta $002140

    ; Send $FF to SMP to enter upload mode
    ;lda #$FF
    ;sta $002140

    ; Clear $12-14 for use later
    rep #$30
    lda #$0000
    sta $12
    sta $14

    ; Call SM's own APU upload code with our "hacked" data to break out of
    ; SM's own SMP code, turn on IPL ROM and jump to it and wait for further uploads
    ;jsl $80800A
    ;dl sm_spc_data

    ; Call our own SPC loading code that uploads the new SPC data and executes it
    jsr loadspc

    plb
    plp
    pla
    ply
    plx

    rtl

loadspc:
    ; Turn off interrupts and NMI during SPC transfer
    lda #$0000
    sta $004200
    sei

    ; Copy $02-EF to SPC RAM
    ; sendmusicblock $E0 $C002 $0002 $00EE
    sep #!A_8BIT
    lda #$F6    ; 1
    sta $14
    rep #!A_8BIT
    lda #$0002  ; 2
    sta $12

    rep #!XY_8BIT
    ldx #$0002 ; 3
    ldy #$00EE ; 4
    jsr copyblocktospc

    ; sendmusicblock $F6 $0100 $0100 $7F00
    sep #!A_8BIT
    lda #$F6 ; 1
    sta $14
    rep #!A_8BIT
    lda #$0100 ; 2
    sta $12

    rep #!XY_8BIT
    ldx #$0100 ; 3
    ldy #$7F00 ; 4
    jsr copyblocktospc

    ; sendmusicblock $F7 $0000 $8000 $7FC0
    sep #!A_8BIT
    lda #$F7 ; 1
    sta $14
    rep #!A_8BIT
    lda #$0000 ; 2
    sta $12

    rep #!XY_8BIT
    ldx #$8000 ; 3
    ldy #$7FC0 ; 4
    jsr copyblocktospc

    ; Create SPC init code that sets up registers
    jsr makespcinitcode

    ; Copy init code to RAM
    ; sendmusicblock $7E $FF00 {spcfreeaddr} $003A
    sep #!A_8BIT
    lda #$7E ; 1
    sta $14
    rep #!A_8BIT
    lda #$FF00 ; 2
    sta $12

    rep #!XY_8BIT
    ldx #!spcfreeaddr ; 3
    ldy #$003A ; 4
    jsr copyblocktospc
    ; endmacro

    ; Initialize the DPS with values from the SPC
    jsr initdsp

    ; Start execution of init code, first $F0-FF init and then registers and finally
    ; jump to the SPC entry point
    rep #!XY_8BIT
    ldx #!spcfreeaddr
    jsr startspcexec

    ; Restore interrupts and NMI and exit
    ;cli
    ;sep #!A_8BIT
    ;lda #$80
    ;sta $004200
    rts

copyblocktospc:
    sep #!A_8BIT
    lda #$AA
    !waitforaudio

    stx !AUDIO_R2

    tyx

    lda #$01
    sta !AUDIO_R1
    lda #$CC
    sta !AUDIO_R0
    !waitforaudio

    ldy #$0000

.loop:
    xba
    lda [$12], y
    xba

    tya

    rep #!A_8BIT
    sta !AUDIO_R0
    sep #!A_8BIT

    !waitforaudio

    iny
    dex
    bne .loop

    ldx #$FFC9
    stx !AUDIO_R2

    xba
    lda #$00
    sta !AUDIO_R1
    xba

    clc
    adc #$02

    rep #!A_8BIT
    sta !AUDIO_R0
    sep #!A_8BIT

    !waitforaudio
    rts

startspcexec:
    sep #!A_8BIT
    lda #$AA
    !waitforaudio

    stx !AUDIO_R2

    lda #$00
    STA !AUDIO_R1
    lda #$CC
    STA !AUDIO_R0
    !waitforaudio
    rts

initdsp:
    rep #!XY_8BIT
    ldx #$0000
-
    cpx #$006C
    beq .skip
    cpx #$007D
    beq .skip
    cpx #$004C
    beq .skip
    cpx #$005C
    beq .skip

    sep #!A_8BIT
    txa
    sta $7EFF00
    lda.l dspdata,x

    sta $7EFF01
    phx

    ; sendmusicblock $7E $FF00 $00F2 $0002
    sep #!A_8BIT
    lda #$7E ; 1
    sta $14
    rep #!A_8BIT
    lda #$FF00 ; 2
    sta $12

    rep #!XY_8BIT
    ldx #$00F2 ; 3
    ldy #$0002 ; 4
    jsr copyblocktospc
    ; endmacro

    rep #!XY_8BIT
    plx

.skip:
    inx
    cpx #$0080
    bne -
    rts

makespcinitcode:
    sep #!A_8BIT

    lda $F60001
    pha

    lda $F60000
    pha

    lda #$8F
    sta $7EFF00
    pla
    sta $7EFF01
    lda #$00
    sta $7EFF02

    lda #$8F
    sta $7EFF03
    pla
    sta $7EFF04
    lda #$01
    sta $7EFF05

    lda #$CD
    sta $7EFF06
    lda.l audiosp
    sta $7EFF07
    lda #$BD
    sta $7EFF08

    lda #$CD
    sta $7EFF09
    lda.l audiopsw
    sta $7EFF0A
    lda #$4D
    sta $7EFF0B

    lda #$CD
    sta $7EFF0C
    lda.l audiox
    sta $7EFF0D

    lda #$8D
    sta $7EFF0E
    lda.l audioy
    sta $7EFF0F

    lda #$8F
    sta $7EFF10
    lda.l musicdata1+$FC
    sta $7EFF11
    lda #$FC
    sta $7EFF12

    lda #$8F
    sta $7EFF13
    lda.l musicdata1+$FB
    sta $7EFF14
    lda #$FB
    sta $7EFF15

    lda #$8F
    sta $7EFF16
    lda.l musicdata1+$FA
    sta $7EFF17
    lda #$FA
    sta $7EFF18

    lda #$8F
    sta $7EFF19
    lda.l musicdata1+$F1
    sta $7EFF1A
    lda #$F1
    sta $7EFF1B

    lda #$E4
    sta $7EFF1C
    lda #$FD
    sta $7EFF1D

    lda #$E4
    sta $7EFF1E
    lda #$FE
    sta $7EFF1F

    lda #$E4
    sta $7EFF20
    lda #$FF
    sta $7EFF21

    lda #$E8
    sta $7EFF22
    lda.l audioa
    sta $7EFF23

    lda #$8F
    sta $7EFF24
    lda #$7D
    sta $7EFF25
    lda #$F2
    sta $7EFF26

    lda #$8F
    sta $7EFF27
    lda.l dspdata+$7D
    sta $7EFF28
    lda #$F3
    sta $7EFF29

    lda #$8F
    sta $7EFF2A
    lda #$6C
    sta $7EFF2B
    lda #$F2
    sta $7EFF2C

    lda #$8F
    sta $7EFF2D
    lda.l dspdata+$6C
    sta $7EFF2E
    lda #$F3
    sta $7EFF2F

    lda #$8F
    sta $7EFF30
    lda #$4C
    sta $7EFF31
    lda #$F2
    sta $7EFF32

    lda #$8F
    sta $7EFF33
    lda.l dspdata+$4C
    sta $7EFF34
    lda #$F3
    sta $7EFF35

    lda #$8E
    sta $7EFF36

    lda #$5F
    sta $7EFF37
    rep #!A_8BIT
    lda.l audiopc
    sta $7EFF38
    sep #!A_8BIT
    xba
    sta $7EFF39

    rts

; Overwrite some code in the SM music engine that sets up the transfers
credits_sm_spc_data:
    dw $002A, $15A0
    db $8F, $6C, $F2
    db $8F, $E0, $F3 ; Disable echo buffer writes and mute amplifier
    db $8F, $7C, $F2
    db $8F, $FF, $F3 ; ENDX
    db $8F, $7D, $F2
    db $8F, $00, $F3 ; Disable echo delay
    db $8F, $4D, $F2
    db $8F, $00, $F3 ; EON
    db $8F, $5C, $F2
    db $8F, $FF, $F3 ; KOFF
    db $8F, $5C, $F2
    db $8F, $00, $F3 ; KOFF
    db $8F, $80, $F1 ; Enable IPL ROM
    db $5F, $C0, $FF ; jmp $FFC0
    dw $0000, $1500
