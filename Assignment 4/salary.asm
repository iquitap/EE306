        ; R0:
        ; R1:
        ; R2:
        ; R3: throwaway branch check
        ; R4:
        ; R5:
        ; R6: don't touch (stack pointer)
        ; R7: don't touch (return address)

        .ORIG x3000

        LD      R6,BASE

        ; Clear out the query storage
LOOP    LEA     R4,QUERY
        ADD     R4,R4,#10
        ADD     R4,R4,#10       ; R4 = address of QUERY + 20
        NOT     R4,R4
        ADD     R4,R4,#1        ; R4 = -(address of QUERY + 20)
        AND     R5,R5,#0        ; R5 = 0
        LEA     R2,QUERY        ; R2 = address of QUERY

CLEAN   STR     R5,R2,#0
        ADD     R2,R2,#1
        ADD     R3,R2,R4
        BRn     CLEAN

        ; Prompt the user for a professor's name and store the input
        LEA     R0,PROMPT
        LEA     R2,QUERY
        LD      R1,LINEF
        TRAP    x22             ; PUTS (display PROMPT)

INPUT   TRAP    x20             ; GETC
        TRAP    x21             ; OUT

        NOT     R0,R0
        ADD     R0,R0,#1        ; R0 = -R0

        ADD     R3,R0,R1
        BRz     CHECK           ; if inputted character is line feed, branch

        STR     R0,R2,#0        ; otherwise store the negative of the inputted character
        ADD     R2,R2,#1

        BRnzp   INPUT

        ; Halt if the user only inputted 'd'
CHECK   LEA     R2,QUERY
        LD      R4,d
        LDR     R3,R2,#0
        ADD     R3,R3,R4
        BRnp    NOQUIT

        AND     R4,R4,#0
        LDR     R3,R2,#1
        ADD     R3,R3,R4
        BRnp    NOQUIT

        HALT

        ; Search for the professor
NOQUIT  LDI     R1,ROOT         ; R1 contains address of root
        JSR     SEARCH
        ADD     R0,R0,#0
        BRn     NFOUND
        JSR     PRINT_NUM
        BRnzp   END

NFOUND  LEA     R0,NOPE
        TRAP    x22
        LD      R0,LINEF
        TRAP    x21

END     BRnzp   LOOP

; ===== SEARCH SUBROUTINE =====

SEARCH  LEA     R2,QUERY        ; R2 contains address of query
        LDR     R3,R1,#2        ; R3 contains address of professor's name

        ; Compare strings
CHECK1  LDR     R4,R2,#0        ; R4 contains query character
        BRnp    NONZ
        LDR     R5,R3,#0        ; R5 contains prof name character
        BRz     SALARY          ; if both R4 and R5 are 0, match found. go to SALARY
        BRnzp   NONZ1

NONZ    LDR     R5,R3,#0

NONZ1   ADD     R0,R4,R5
        BRnp    LEFT
        ADD     R2,R2,#1
        ADD     R3,R3,#1
        BRnzp   CHECK1

        ; Return the return value of whichever call was nonzero, or return -1
LEFT    LDR     R2,R1,#0        ; R2 contains left node address
        BRz     RIGHT

        ; Push R1
        ADD     R6,R6,#-1
        STR     R1,R6,#0

        ; Push R7
        ADD     R6,R6,#-1
        STR     R7,R6,#0

        ADD     R1,R2,#0        ; R1 = R2
        JSR     SEARCH

        ; Pop R7
        LDR     R7,R6,#0
        ADD     R6,R6,#1

        ; Pop R1
        LDR     R1,R6,#0
        ADD     R6,R6,#1

        ADD     R0,R0,#0
        BRn     #1              ; if left subtree found professor, return it
        RET

RIGHT   LDR     R3,R1,#1        ; R3 contains right node address
        BRz     ENDNODE

        ; Push R1
        ADD     R6,R6,#-1
        STR     R1,R6,#0

        ; Push R7
        ADD     R6,R6,#-1
        STR     R7,R6,#0

        ADD     R1,R3,#0        ; R1 = R3
        JSR     SEARCH

        ; Pop R7
        LDR     R7,R6,#0
        ADD     R6,R6,#1

        ; Pop R1
        LDR     R1,R6,#0
        ADD     R6,R6,#1

        RET

        ; Return the salary
SALARY  LDR     R0,R1,#3        ; R0 contains professor's salary
        RET

        ; Return -1 (professor not found in subtree)
ENDNODE AND     R0,R0,#0
        ADD     R0,R0,#-1
        RET

; ===== END OF SEARCH SUBROUTINE =====

; ===== NUM TO ASCII SUBROUTINE =====
; Subroutine that prints a positive 2's complement number on the display
; Input Register: R0 (positive 2's complement number)
; Output Registers: None
; Algorithm: The subroutine keeps dividing the input number by 10. It stores 
;            the remainder of each division in some sequential storage growing
;            backwards. When the quotient of the division hits zero, it prints
;            the stored digits in the reverse order and returns.
PRINT_NUM        ST   R0, PRINT_NUM_SAVER0
                 ST   R1, PRINT_NUM_SAVER1
                 ST   R6, PRINT_NUM_SAVER6
                 ST   R7, PRINT_NUM_SAVER7

                 LEA  R6, PRINT_NUM_LF ; initialize the local stack pointer
PRINT_NUM_AGAIN  JSR  DIV10            ; Extract next digit by dividing by 10
                 ADD  R6, R6, #-1
                 LD   R7, PRINT_NUM_HEX30
                 ADD  R0, R0, R7       ; Convert the single digit to ASCII
                 STR  R0, R6, #0       ; push the ASCII digit onto the stack
                 ADD  R1, R1, #0
                 BRz  PRINT_NUM_DONE   ; If the quotient is zero, we are ready to print
                 ADD  R0, R1, #0
                 BR   PRINT_NUM_AGAIN
PRINT_NUM_DONE   ADD  R0, R6, #0
                 TRAP x22              ; Print all the digits in the reverse order
                 LD   R0, PRINT_NUM_SAVER0
                 LD   R1, PRINT_NUM_SAVER1
                 LD   R6, PRINT_NUM_SAVER6
                 LD   R7, PRINT_NUM_SAVER7
                 RET

PRINT_NUM_STACK  .BLKW 5
PRINT_NUM_LF     .FILL x000A  
PRINT_NUM_NULL   .FILL x0000
PRINT_NUM_HEX30  .FILL x0030
PRINT_NUM_SAVER0 .BLKW 1
PRINT_NUM_SAVER1 .BLKW 1
PRINT_NUM_SAVER6 .BLKW 1
PRINT_NUM_SAVER7 .BLKW 1

; Subroutine for dividing a number by 10
; Input: R0 (the dividend)
; Outputs: R0 (the remainder), R1(the quotient)
DIV10            AND  R1, R1, #0
DIV10_AGAIN      ADD  R0, R0, #-10
                 BRn  DIV10_DONE
                 ADD  R1, R1, #1
                 BR   DIV10_AGAIN
DIV10_DONE       ADD  R0, R0, #10
                 RET

; ===== END OF NUM TO ASCII SUBROUTINE

NOPE    .STRINGZ "No Entry"
BASE    .FILL xFE00
ROOT    .FILL x4000
LINEF   .FILL x000A             ; line feed
d       .FILL x0064             ; d
PROMPT  .STRINGZ "Type a professor's name and then press Enter:"
QUERY   .BLKW 20                ; for storing the user's query of a professor's name
        .END
