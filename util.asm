!zone util {

!addr chrout = $ffd2

!macro pointer .pointer, .address {
    ldx #<.address
    stx .pointer
    ldx #>.address
    stx .pointer+1
}

!macro inc16 .addr {
    inc .addr
    bne .done
    inc .addr+1
.done
}

!macro inc24 .addr {
    inc .addr
    bne .done
    inc .addr+1
    bne .done
    inc .addr+2
.done
}

!macro decw .addr {
    dec .addr
    cmp #$ff
    bne .done
    dec .addr+1
.done
}

!macro jmp_via_rti .addr {
    ldx #$ff
    txs
    lda #>.addr
    pha
    lda #<.addr
    pha
    lda #$00
    pha
    rti
}

!macro status .addr, .routine {
    ldx #<.addr
    ldy #>.addr
    jsr .routine
}

!macro scan .k {
    sei
    lda .k
	sta $dc00
	lda $dc01
	and .k+1
	cmp .k+1
    cli
}

!macro random_byte .floor, .ceiling {
-   lda random_byte
    cmp #.ceiling
    bcs -
    beq -
    cmp #.floor
    bcc -
}

home !zone home {
    lda #$13
    jsr chrout
    rts
}

clrhome !zone clrhome {
    lda #$93
    jsr chrout
    rts
}

!macro plot .x, .y {
    ldy #.x
    ldx #.y
    clc
    jsr $fff0
}

!macro wait_raster .line {
-   lda $d012
    cmp #.line
    bne -
}

!macro print .addr {
    ldx #<.addr
    ldy #>.addr
    jsr print
}

!macro print_ascii .addr {
    ldx #<.addr
    ldy #>.addr
    jsr print_ascii
}

!macro print_indirect .ptr {
    ldx .ptr
    ldy .ptr+1
    jsr print
}

print !zone print {
    stx zp2
    sty zp2+1
    ldy #$00

.loop
    lda (zp2),y
    beq .done
    jsr chrout
    inc zp2
    bne .loop
    inc zp2+1
    jmp .loop

.done
    rts
}

print_ascii !zone print_ascii {
    stx zp2
    sty zp2+1
    ldy #$00

.loop
    lda (zp2),y
    beq .done
    tax
    lda ascii2petscii,x
    jsr chrout
    inc zp2
    bne .loop
    inc zp2+1
    jmp .loop

.done
    rts
}

!macro newline {
    lda #$0d
    jsr chrout
}

!macro paragraph {
    lda #$0d
    jsr chrout
    jsr chrout
}

!macro restart_or_return_prompt .restart_addr {
    +print restart_or_return_text

.scan_any_key
    +scan key_none
    beq .scan_any_key

.except_runstop
    +scan key_stop
    bne .scan_any_key

    jmp .restart_addr
}

hexprint !zone hexprint {
    sta .value

    lda zp2
    sta .zp2
    lda zp2+1
    sta .zp2+1

    txa
    pha
    tya
    pha

    lda .value
    ldx #<.digits
    stx zp2
    ldx #>.digits
    stx zp2+1
    lsr
    lsr
    lsr
    lsr
    tay
    lda (zp2),Y
    jsr chrout

    lda .value

    and #$0f
    tay
    lda (zp2),Y
    jsr chrout

    pla
    tay
    pla
    tax

    lda .zp2
    sta zp2
    lda .zp2+1
    sta zp2+1

    lda .value
    rts

.value !byte $00
.zp2 !word $0000
.digits
    !text "0123456789ABCDEF"
}

print_dec !zone print_dec {
    cmp #$00
    bne .not_zero

    lda #' '
    jsr $ffd2
    jsr $ffd2
    lda #'0'
    jsr $ffd2
    rts

.not_zero:
   sta .value
   ldy #$01
   sta .nonzero_digit_printed

.hundreds:
    ldx #$00
-   sec
    sbc #100
    bcc .print_hundreds
    sta .value
    inx
    jmp -

.print_hundreds:
    jsr .print_digit_in_x

.tens:
    lda .value
    ldx #$00
-   sec
    sbc #10
    bcc .print_tens
    sta .value
    inx
    jmp -

.print_tens:
    jsr .print_digit_in_x

.print_ones:
    lda .value
    tax
    jsr .print_digit_in_x

    rts

.print_digit_in_x:
    cpx #$00
    bne +

    lda .nonzero_digit_printed
    beq +

    lda #' '
    jsr $ffd2

    rts

+   lda .digits,x
    jsr $ffd2

    lda #$00
    sta .nonzero_digit_printed
    rts

.value: !byte $00
.nonzero_digit_printed: !byte $01
.digits: !pet "0123456789"
}

delay: !zone delay {
    sta .z
--- ldy #$00
--  ldx #$00
-   dex
    bne -
    dey
    bne --
    dec .z
    bne ---
    rts

.z: !byte $00
}

ascii2petscii:
!for i, 0, 255 { !byte i }

* = ascii2petscii+65, overlay
!for i, 1, 26 {!byte *-ascii2petscii + 128}

* = ascii2petscii+97, overlay
!for i, 1, 26 {!byte *-ascii2petscii - 32}

}