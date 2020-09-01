; This skips the intro
org $C2EEDA
    db $1F

; Hijack init routine to autosave and set door flags
org $C28067
    jsl introskip_doorflags

org $C0FD00
base $80FD00
introskip_doorflags:
    ; Do some checks to see that we're actually starting a new game

    ; Make sure game mode is 1F
    lda $7E0998
    cmp.w #$001F
    beq +
    jmp .ret
+

    ; Check if samus saved energy is 00, if it is, run startup code
    lda $7ED7E2
    beq +
    jmp .ret

+
    ; Set construction zone and red tower elevator doors to blue
    ;lda $7ED8B6
    ;ora.w #$0004
    ;sta $7ED8B6
    ;lda $7ED8B2
    ;ora.w #$0001
    ;sta $7ED8B2

    ; Unlock crateria map station door
    lda $7ED8B0
    ora.w #$0020
    sta $7ED8B0

    ; Unlock norfair map station door
    lda $7ED8B8
    ora.w #$1000
    sta $7ED8B8

    ; Set up open mode event bit flags
    ;lda #$0001
    ;sta $7ED820

    lda #$0000
    sta.l !SRAM_SM_COMPLETED
    sta.l !SRAM_ALTTP_EQUIPMENT_1
    sta.l !SRAM_ALTTP_EQUIPMENT_2
    sta.l !SRAM_ALTTP_COMPLETED
    sta.l !SRAM_ALTTP_RANDOMIZER_SAVED
    sta.l !door_timer_tmp
    sta.l !door_adjust_tmp
    sta.l !add_time_tmp
    sta.l !region_timer_tmp
    sta.l !region_tmp
    sta.l !transition_tmp

    jsl stats_clear_values      ; Clear SM stats
    jsl alttp_new_game          ; Setup new game for ALTTP
    ;jsl sm_copy_alttp_items    ; Copy alttp items into temporary SRAM buffer
    ;jsl zelda_fix_checksum     ; Fix alttp checksum

    ; begin Leno edits here!
    LDA #$FFFF                  ; decrement the accumulator by 1, making it #$FFFF
    sta.l $7ED908               ; activate Crateria and Brinstar maps
    ; sta.l $7ED909
    sta.l $7ED90A               ; activate Norfair and Wrecked Ship maps
    ; sta.l $7ED90B
    sta.l $7ED90C               ; activate Maridia and Tourian maps
    ; sta.l $7ED90D
    ; sta.l $7ED90E             ; Ceres and debug maps
    ; sta.l $7ED90F

    %a8()
    lda.b #$01
    sta $0789                   ; this is used for the minimap, so blue tiles can show up on it. this also lets the main map scroll
    %a16()

    ; Call the save code to create a new file
    lda $7E0952
    jsl $818000

    ; Reboot into alttp
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

    %ai8()
    lda #$00
    sta !SRAM_CURRENT_GAME
    sta !SRAM_CURRENT_GAME+1
    pha : plb
    jml $008000

.ret:
    lda #$0000
    rtl
