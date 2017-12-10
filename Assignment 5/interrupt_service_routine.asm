        ; R0: user-inputted character
        ; R1: testing values for branch
        ; R2: address of current character in string being printed
        ; R3: current character in string being printed

        .ORIG x1500

        ST      R0,SAVER0
        ST      R1,SAVER1
        ST      R2,SAVER2
        ST      R3,SAVER3

        ; Print linefeed
        LD      R3,LF
        LDI     R1,DSR
        BRzp    #-1
        STI     R3,DDR

        ; Get inputted character
        LDI     R0,KBDR

        ; Check if it's a capital letter
        LD      R1,A
        ADD     R1,R0,R1
        BRn     ERR

        LD      R1,Z
        ADD     R1,R0,R1
        BRp     ERR

; ===== INPUTTED CHARACTER IS A CAPITAL LETTER =====

        ; Print the beginning of success message
        LEA     R2,LOWER
LOOP    LDR     R3,R2,#0
        BRz     CONT
        LDI     R1,DSR
        BRzp    #-1
        STI     R3,DDR
        ADD     R2,R2,#1
        BRnzp   LOOP

        ; Print the inputted character
CONT    LDI     R1,DSR
        BRzp    CONT
        STI     R0,DDR

        ; Print " is "
        LEA     R2,IS
LOOP1   LDR     R3,R2,#0
        BRz     CONT1
        LDI     R1,DSR
        BRzp    #-1
        STI     R3,DDR
        ADD     R2,R2,#1
        BRnzp   LOOP1

        ; Print lowercase version of the letter
CONT1   LD      R1,OFFSET
        ADD     R0,R0,R1
        LDI     R1,DSR
        BRzp    #-1
        STI     R0,DDR

        ; Print period
        LD      R3,PERIOD
        LDI     R1,DSR
        BRzp    #-1
        STI     R3,DDR

        ; Print linefeed
        LD      R3,LF
        LDI     R1,DSR
        BRzp    #-1
        STI     R3,DDR

        BRnzp   EXIT

; ===== INPUTTED CHARACTER IS NOT A CAPITAL LETTER =====

        ; Print inputted character
ERR     LDI     R1,DSR
        BRzp    ERR
        STI     R0,DDR

        ; Print the rest of the error message
        LEA     R2,ERR_MSG
LOOP2   LDR     R0,R2,#0
        BRz     CONT2
        LDI     R1,DSR
        BRzp    #-1
        STI     R0,DDR
        ADD     R2,R2,#1
        BRnzp   LOOP2

        ; Print linefeed
CONT2   LD      R3,LF
        LDI     R1,DSR
        BRzp    #-1
        STI     R3,DDR

; ===== EXIT =====

EXIT    LD      R0,SAVER0
        LD      R1,SAVER1
        LD      R2,SAVER2
        LD      R3,SAVER3
        RTI



SAVER0  .BLKW 1
SAVER1  .BLKW 1
SAVER2  .BLKW 1
SAVER3  .BLKW 1

A       .FILL xFFBF
Z       .FILL xFFA6

OFFSET  .FILL x0020

KBDR    .FILL xFE02
DSR     .FILL xFE04
DDR     .FILL xFE06

LOWER   .STRINGZ "The lower case character of "
IS      .STRINGZ " is "
PERIOD  .FILL x002E

LF      .FILL x000A

ERR_MSG .STRINGZ " is not a capital letter in the English alphabet."
        .END
