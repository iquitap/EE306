        .ORIG x3000

        ; Initialize stack pointer
        LD      R6,STACK

        ; Add keyboard interrupt vector to interrupt vector table
        LD      R0,KEY_INT
        STI     R0,TABLE

        ; Set interrupt enable (IE) bit in the Keyboard Status Register (KBSR)
        LDI     R0,KBSR
        LD      R1,IE_BIT
        NOT     R0,R0
        NOT     R1,R1
        AND     R0,R0,R1
        NOT     R0,R0           ; R0 = KBSR OR IE_BIT
        STI     R0,KBSR

        ; Spam the prompt message forever
LOOP    LEA     R0,MSG
        TRAP    x22
        LD      R0,LF
        TRAP    x21
        JSR     DELAY
        BRnzp   LOOP

; ===== DELAY SUBROUTINE =====
DELAY   ST      R1,SaveR1
        LD      R1,COUNT
REP     ADD     R1,R1,#-1
        BRnp    REP
        LD      R1, SaveR1
        RET
COUNT   .FILL #40000
SaveR1  .BLKW 1
; ===== END OF DELAY SUBROUTINE =====

STACK   .FILL x3000
TABLE   .FILL x0100
KEY_INT .FILL x0080
KBSR    .FILL xFE00
IE_BIT  .FILL x4000
MSG     .STRINGZ "Input a capital letter from the English alphabet:"
LF      .FILL x000A
        .END
