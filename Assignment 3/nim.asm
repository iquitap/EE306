        ; R0: anything
        ; R1: counter during game board display, inputted row
        ; R2: inputted number of rocks
        ; R3: current player (0 if Player 1, 1 if Player 2)
        ; R4: number of rocks in row A
        ; R5: number of rocks in row B
        ; R6: number of rocks in row C
        ; R7: TRAP routine messes with this

        .ORIG   x3000

        ; Initialize current player to player 1
        AND     R3,R3,#0

        ; Initialize row A to 3
        AND     R4,R4,#0
        ADD     R4,R4,#3

        ; Initialize row B to 5
        AND     R5,R5,#0
        ADD     R5,R5,#5

        ; Initialize row C to 8
        AND     R6,R6,#0
        ADD     R6,R6,#8

        ; Display the game board
DISPLAY LEA     R0,A_STR
        TRAP    x22             ; PUTS
        ADD     R1,R4,#0
LOOP_A  LD      R0,ROCK
        TRAP    x21             ; OUT
        ADD     R1,R1,#-1
        BRp     LOOP_A

        LD      R0,LF           ; R0 = linefeed character
        TRAP    x21

        LEA     R0,B_STR
        TRAP    x22
        ADD     R1,R5,#0
LOOP_B  LD      R0,ROCK
        TRAP    x21
        ADD     R1,R1,#-1
        BRp     LOOP_B

        LD      R0,LF           ; R0 = linefeed character
        TRAP    x21

        LEA     R0,C_STR
        TRAP    x22
        ADD     R1,R6,#0
LOOP_C  LD      R0,ROCK
        TRAP    x21
        ADD     R1,R1,#-1
        BRp     LOOP_C

        LD      R0,LF           ; R0 = linefeed character
        TRAP    x21

        ; Display next move prompt string
PROMPT  LEA     R0,PROMPT1
        TRAP    x22             ; PUTS
        ADD     R3,R3,#0
        BRp     PLAYER2

PLAYER1 LD      R0,NUM1
        TRAP    x21             ; OUT
        BRnzp   NEXT

PLAYER2 LD      R0,NUM2
        TRAP    x21

NEXT   LEA     R0,PROMPT2
        TRAP    x22

        ; Get input and echo
        TRAP    x20             ; GETC
        TRAP    x21             ; OUT
        ADD     R1,R0,#0        ; R1 = row
        TRAP    x20
        TRAP    x21
        ADD     R2,R0,#0        ; R2 = number of rocks in ASCII

        LD      R0,LF           ; R0 = linefeed character
        TRAP    x21

        ; Convert R2 from ASCII to decimal
        LD      R0,CONVERT      ; R0 = -30
        ADD     R2,R2,R0        ; R2 = R2 - 30

        ; Check input for bad number: R2 <= 0
        ADD     R2,R2,#0
        BRnz    ERROR

        ; Check input for good row
        LD      R0,LETTERA
        ADD     R0,R1,R0
        BRz     ROW_A
        LD      R0,LETTERB
        ADD     R0,R1,R0
        BRz     ROW_B
        LD      R0,LETTERC
        ADD     R0,R1,R0
        BRz     ROW_C
        BRnzp   ERROR

        ; Check input for bad number: R2 > R4
ROW_A   NOT     R0,R2
        ADD     R0,R0,#1        ; R0 = -R2
        ADD     R0,R4,R0        ; R0 = R4 - R2
        BRn     ERROR
        BRnzp   VALID_A

ROW_B   NOT     R0,R2
        ADD     R0,R0,#1        ; R0 = -R2
        ADD     R0,R5,R0        ; R0 = R5 - R2
        BRn     ERROR
        BRnzp   VALID_B

ROW_C   NOT     R0,R2
        ADD     R0,R0,#1        ; R0 = -R2
        ADD     R0,R6,R0        ; R0 = R6 - R2
        BRn     ERROR
        BRnzp   VALID_C

        ; Display error message, then loop back to PROMPT
ERROR   LEA     R0,E_MSG
        TRAP    x22             ; PUTS
        LD      R0,LF
        TRAP    x21
        BRnzp   PROMPT

        ; Make the move, then check for game over, then swap player and loop to DISPLAY
VALID_A NOT     R0,R2
        ADD     R0,R0,#1        ; R0 = -R2
        ADD     R4,R4,R0        ; R4 = R4 - R2
        BRnz    END
        BRnzp   PRELOOP

VALID_B NOT     R0,R2
        ADD     R0,R0,#1        ; R0 = -R2
        ADD     R5,R5,R0        ; R5 = R5 - R2
        BRnz    END
        BRnzp   PRELOOP

VALID_C NOT     R0,R2
        ADD     R0,R0,#1        ; R0 = -R2
        ADD     R6,R6,R0        ; R6 = R6 - R2
        BRnz    END
        BRnzp   PRELOOP

        ; Swap player, loop to DISPLAY
PRELOOP ADD     R3,R3,#0
        BRp     #2
        ADD     R3,R3,#1
        BRnzp   DISPLAY
        ADD     R3,R3,#-1
        BRnzp   DISPLAY

        ; Announce the other player as winner
END     LEA     R0,PROMPT1
        TRAP    x22             ; PUTS
        ADD     R3,R3,#0
        BRp     WIN1            ; If current player is Player 2, Player 1 wins.
        LD      R0,NUM2
        BRnzp   #1
WIN1    LD      R0,NUM1
        TRAP    x21             ; OUT
        LEA     R0,WIN_STR
        TRAP    x22
        TRAP    x25             ; HALT

CONVERT .FILL #-48
ROCK    .FILL x006F
LF      .FILL x000A
NUM1    .FILL x0031
NUM2    .FILL x0032
LETTERA .FILL xFFBF             ; -x0041
LETTERB .FILL xFFBE             ; -x0042
LETTERC .FILL xFFBD             ; -x0043
A_STR   .STRINGZ "ROW A: "
B_STR   .STRINGZ "ROW B: "
C_STR   .STRINGZ "ROW C: "
PROMPT1 .STRINGZ "Player "
PROMPT2 .STRINGZ ", choose a row and number of rocks: "
WIN_STR .STRINGZ " Wins."
E_MSG   .STRINGZ "Invalid move. Try again."
        .END
