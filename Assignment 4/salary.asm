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
        LEA     R0,CELERY
        TRAP    x22
        BRnzp   #2

NFOUND  LEA     R0,NOPE
        TRAP    x22

        BRnzp   LOOP

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
        BRnp    CONT
        ADD     R2,R2,#1
        ADD     R3,R3,#1
        BRnzp   CHECK1

        ; Return the return value of whichever call was nonzero, or return -1
CONT    LDR     R2,R1,#0        ; R2 contains left node address
        LDR     R3,R1,#1        ; R3 contains right node address

        ADD     R1,R2,#0        ; R1 = R2
        BRz     #5

        ; Push R7
        ADD     R6,R6,#-1
        STR     R7,R6,#0

        JSR     SEARCH

        ; Pop R7
        LDR     R7,R6,#0
        ADD     R6,R6,#1

        ADD     R0,R0,#0
        BRn     #1
        RET
        ADD     R1,R3,#0        ; R1 = R3
        BRz     ENDNODE

        ; Push R7
        ADD     R6,R6,#-1
        STR     R7,R6,#0

        JSR     SEARCH

        ; Pop R7
        LDR     R7,R6,#0
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

CELERY  .STRINGZ "salary here"
NOPE    .STRINGZ "not found"
BASE    .FILL xFE00
ROOT    .FILL x4000
LINEF   .FILL x000A             ; line feed
d       .FILL x0064             ; d
PROMPT  .STRINGZ "Type a professor's name and then press Enter:"
QUERY   .BLKW 20                ; for storing the user's query of a professor's name
        .END
