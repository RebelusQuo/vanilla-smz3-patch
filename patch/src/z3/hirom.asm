; Patch Zelda 3 SRAM Accesses

org $0087EB
    sta $A07FFE
    lda $A063E1

org $0087FB
    sta $A063E1
    lda $A068E1

org $00880B
    sta $A068E1
    lda $A06DE1

org $00881B
    sta $A06DE1

org $0CCCDD
    adc $A06000,x

org $0CCCF5
    adc $A06F00,x

org $0CCD5F
    sta $A06F00,x
    sta $A06000,x
    sta $A07000,x
    sta $A06100,x
    sta $A07100,x
    sta $A06200,x
    sta $A07200,x
    sta $A06300,x
    sta $A07300,x
    sta $A06400,x

org $0CCD0A
    sta $A06F00,x
    sta $A06000,x
    sta $A07000,x
    sta $A06100,x
    sta $A07100,x
    sta $A06200,x
    sta $A07200,x
    sta $A06300,x
    sta $A07300,x
    sta $A06400,x

org $0CCDFA
    lda $A063E1,x


org $1BEFA0
    lda $A06354
org $1BEFA6
    lda $A0635B
org $1BEFB0
    lda $A06359
org $1BEFBA
    lda $A0635A
org $1BEFC4
    lda $A06854
org $1BEFCA
    lda $A0685B
org $1BEFD4
    lda $A06859
org $1BEFDE
    lda $A0685A
org $1BEFE8
    lda $A06D54
org $1BEFEE
    lda $A06D5B
org $1BEFF8
    lda $A06D59
org $1BF002
    lda $A06D5A

org $0CD79B
    sta $A06000,x
    sta $A06100,x
    sta $A06200,x
    sta $A06300,x
    sta $A06400,x

org $0CD7BE
    sta $A063D9,x
    sta $A063DB,x
    sta $A063DD,x
    sta $A063DF,x

org $0CDB11
    sta $A063D9,x

org $0CDCA9
    lda $A063D9,x

org $0CDB25
    lda $A063D9,x

org $0CDB4C
    sta $A07FFE

org $0CDB5B
    sta $A063E1,x
org $0CDB62
    sta $A0620C,x
org $0CDB66
    sta $A0620E,x
org $0CDB6D
    sta $A06401,x

org $0CDB8A
    lda $A063D9

org $0CDB96
    sta $A06212,x
org $0CDB9D
    sta $A063C5,x
org $0CDBA4
    sta $A063C7,x

org $0CDBAE
    sta $A06340,x

org $0CDBC1
    adc $A06000,x

org $0CDBD7
    sta $A064FE,x

org $0CD5D9
    lda $A06359,x

org $0CD626
    lda $A0635A,x

org $0CD6C4
    lda $A06401,x

org $0CD52C
    lda $A063D9,x

org $0CD54C
    lda $A0636C,x

org $0CCE85
    sta $A07FFE

org $0CCED8
    lda $A06000,x

org $0CCEDF
    lda $A06100,x

org $0CCEE6
    lda $A06200,x

org $0CCEED
    lda $A06300,x

org $0CCEF4
    lda $A06400,x

org $0EEFEB
    lda $A07FFE

org $0EEFF5
    lda $A063D9,x

org $0EF011
    lda $A063DB,x

org $0EF02D
    lda $A063DD,x

org $0EF049
    lda $A063DF,x

org $00894B
    lda #$A0

org $008951
    ldx $7FFE

org $008961
    sta $6000,y
    sta $6F00,y

org $00896B
    sta $6100,y
    sta $7000,y

org $008975
    sta $6200,y
    sta $7100,y

org $00897F
    sta $6300,y
    sta $7200,y

org $008989
    sta $6400,y
    sta $7300,y

org $0089B6
    sta $A064FE,x
    sta $A073FE,x

org $0CD4D3
    sta.l $A06000,x
    sta.l $A06100,x
    sta.l $A06200,x
    sta.l $A06300,x
    sta.l $A06400,x
    sta.l $A06F00,x
    sta.l $A07000,x
    sta.l $A07100,x
    sta.l $A07200,x
    sta.l $A07300,x

org $0CD2D1
    lda.b #$A0

org $0CD2DC
    lda $6000,x
    sta $6000,y
    lda $6100,x
    sta $6100,y
    lda $6200,x
    sta $6200,y
    lda $6300,x
    sta $6300,y
    lda $6400,x
    sta $6400,y
