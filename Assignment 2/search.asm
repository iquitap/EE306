	; R0: xmin, xmiddle / quotient (division counter)
	; R1: lower bound
	; R2: upper bound
	; R3: f(xmin)
	; R4: f(xmin), R1 + R2, f(xmiddle)
	; R5: bitmask
	; R6: subroutine location
	; R7: don't touch

	.ORIG	x3000


	; Initialize R1
				; R1 contains lower bound
	LDI	R1,MIN


	; Initialize R2
				; R2 contains upper bound
	LDI	R2,MAX


	; Initialize R5
				; R5 contains bitmask
	LD	R5,MASK


	; Initialize R6
				; R6 is the subroutine's location
	LD	R6,EVAL


	; Evaluate function at xmin in R1

LOOP	ADD	R0,R1,#0	; R0 contains xmin
	ST	R1,SAVER1
	ST	R2,SAVER2
	ST	R3,SAVER3
	ST	R5,SAVER5
	ST	R6,SAVER6
	JSRR	R6		; R0 (xmin) is input, R4 f(xmin) is output
	LD	R1,SAVER1
	LD	R2,SAVER2
	LD	R3,SAVER3
	LD	R5,SAVER5
	LD	R6,SAVER6
	ADD	R3,R4,#0	; R3 contains f(xmin)


	; Find the middle


	; Find (R1 + R2)/2 (always rounds to greater absolute value)

	AND	R0,R0,#0	; Reset R0
	ADD	R4,R1,R2
	BRn	DIVIDEN

DIVIDEP	ADD	R4,R4,#0
	BRnz	QUOTNT
	ADD	R4,R4,#-2
	ADD	R0,R0,#1
	BRnzp	DIVIDEP


DIVIDEN	ADD	R4,R4,#0
	BRzp	QUOTNT
	ADD	R4,R4,#2
	ADD	R0,R0,#-1
	BRnzp	DIVIDEN


	; Evaluate function at xmiddle

QUOTNT	ST	R1,SAVER1	; R0 contains xmiddle
	ST	R2,SAVER2
	ST	R3,SAVER3
	ST	R5,SAVER5
	ST	R6,SAVER6
	JSRR	R6		; R0 (xmiddle) is input, R4 f(xmiddle)is output
	LD	R1,SAVER1
	LD	R2,SAVER2
	LD	R3,SAVER3
	LD	R5,SAVER5
	LD	R6,SAVER6	; R4 contains f(xmiddle)


	; Check if f(xmiddle) is 0

	ADD	R4,R4,#0
	BRz	RETURN		; Return xmiddle


	; Compare sign of f(xmin) with f(xmiddle)

	AND	R3,R3,R5	; Bitmask f(xmin)
	AND	R4,R4,R5	; Bitmask f(xmiddle)
	ADD	R3,R3,R4	; R3 contains the sign difference (0 if same sign)
	BRnp	DIFF
SAME	ADD	R1,R0,#0	; R1 (lower bound) = R0 (middle)
	BRnzp	LOOP
DIFF	ADD	R2,R0,#0	; R2 (upper bound) = R0 (middle)
	BRnzp	LOOP


RETURN	STI	R0,STORE	; Store R0 into x4000
	TRAP	x0025	; HALT

EVAL	.FILL	x5000
STORE	.FILL	x4000
MIN	.FILL	x4001
MAX	.FILL	x4002
MASK	.FILL	x8000
SAVER1	.BLKW	#1
SAVER2	.BLKW	#1
SAVER3	.BLKW	#1
SAVER5	.BLKW	#1
SAVER6	.BLKW	#1
	.END