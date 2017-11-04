	; R0 contains x, don't touch!!

	.ORIG	x5000

	; Initialize R1
				; R1 will be the counter for Horner's rule loop.
	LD 	R1,ADDR		; R1 contains x4001
	LDR 	R1,R1,#2	; Load R1 with contents at address x4003 (the degree of the polynomial)
				; assume R1 >= 1


	; Initialize R2
				; R2 will contain the value to be multiplied by x
	LD	R2,ADDR
	LDR	R2,R2,#3	; Load R2 with contents at address x4004 (coefficient A)


	; Initialize R3
				; R3 will contain the address of the constant to be added to R2
	LD	R3,ADDR
	ADD	R3,R3,#4	; Load R3 with x4005 (address of coefficient B)


	; Horner's rule loop

HLOOP	LDR	R4,R3,0		; Put value at address R3 into R4

	; Initialize R5
				; R5 will contain a product
	AND	R5,R5,#0

	; Multiply R2 with R0, put into R5

	ADD	R6,R0,#0	; R6 contains what gets added repeatedly
	ADD	R2,R2,#0	; R2 contains how many times to add
	BRp	#4		; If R2 is non-positive, switch sign of R2 and R6
	NOT	R6,R6
	ADD	R6,R6,#1
	NOT	R2,R2
	ADD	R2,R2,#1

MLOOP	BRz	END		; If R2 is 0, exit

	ADD	R5,R5,R6
	ADD	R2,R2,#-1
	BRnzp	MLOOP

	; End of multiply section

END	ADD	R2,R4,R5	; Add R5 and R4, put into R2
	ADD	R3,R3,#1
	ADD 	R1,R1,#-1
	BRp 	HLOOP		; if R1 <= 0, quit the loop

	; Return
	ADD	R4,R2,#0	; Put R2 into R4
	RET

ADDR	.FILL	x4001
	.END