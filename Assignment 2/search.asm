	.ORIG	x3000

	; Initialize R0

	AND	R0,R0,#0
	ADD	R0,R0,#5


	; Initialize R1

	LD	R1,EVAL


	; Evaluate function at x in R0
	JSRR	R1

	TRAP	x0025	; HALT

EVAL	.FILL	x5000
	.END