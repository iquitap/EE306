        .ORIG x3000

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

        ; Prompt the user for a professor's name

        LEA     R0,PROMPT
        LD      R1,LINEF
        TRAP    x22             ; PUTS (display PROMPT)

INPUT   TRAP    x20             ; GETC
        TRAP    x21             ; OUT

        NOT     R0,R0
        ADD     R0,#1           ; R0 = -R0

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
        BRnp    SEARCH

        AND     R4,R4,#0
        LDR     R3,R2,#1
        ADD     R3,R3,R4
        BRnp    SEARCH

        HALT

SEARCH
        LEA     R2,QUERY




LINEF   .FILL x000A             ; line feed
d       .FILL x0064             ; d
PROMPT  .STRINGZ "Type a professor's name and then press Enter:"
QUERY   .BLKW 20                ; for storing the user's query of a professor's name
        .END
