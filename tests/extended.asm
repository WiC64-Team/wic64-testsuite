test_extended !zone test_extended {

.restart
    jsr clrhome

    lda #$00
    sta $d020

    lda #$ff
    sta iterations
    sta iterations+1
    sta iterations+2

.repeat
    +inc24 iterations

    lda #$00
    sta blocks_sent
    sta blocks_sent+1
    sta blocks_received
    sta blocks_received+1

    +status .sending, status_extended

    +wic64_execute post_url_request, response
    bcc +
    jmp .timeout

+   beq +
    jmp .error

+   lda #$00
    sta direction

    +wic64_set_timeout $04
    +wic64_branch_on_timeout .timeout

    +wic64_initialize
    +wic64_send_header extended_post_request

    lda #$08
    sta .blocks

-   +wic64_send send_buffer, buffer_size

    +inc16 blocks_sent
    +status .sending, status_extended

    dec .blocks
    bne -

    lda #$01
    sta direction

    +status .receiving, status_extended

    +wic64_receive_header
    bne .error

    lda #$08
    sta .blocks

-   +wic64_receive receive_buffer, buffer_size

    +inc16 blocks_received
    +status .receiving, status_extended

    dec .blocks
    bne -

    +wic64_finalize

    jmp .repeat

.timeout
    +print timeout_error_text
    jmp .prompt

.error
    +wic64_execute status_request, response
    bcs .timeout

    +print error_prefix_text
    +print response
    +paragraph

.prompt
    +restart_or_return_prompt .restart

.sending    !pet "Sending  ", $00
.receiving  !pet "Receiving", $00

.blocks !byte $00

status_extended !zone status_extended {
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

    +plot 10, 2
    +wait_raster $30

    lda direction
    bne +
    lda blocks_sent
    jmp ++
+   lda blocks_received

++  asl
    asl
    asl
    asl
    bcc +
    ora #$80

+   tax
    +wait_raster $30
    txa
    jsr print_dec

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

.kb !byte $00

.text
!pet "WiC64 Test: HTTP POST 128kb ($28, $2B)", $0d
!pet $0d
!pet "          nnn/128kb", $0d
!pet $0d
!pet "$       successful post requests", $0d
!pet $0d
!pet $0d
!pet "-- This test should run indefinitely --", $0d
!pet $0d
!pet $0d
!pet "If the ESP is reset, this test should", $0d
!pet "time out after approx. four seconds.", $0d
!pet $0d
!pet "If this test is aborted, the ESP should", $0d
!pet "time out after approx. one second.", $0d
!pet $00
.task !16 $0000
}

buffer_size = $4000
send_buffer = response
receive_buffer = response

blocks_sent: !word $0000
blocks_received: !word $0000
direction: !byte $00

} ; end of !zone test_extended

extended_post_request: !byte "E", $2b
extended_post_request_size: !byte $00, $00, $02, $00 ; $20000 = 128kb


