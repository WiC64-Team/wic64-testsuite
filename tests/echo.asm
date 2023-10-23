test_echo !zone test_echo {

.restart:
    jsr clrhome

    lda #$00
    sta $d020

    lda #$ff
    sta iterations
    sta iterations+1
    sta iterations+2

.next_iteration
    +inc24 iterations
    jsr .randomize
    jsr .echo
    bcs .timed_out

    jsr .verify
    bcc .next_iteration

    +print verify_error_text
    jmp .prompt

.timed_out
    +print timeout_error_text

.prompt
    +restart_or_return_prompt .restart

.randomize !zone randomize {
    ; calculate a random payload size up to 16kb
    lda #$00
    sta request_size
-   lda random_byte
    beq -
    cmp #$41
    bcs -
+   sta request_size+1

    ; fill input buffer with random bytes for size+1 pages
    +status .generating, status_echo

    +pointer zp1, request_data
    ldx request_size+1 ; num pages to fill

.next_page
    ldy #$00

.next_byte
    lda random_byte
    sta (zp1),y
    dey
    bne .next_byte
    inc zp1+1
    dex
    bne .next_page

    rts
.generating !pet "Generating", $00
}

.echo !zone echo {
    lda #$fe
    sta request_id

    lda #$02
    sta wic64_timeout

    +wic64_branch_on_timeout .timed_out

    +wic64_initialize

    +status .sending, status_echo
    +wic64_send_header request
    +wic64_send

    +status .receiving, status_echo
    +wic64_receive_header
    +wic64_receive response

    +wic64_finalize
    rts

.timed_out
    lda #$02
    sta $d020
    rts

.sending !pet "Sending   ", $00
.receiving !pet "Receiving ", $00
}

.verify !zone verify {
    +status .verifying, status_echo
    +pointer zp1, request_data
    +pointer zp2, response

    ldy #$00
    ldx #$00
.loop
    lda (zp1),y
    cmp (zp2),y
    bne .fail
    +inc16 zp1
    +inc16 zp2
    inx
    beq .next_page
    jmp .loop

.next_page
    dec request_size+1
    bne .loop

.success:
    clc
    rts

.fail:
    sec
    rts

.verifying !pet "Verifying ", $00
}

status_echo !zone status_echo {
    stx .task
    sty .task+1

    lda $0400
    cmp #$20
    bne +

    jsr home
    +print .text

+   +plot 0, 2
    +wait_raster $30
    +print_indirect .task

    +plot 12, 2
    +wait_raster $30
    lda request_size+1
    jsr hexprint

    +plot 1, 4
    +wait_raster $30
    lda iterations+2
    jsr hexprint

    +plot 3, 4
    +wait_raster $30
    lda iterations+1
    jsr hexprint

    +plot 5, 4
    +wait_raster $30
    lda iterations
    jsr hexprint

    +plot 0, 17
    rts

.text
!pet "WiC64 Test: Data Transfer (Echo $fe)", $0d
!pet $0d
!pet "           $  00 bytes of random data", $0d
!pet $0d
!pet "$       successful transfers", $0d
!pet $0d
!pet $0d
!pet "-- This test should run indefinitely --", $0d
!pet $0d
!pet $0d
!pet "If the ESP is reset, this test should", $0d
!pet "time out after approx. two seconds.", $0d
!pet $0d
!pet "If this test is aborted, the ESP should", $0d
!pet "time out after approx. one second.", $0d, $00
.task !16 $0000
}

} // !zone echo
