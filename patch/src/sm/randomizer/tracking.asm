; RTA Timer (timer 1 is frames, and timer 2 is number of times frames rolled over)
!timer1 = $05B8
!timer2 = $05BA

; Temp variables (define here to make sure they're not reused, make sure they're 2 bytes apart)
; These variables are cleared to 0x00 on hard and soft reset
!door_timer_tmp = $7FFF00
!door_adjust_tmp = $7FFF02
!add_time_tmp = $7FFF04
!region_timer_tmp = $7FFF06
!region_tmp = $7FFF08
!transition_tmp = $7FFF10
!ALTTP_NMI_COUNTER = $7EF43E

; -------------------------------
; HIJACKS
; -------------------------------

; Samus hit a door block (Gamestate change to $09 just before hitting $0A)
org $C2E176
    jml door_entered

; Samus gains control back after door (Gamestate change back to $08 after door transition)
org $C2E764
    jml door_exited

; Door starts adjusting
org $C2E309
    jml door_adjust_start

; Door stops adjusting
org $C2E34C
    jml door_adjust_stop

; Firing charged beam
org $D0B9A1
    jml charged_beam

; Firing SBAs
org $D0CCD2
    jml fire_sba

; Missiles/supers fired
org $D0BEB7
    jml missiles_fired

; PBs laid
org $D0C02D
    jml pbs_laid

; Bombs laid
org $D0C107
    jml bombs_laid

org $E2AB13
    jsl game_end

org $C58089
    jsl item_collected


;Patch NMI to skip resetting 05BA and instead use that as an extra time counter
org $C095E5
base $8095E5
sm_patch_nmi:
    ldx #$00
    stx $05B4
    ldx $05B5
    inx
    stx $05B5
    inc $05B6
.inc:
    rep #$30
    inc $05B8
    bne +
    inc $05BA
+
    bra .end

org $C09602
base $809602
    bra .inc
.end:
    ply
    plx
    pla
    pld
    plb
    rti

; -------------------------------
; CODE (using bank A1 free space)
; -------------------------------
org $E1EC00
base $A1EC00
get_total_frame_time:
    pha : phx : php
    %ai16()
    lda !SRAM_CURRENT_GAME
    beq .alttp

    lda !timer1
    clc
    adc $A0643E
    sta !SRAM_TIMER1
    lda !timer2
    adc $A06440
    sta !SRAM_TIMER2
    jmp .end

.alttp
    lda !ALTTP_NMI_COUNTER
    clc
    adc !SRAM_SM_STATS
    sta !SRAM_TIMER1
    lda !ALTTP_NMI_COUNTER+2
    adc !SRAM_SM_STATS+2
    sta !SRAM_TIMER2

.end
    plp : plx : pla
    rtl

; stats:
;     ; STAT ID, ADDRESS,    TYPE (1 = Number, 2 = Time, 3 = Full time), UNUSED
;     dw $00,       0,  3, 0          ; Full RTA Time
;     dw $02,       0,  1, 0          ; Door transitions
;     dw $03,       0,  3, 0          ; Time in doors
;     dw $05,       0,  2, 0          ; Time adjusting doors
;     dw $07,       0,  3, 0          ; Crateria
;     dw $09,       0,  3, 0          ; Brinstar
;     dw $0B,       0,  3, 0          ; Norfair
;     dw $0D,       0,  3, 0          ; Wrecked Ship
;     dw $0F,       0,  3, 0          ; Maridia
;     dw $11,       0,  3, 0          ; Tourian
;     dw $14,       0,  1, 0          ; Charged Shots
;     dw $15,       0,  1, 0          ; Special Beam Attacks
;     dw $16,       0,  1, 0          ; Missiles
;     dw $17,       0,  1, 0          ; Super Missiles
;     dw $18,       0,  1, 0          ; Power Bombs
;     dw $1A,       0,  1, 0          ; Bombs
;     dw $1B,       0,  1, 0          ; Transitions to SM
;     dw $1C,       0,  1, 0          ; Transitions to ALTTP
;     dw $1D,       0,  1, 0          ; Collected items
;     dw 0,         0,  0, 0          ; end of table

; Helper function to add a time delta, X = stat to add to, A = value to check against
; This uses 4-bytes for each time delta
add_time:
    sta !add_time_tmp
    lda !timer1
    sec
    sbc !add_time_tmp
    sta !add_time_tmp
    txa
    jsl load_stat
    clc
    adc !add_time_tmp
    bcc +
    jsl store_stat    ; If carry set, increase the high bits
    inx
    txa
    jsl inc_stat
+
    jsl store_stat
    rts


; Samus hit a door block (Gamestate change to $09 just before hitting $0A)
door_entered:
    lda #$0002  ; Number of door transitions
    jsl inc_stat

    lda !timer1
    sta !door_timer_tmp     ; Save RTA time to temp variable

    ; Run hijacked code and return
    plp
    inc $0998
    jml $82E1B7

; Samus gains control back after door (Gamestate change back to $08 after door transition)
door_exited:
    ; Check for transition from ALTTP
    lda !transition_tmp
    bne +

    ; Increment saved value with time spent in door transition
    lda !door_timer_tmp
    ldx #$0003
    jsr add_time

    ; Store time spent in last room/area unless region_tmp is 0
    lda !region_tmp
    beq +
    tax
    lda !region_timer_tmp
    jsr add_time


   ; Store the current frame and the current region to temp variables
+
    lda #$0000
    sta !transition_tmp

    lda !timer1
    sta !region_timer_tmp
    lda $7E079F
    asl
    clc
    adc #$0007
    sta !region_tmp         ; Store (region*2) + 7 to region_tmp (This uses stat id 7-18 for region timers)

    ; Run hijacked code and return
    lda #$0008
    sta $0998
    jml $82E76A

; Door adjust start
door_adjust_start:
    lda !timer1
    sta !door_adjust_tmp    ; Save RTA time to temp variable

    ; Run hijacked code and return
    lda #$E310
    sta $099C
    jml $82E30F

; Door adjust stop
door_adjust_stop:
    lda !door_adjust_tmp
    inc ; Add extra frame to time delta so that perfect doors counts as 0
    ldx #$0005
    jsr add_time

    ; Run hijacked code and return
    lda #$E353
    sta $099C
    jml $82E352

; Charged Beam Fire
charged_beam:
    lda #$0014
    jsl inc_stat

    ; Run hijacked code and return
    LDX #$0000
    LDA $0C2C, x
    JML $90B9A7

; Firing SBAs
fire_sba:
    lda.l $90CC21, x
    beq .nosba              ; If the table lookup for the PB amount to remove is just 0, then exit right away

    lda #$0015              ; SBA happening, increment stat
    jsl inc_stat

    dec $09CE               ; Cheat and don't use the table for the amount of PB's to remove
    bpl +                   ; since it'll always cost one
    stz $09CE               ; Handle underflow if it somehow can happen
+
    jml $90CCE1             ; Jump to SBA triggering code

.nosba
    jml $90CCEF             ; Jump to RTS (don't trigger SBA)

; MissilesSupers used
missiles_fired:
    lda $09D2
    cmp #$0002
    beq .super
    dec $09C6
    lda #$0016
    jsl inc_stat
    bra .end
.super:
    dec $09CA
    lda #$0017
    jsl inc_stat
.end:
    jml $90BEC7

; PBs laid
pbs_laid:
    dec
    sta $09CE
    lda #$0018
    jsl inc_stat
    jml $90C031

; Bombs laid
bombs_laid:
    lda $09D2               ; Check HUD selection index for PB selected
    cmp #$0003
    beq .powerbomb
    lda #$001A
    bra .end
.powerbomb
    lda #$0018
.end
    jsl inc_stat

    ;run hijacked code and return
    lda $0CD2
    inc
    jml $90C10B

item_collected:
    pha
    lda $1C1F
    cmp #$0014
    beq .noitem
    cmp #$0015
    beq .noitem
    cmp #$0016
    beq .noitem
    cmp #$0017
    beq .noitem
    cmp #$0018
    beq .noitem
    cmp #$001C
    beq .noitem

    lda #$001D
    jsl inc_stat

.noitem
    pla
    rtl


; Increment Statistic (in A)
inc_stat:
    phx
    asl
    tax
    lda $7FFC00, x
    inc
    sta $7FFC00, x
    plx
    rtl

; Decrement Statistic (in A)
dec_stat:
    phx
    asl
    tax
    lda $7FFC00, x
    dec
    sta $7FFC00, x
    plx
    rtl


; Store Statistic (value in A, stat in X)
store_stat:
    phx
    pha
    txa
    asl
    tax
    pla
    sta $7FFC00, x
    plx
    rtl

; Load Statistic (stat in A, returns value in A)
load_stat:
    phx
    asl
    tax
    lda $7FFC00, x
    plx
    rtl

load_stats:
    phx
    pha
    ldx #$0000
    lda $7E0952
    bne +
-
    lda !SRAM_SM_STATS, x
    sta $7FFC00, x
    inx
    inx
    cpx #$0040
    bne -
    jmp .end
+
    cmp #$0001
    bne +
    lda !SRAM_SM_STATS+$40, x
    sta $7FFC00, x
    inx
    inx
    cpx #$0040
    bne -
    jmp .end
+
    lda !SRAM_SM_STATS+$80, x
    sta $7FFC00, x
    inx
    inx
    cpx #$0040
    bne -
    jmp .end

.end:
    pla
    plx
    rtl

save_stats:
    phx
    pha
    ldx #$0000
    lda $7E0952
    bne +
-
    lda $7FFC00, x
    sta !SRAM_SM_STATS, x
    inx
    inx
    cpx #$0040
    bne -
    jmp .end
+
    cmp #$0001
    bne +
    lda $7FFC00, x
    sta !SRAM_SM_STATS+$40, x
    inx
    inx
    cpx #$0040
    bne -
    jmp .end
+
    lda $7FFC00, x
    sta !SRAM_SM_STATS+$80, x
    inx
    inx
    cpx #$0040
    bne -
    jmp .end

.end:
    pla
    plx
    rtl

stats_load_sram:
    pha : phx : phy : php
    jsl load_stats
    lda $7FFC00
    sta !timer1
    lda $7FFC02
    sta !timer2
    plp : ply : plx : pla
    rtl

stats_save_sram:
    pha : phx : phy : php
    lda !timer1
    sta $7FFC00
    lda !timer2
    sta $7FFC02
    jsl save_stats
    plp : ply : plx : pla
    rtl

stats_clear_values:
    pha : phx : phy : php
    rep #$30

    ldx #$0000
    lda #$0000
-
    jsl store_stat
    inx
    cpx #$0180
    bne -

    ; Clear RTA Timer
    lda #$0000
    sta !timer1
    sta !timer2

.ret:
    plp : ply : plx : pla
    rtl

game_end:
    lda !timer1
    sta $7FFC00
    lda !timer2
    sta $7FFC02

    ; Subtract frames from pressing down at ship to this code running
    lda $7FFC00
    sec
    sbc #$013D
    sta $7FFC00
    lda #$0000  ; if carry clear this will subtract one from the high byte of timer
    sbc $7FFC02

    jsl save_stats
    lda #$000A
    jsl $90F084
    rtl

warnpc $E1FFFF
