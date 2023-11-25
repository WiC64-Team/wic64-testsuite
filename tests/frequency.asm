test_frequency !zone test_frequency {

.restart:
    jsr clrhome
    +print .text

    lda #WIC64_ECHO
    sta request_id
    lda #$01
    sta request_size
    lda #$00
    sta request_size+1
    lda #$55
    sta request_data

    lda #$02
    sta wic64_timeout

    lda #$00
    sta abort_with_delay

-   +wic64_execute request, response
    bcs .timed_out
    jmp -

.timed_out
    +print timeout_error_text

.prompt
    +restart_or_return_prompt .restart

.text
!pet "WiC64 Test: High command frequency ($fe)"
!pet $0d
!pet "Sends small echo requests as fast as", $0d
!pet "possible to test the firmwares ability", $0d
!pet "to serve commands at high frequencies", $0d
!pet $0d
!pet "-- This test should run indefinitely --", $0d
!pet $0d
!pet "The log should not report any unknown", $0d
!pet "protocol or command ids and no timeouts", $0d
!pet "should occur.", $0d
!pet $0d
!byte $00

} // !zone test_frequency
