test_wifi !zone test_wifi {

.restart
    jsr clrhome
    +print .text

    +print .text_ssid
    lda #$10
    sta request_id

    jsr get_info
    bcc +
    jmp .timeout

+   +print_ascii response
    +newline

    +print .text_rssi
    lda #$11
    sta request_id

    jsr get_info
    bcc +
    jmp .timeout

+   +print_ascii response
    +newline

    +print .text_ip
    lda #$06
    sta request_id

    jsr get_info
    bcc +
    jmp .timeout

+   +print response
    +newline

    +print .text_mac
    lda #$14
    sta request_id

    jsr get_info
    bcc +
    jmp .timeout

+   +print response
    +newline

    +paragraph
    jmp .prompt

.timeout
    +newline
    +paragraph
    +print timeout_error_text

.prompt
    +restart_or_return_prompt .restart

.text
!pet "WiC64 Test: WiFi Info ($10,$11,$06,$14)", $0d
!pet $0d, $00
.text_ssid
!pet "SSID: ", $00
.text_rssi
!pet "RSSI: ", $00
.text_ip
!pet "ADDR: ", $00
.text_mac
!pet "MAC : ", $00

get_info !zone wifi_info {
    lda #$00
    sta request_size
    sta request_size+1

    +wic64_execute request, response
    rts
}

} // !zone test_wifi_info