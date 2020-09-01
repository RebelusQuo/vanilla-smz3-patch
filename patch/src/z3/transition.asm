; Transition into Zelda

; Place all the transition code in the top of the upper bank AA/EA (free space in SM)
org $EAF800     
base $AAF800


; exit id in !SRAM_ALTTP_EXIT
; darkworld flag in !SRAM_ALTTP_DARKWORLD
transition_to_zelda:
    sei                         ; Disable IRQ's
    
    %a8()
    %i16()

    phk
    plb                         ; Set data bank program bank

    lda #$00
    sta $004200                 ; Disable NMI and Joypad autoread
    sta $00420C                 ; Disable H-DMA

    lda #$8F
    sta $002100                 ; Enable PPU force blank

    jsl zelda_spc_reset         ; Kill the SM music engine and put the SPC in IPL upload mode
                                ; Gotta do this before switching RAM contents

-
    bit $4212                   ; Wait for a fresh NMI
    bmi -

-
    bit $4212
    bpl -

    ldx.w #zelda_vram>>16       ; Put Zelda VRAM bank in X
    jsl copy_to_vram            ; Call the DMA routine to copy Zelda template VRAM from ROM

    ldx.w #zelda_wram>>16       ; Put Zelda VRAM bank in X
    jsl copy_to_wram            ; Call the DMA routine to copy Zelda template VRAM from ROM
    
    %ai16()
    
    ldx #$01EC
    txs                         ; Adjust stack pointer

    lda #$0000                  ; Set the "game flag" to Zelda so IRQ's/NMI runs using the 
    sta !SRAM_CURRENT_GAME      ; correct game

    jsr zelda_copy_sram         ; Copy SRAM back to RAM
    jsl zelda_fix_checksum
    jsl zelda_copy_sm_items     ; Copy SM items to temp buffer
    jsr zelda_spc_load          ; Load Zelda's music engine
    jsr zelda_blank_cgram       ; Blank out CGRAM
    jsr zelda_restore_dmaregs   ; Restore ALTTP DMA regs
    
    ;jsl zelda_restore_randomizer_ram

    lda !SRAM_ALTTP_EXIT
    sta $A0                     ; Store links house as exit

    lda !SRAM_ALTTP_DARKWORLD
    sta $7EF3CA                 ; Store lightworld/darkworld flag (0x0040 = dark world)

    %a8()
    sta $7B
    sta $A063CA
    cmp.b #$40
    bne +
    lda #$01
    sta $7E0FFF
    lda #$0B
    sta $7E0AA4
    lda #$01
    sta $7E0AB3
    bra ++
+
    lda #$00
    sta $7E0FFF
    sta $7E0AB3
    lda #$01
    sta $7E0AA4
++

    %a8()

    lda $7EF35A
    asl #6
    sta $7EF416                 ; Set progressive shield flag

    lda !SRAM_ALTTP_EQUIPMENT_1
    sta $000202
    lda !SRAM_ALTTP_EQUIPMENT_2
    sta $000303


    php
    jsl $0DFA78                 ; Redraw HUD
    jsl $00FC41
    %ai8()
    jsl $09C499                 ; Load all overworld sprites
    plp

    ;jsl $1CF37A                ; Regenerate dialog pointers

    %ai8()
    jsl $00D308                 ; Update sword graphics
    jsl $00D348                 ; Update shield graphics

    lda #$FF
    sta $4201

    ;lda $13
    ;sta $2100

    lda $1C
    sta $212C
    lda $1D
    sta $212D
    lda $1E
    sta $212E
    lda $1F
    sta $212F
    lda $94
    sta $2105
    lda $95
    sta $2106
    lda $96
    sta $2123
    lda $97
    sta $2124
    lda $98
    sta $2125

    lda #$13
    sta $2107
    lda #$03
    sta $2108
    lda #$63
    sta $2109
    lda #$22
    sta $210B
    lda #$07
    sta $210C

    lda #$02
    sta $2101

    lda #$00
    sta $2102
    sta $2103

    lda #$81
    sta $4200                   ; Turn NMI/IRQ/Autojoypad read back on

    lda #$01
    sta $420D                   ; Toggle FastROM on (used for rando banks)


    %ai16()

    cli                         ; Enable interrupts and push processor status to the stack
    ;php   

    lda $4210                   ; Acknowledge any pending IRQ's
    
    pea $0707
    plb

    lda $A0
    sta $A2

    %ai8()

    lda $0114
    jsl $02A0BE
    jsl $02B81D
    lda #$08

    lda #$08
    sta $010C
    lda #$0F
    sta $10
    stz $11
    stz $B0


    %ai16()

    ldx #$0000                  ; Restore overworld area and coordinate data
-
    lda.l !SRAM_ALTTP_OVERWORLD_BUF,x
    sta.l $7EC140,x
    inx
    inx
    cpx #$0032
    bne -


    lda #$0000
    ldx #$00FF
    ldy #$0000

    %ai8()
    jml $02B6FB                 ; Jump directly to pre-overworld module

zelda_spc_reset:
    pha
    php
    %a8()
    
    lda #$FF                    ; Send N-SPC into "upload mode"
    sta $2140

    rep #$30
    lda #$0000
    sta $12
    sta $14

    jsl $80800A
    db alttp_spc_data, (alttp_spc_data>>8)+$80, alttp_spc_data>>16

    plp
    pla
    rtl

zelda_spc_load:
    pha
    php

    %a8()

    ldx #$0000
-
    lda $00,x
    sta !SRAM_ALTTP_SPC_BUF,x
    inx
    cpx #$0100
    bne -

    lda #$00                    
    sta $00                     
    lda #$80                    
    sta $01
    lda #$19
    sta $02

    jsl alttp_load_music        ; Call the alttp SPC upload routine

    ldx #$0000
-
    lda !SRAM_ALTTP_SPC_BUF,x
    sta $00,x
    inx
    cpx #$0100
    bne -


    plp
    pla
    rts

zelda_copy_sram:
    pha
    phx
    phy
    php
    phb

    rep #$20
    
    ;lda $C8
    ;asl a
    ;inc
    ;inc
    lda #$0000
    sta $A07FFE                 ; Always set save slot to 1 for now
    
    sep #$20
    %ai16()
    pea $7E7E
    plb
    plb
    ldy #$0000
    ldx #$0000
-
    LDA $A06000,X
    STA $F000,Y
    LDA $A06100,X
    STA $F100,Y
    LDA $A06200,X
    STA $F200,Y
    LDA $A06300,X
    STA $F300,Y
    LDA $A06400,X
    STA $F400,Y
    inx
    inx
    iny
    iny
    cpy #$0100
    bne -

    plb
    plp
    ply
    plx
    pla
    rts

zelda_blank_cgram:
    lda #$0000
    sta $2121
    ldx #$0000
-
    sta $2122
    inx
    cpx #$00FF
    bne -
    rts

zelda_fix_checksum:
    pha
    phx
    php
    %ai16()
    lda $00
    pha

    ldx #$0000                  ; Copy main SRAM to backup SRAM
-
    lda.l $A06000,x
    sta.l $A06F00,x
    inx : inx
    cpx #$04FE
    bne -

    ldx #$0000
    lda #$0000
-
    clc
    adc $A06000,x
    inx
    inx
    cpx #$04FE
    bne -

    sta $00
    lda #$5A5A
    sec
    sbc $00
    ;sta $7EF4FE
    sta $A064FE
    sta $A073FE
    pla
    plp
    plx
    pla
    rtl

zelda_restore_dmaregs:
    php
    %ai16()
    ldx #$0000                  ; Restore overworld area and coordinate data
-
    lda.l zelda_dmaregs,x
    sta.l $004300,x
    inx
    inx
    cpx #$0080
    bne -
    plp
    rts

zelda_copy_sm_items:        
    pha
    phx
    php
    %ai16()
    ldx #$0000
-
    lda.l !SRAM_SM_START,x        
    sta.l !SRAM_SM_ITEM_BUF,X   ; save to temporary buffer
    inx : inx
    cpx #$0040
    bne -

    plp
    plx
    pla
    rtl

zelda_save_sm_items:            ; Restores SM items to the real SRAM
    pha
    phx
    phy
    php

    %ai16()
    ldx #$0000
-
    lda.l !SRAM_SM_ITEM_BUF,X    
    sta.l !SRAM_SM_START,x       
    inx : inx
    cpx #$0040
    bne -

    jsl sm_fix_checksum         ; Update SM checksum so the savefile doesn't get deleted

    plp
    ply
    plx
    pla
    rtl

zelda_save_done_hook:
    jsl zelda_save_sm_items
    sep #$30
    plb
    rtl

;zelda_cgram:
;    incbin "../data/zelda-cgram.bin"

zelda_dmaregs:
    db $01, $18, $32, $AD, $7E, $4F, $01, $FF, $FF, $FF, $FF, $FF, $00, $00, $00, $FF
    db $01, $18, $80, $BB, $7E, $00, $00, $FF, $FF, $FF, $FF, $FF, $00, $00, $00, $FF
    db $01, $18, $C0, $BD, $7E, $00, $00, $FF, $FF, $FF, $FF, $FF, $00, $00, $00, $FF
    db $01, $18, $40, $B3, $7E, $00, $00, $FF, $FF, $FF, $FF, $FF, $00, $00, $00, $FF
    db $01, $18, $C0, $A5, $7E, $00, $00, $FF, $FF, $FF, $FF, $FF, $00, $00, $00, $FF
    db $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $00, $00, $00, $FF
    db $41, $26, $F6, $F2, $00, $FF, $FF, $00, $FF, $FF, $FF, $FF, $00, $00, $00, $FF
    db $41, $26, $F6, $F2, $00, $C2, $1C, $00, $FC, $F2, $8F, $FF, $00, $00, $00, $FF    

; Game state template data (banks E0-E7 = ALTTP, E8-EF = SM)
org $E00000
zelda_wram:
    incbin "../data/zelda-wram-lo-1.bin"
org $E10000
    incbin "../data/zelda-wram-lo-2.bin"
org $E20000
    incbin "../data/zelda-wram-hi-1.bin"
org $E30000
    incbin "../data/zelda-wram-hi-2.bin"

org $E40000
zelda_vram:
    incbin "../data/zelda-vram-1.bin"
org $E50000
    incbin "../data/zelda-vram-2.bin"
