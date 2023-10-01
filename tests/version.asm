test_version !zone test_version {

.restart
    jsr clrhome
    +print .text

    +print .text_string

    lda #$00
    sta request_size
    sta request_size+1

    lda #$00
    sta request_id

    jsr .get_version
    bcc +
    jmp .timeout

+   +print_ascii response
    +paragraph

    lda #$26
    sta request_id

    jsr .get_version
    bcc +
    jmp .timeout

+   +print .text_major
    lda response
    jsr hexprint
    +newline

    +print .text_minor
    lda response+1
    jsr hexprint
    +newline

    +print .text_patch
    lda response+2
    jsr hexprint
    +newline

    +print .text_devel
    lda response+3
    jsr hexprint
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
!pet "WiC64 Test: Version ($00, $26)", $0d
!pet $0d
!pet $00

.text_string
!pet "String: ", $00

.text_major
!pet "Major: $", $00

.text_minor
!pet "Minor: $", $00

.text_patch
!pet "Patch: $", $00

.text_devel
!pet "Devel: $", $00

.get_version:
    +wic64_execute request, response
    rts

} // !zone test_version