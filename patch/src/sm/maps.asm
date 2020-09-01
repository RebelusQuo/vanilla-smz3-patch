org $C2C74D
base $82C74D
    ; first we set our pointers for map icons
    dw Crateria_names
    dw Brinstar_names
    dw Norfair_names
    dw WS_names
    dw Maridia_names
    dw Tourian_names

org $C2F740
base $82F740
; we're adding in 2 names for Crateria from vanilla, so we have to move this to free space
; format is XX coordinate, YY coordinate, icon
Crateria_names:
    dw $002C, $0070, $005A      ; Brinstar
    dw $00B8, $00B8, $005A      ; Brinstar
    dw $0110, $0068, $005A      ; Brinstar
    dw $0178, $0020, $005C      ; Wrecked Ship
    dw $01A0, $0080, $005D      ; Maridia
    dw $0080, $0078, $005E      ; Tourian
    dw $FFFF

org $C2C759
base $82C759
Brinstar_names:
    dw $0048, $0008, $0059      ; Crateria
    dw $00D0, $0040, $0059      ; Crateria
    dw $0128, $0020, $0059      ; Crateria
    dw $0140, $0090, $005D      ; Maridia
    dw $0148, $00C0, $005B      ; Norfair
    dw $FFFF

; we will be adding in both portal locations to Norfair eventually
Norfair_names:
    dw $0050, $0008, $005A      ; Brinstar
    dw $FFFF

WS_names:
    dw $0040, $0080, $0059      ; Crateria
    dw $00C0, $0080, $0059      ; Crateria
    dw $FFFF

Maridia_names:
    dw $0108, $0008, $0059      ; Crateria
    dw $0030, $00A0, $005A      ; Brinstar
    dw $0078, $00A0, $005A      ; Brinstar
    dw $FFFF

Tourian_names:
    dw $0098, $0048, $0059      ; Crateria
    dw $FFFF

; padbyte $FF : pad $82C7CB


; these two lines are just the graphics for the portal indicator

org $DAB3A0
base $9AB3A0
    db $00, $E0, $60, $95, $7C, $80, $7C, $80, $7C, $80, $7C, $80, $60, $95, $00, $E0

org $F68340
base $B68340
    db $00, $E0, $60, $95, $7C, $80, $7C, $80, $7C, $80, $7C, $80, $60, $95, $00, $E0
    db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00

org $F58000
base $B58000

incbin "data/maps.bin" ; add in all of our necessary map changes
