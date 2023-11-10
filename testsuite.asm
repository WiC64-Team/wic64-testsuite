!addr zp1 = $24
!addr zp2 = $50

!addr random_byte = $d41b

red = $1c
green = $1e
yellow = $9e
ron = $12
roff = $92

* = $0801 ; 10 SYS 2064 ($0810)
!byte $0c, $08, $0a, $00, $9e, $20, $32, $30, $36, $34, $00, $00, $00

* = $0810
jmp setup

!src "wic64.h"
!src "wic64.asm"

!src "util.asm"

key_none  !byte %00000000, %11111111
key_one   !byte %01111111, %00000001
key_two   !byte %01111111, %00001000
key_three !byte %11111101, %00000001
key_four  !byte %11111101, %00001000
key_five  !byte %11111011, %00000001
key_six   !byte %11111011, %00001000
key_seven !byte %11110111, %00000001
key_stop  !byte %01111111, %10000000

setup !zone setup {
    sei

    ; stop all cia interrupts
    lda #$7f
    sta $dc0d
    sta $dd0d

    ; setup nmi
    lda #<nmi
    sta $0318
    lda #>nmi
    sta $0319

    ; init keyboard scanning
    lda #$ff
    sta $dc02
	lda #$00
    sta $dc03

    ; setup SID as simple random source
    lda #$ff  ; maximum frequency value
    sta $d40e ; voice 3 frequency low byte
    sta $d40f ; voice 3 frequency high byte
    lda #$80  ; noise waveform, gate bit off
    sta $d412 ; voice 3 control register

    cli
    jmp menu
}

nmi !zone nmi {
    +scan key_stop
    beq .menu

.quit
    +jmp_via_rti quit

.menu
   +jmp_via_rti menu
}

quit !zone quit {
    rts
}

menu !zone menu {
    ; black background and border
    lda #$00
    sta $d020
    sta $d021

    ; green text
    lda #green
    jsr chrout

    ; clear screen and home cursor
    jsr clrhome

    ; lower case
    lda #$0e
    jsr $ffd2

    ; print menu
    +print .menu_title
    +paragraph
    +print .menu_text

.scan:
    +scan key_none
    beq .scan

    +scan key_one
    beq +

    jsr test_echo
    jmp menu

+   +scan key_two
    beq +

    jsr test_wifi
    jmp menu

+   +scan key_three
    beq +

    jsr test_post
    jmp menu

+   +scan key_four
    beq +

    jsr test_extended
    jmp menu

+   +scan key_five
    beq +

    jsr test_version
    jmp menu

+   +scan key_six
    beq +

    jsr test_frequency
    jmp menu

+   jmp .scan

.menu_title
!pet "WiC64 Testsuite", $00

.menu_text
!pet ron, "1", roff, " Data Transfer", $0d
!pet ron, "2", roff, " Get WiFi Info", $0d
!pet ron, "3", roff, " Http POST request", $0d
!pet ron, "4", roff, " Large Http POST request", $0d
!pet ron, "5", roff, " Get firmware version", $0d
!pet ron, "6", roff, " High command frequency", $0d
!byte $00
}

!src "tests/echo.asm"
!src "tests/wifi.asm"
!src "tests/post.asm"
!src "tests/version.asm"
!src "tests/extended.asm"
!src "tests/frequency.asm"

verify_error_text
!pet red, "          => Verify error <=", green, $0d, $0d, $00

timeout_error_text
!pet red, "       => Transfer timed out <=", green, $0d, $0d, $00

error_prefix_text
!pet red, "Error: ", $00

restart_or_return_text
!pet green, "  -- Press ANY KEY to restart test --", $0d
!pet $0d
restore_text
!pet " -- Press RESTORE to return to menu --", $00

iterations !byte $00, $00, $00, $00

request
request_api  !text "R"
request_id   !byte $00
request_size !word $0000
request_data ; Up to 16kb of payload data

* = * + $4000

response ; at least 16kb free for response data