TITLE Combinatorics     (combinatorics.asm)

; Author: Tim Robinson
; Date: 3/11/2015
; Description: This program creates problems and calculates the number of
;	combinations of r items taken from a set of n items. This program
;	creates a random n in [3 .. 12] and a random r in [1 .. n]. The
;	program then allows a student to enter the answer they calculated 
;	on their own and then grades their answer. All input is given in 
;	integers.

INCLUDE Irvine32.inc

HI = 12
LO = 3

.data

intro_1		BYTE		"Combinatorics! ", 0
intro_2		BYTE		"By Tim Robinson ", 0
instruct_1	BYTE		"This program generates a random value n and a random value r. ", 0
instruct_2	BYTE		"The user calculates the number of combinations of r items taken ", 0
instruct_3	BYTE		"from a set of n items. The program will do the same, grade the ", 0
instruct_4	BYTE		"user's answer and display the correct answer. ", 0
value_n		DWORD	?					; [3 .. 12]
value_r		DWORD	?					; [1 .. n]
value_label_1	BYTE		"Number of items n: ", 0
value_label_2	BYTE		"Number in set r: ", 0
prompt_1	BYTE		"How many combinations of size r can be made from n items? ", 0
user_answer	DWORD	?
result		DWORD	?
current_val	DWORD	?
val_a		DWORD	1
val_b		DWORD	1
val_c		DWORD	1
incorrect_ans	BYTE		"Oh no! That's not the correct answer! ", 0
correct_ans	BYTE		"That's correct! Good job! ", 0
result_print	BYTE		"The correct answer is: ", 0
play_again	BYTE		"Generate another problem? (1:yes/0:no) ", 0
repeat_input	BYTE		33 DUP(0)
correct_input	BYTE		"y", 0
count_format	BYTE		")    ", 0
spacer		BYTE		"      ", 0
display_score1	BYTE		"You got ", 0
display_score2	BYTE		" out of ", 0
display_score3	BYTE		"! ", 0
wrong_input	BYTE		"Sorry, must be a 1 or 0! ", 0

problem_count	DWORD	0
score_count	DWORD	0

.code


mWriteStr MACRO buffer
	push			edx
	mov			edx, OFFSET buffer
	call			WriteString
	pop			edx
ENDM


main PROC
;	Introduction
	call			Randomize
	call			intro

problem_set:
;	Show the problem (create the random numbers), accepts addresses of n and r
	mov			eax, 0
	mov			result, eax
	mov			eax, 1
	mov			val_a, eax
	mov			val_b, eax
	mov			val_c, eax

	inc			problem_count
	mov			eax, problem_count
	call			WriteDec
	mWriteStr		count_format

	push			OFFSET value_n
	push			OFFSET value_r
	call			showProblem

;	Get data from the user
	push			OFFSET user_answer
	call			getData

;	Do the combinatorics
	push			value_n
	push			value_r
	push			OFFSET result
	call			combinations

;	Show the results
	push			user_answer
	push			result
	call			showResults

play_againL:
;	Ask if play again
	mWriteStr		play_again
	call			ReadInt
	mov			ebx, 1
	cmp			ebx, eax
	je			problem_set
	
	mov			ebx, 0
	cmp			ebx, eax
	je			display_final
	mWriteStr		wrong_input
	jmp			play_againL

display_final:
;	Display final results
	call			CrLf
	mWriteStr		display_score1
	mov			eax, score_count
	call			WriteDec
	mWriteStr		display_score2
	mov			eax, problem_count
	call			WriteDec
	mWriteStr		display_score3
	call			CrLf
	

	exit	; exit to operating system
main ENDP

; intro

; Procedure to introduce the user to the program and give instructions
; Receives: none 
; Returns:  none, prints messages to the screen
; Preconditions:  none 
; Registers changed: edx (using the mWriteStr macro)

intro PROC
	mWriteStr		intro_1
	call			CrLf
	mWriteStr		intro_2
	call			CrLf
	mWriteStr		instruct_1
	call			CrLf
	mWriteStr		instruct_2
	call			CrLf
	mWriteStr		instruct_3
	call			CrLf
	mWriteStr		instruct_4
	call			CrLf
	ret
intro ENDP

; showProblem

; Procedure to generate random values for n and r and show the user.
; Receives: value_n reference, value_r reference
; Returns: value_n and value_r references, their values changed
; Preconditions:  There must be valid HI and LO constants defined. The "Randomize"
;	procedure must have been called so that the "RandomRange" procedure
;	will work as expected. This procedure also uses the mWriteStr macro.
; Registers changed: eax, ebx, ecx, edx (ebp register changed and restored)

showProblem PROC
	push		ebp
	mov		ebp, esp
	mov		eax, LO
	mov		ebx, HI
	sub		eax, ebx
	neg		eax				; Ensure that the random range is positive
	call		RandomRange
	add		eax, LO

	; Print n
	mWriteStr	value_label_1
	call		WriteDec
	call		CrLf

	mov		ecx, [ebp + 12]	; move the address into ecx
	mov		[ecx], eax		; assign eax to contents at address ecx
	mov		eax, 1
	mov		ebx, [ecx]  
	sub		eax, ebx
	neg		eax
	call		RandomRange
	add		eax, 1

	; Print r
	mWriteStr	spacer
	mWriteStr	value_label_2
	call		WriteDec
	call		CrLf

	mov		ecx, [ebp + 8]		; move the address into ecx
	mov		[ecx], eax		; assign eax to contents at address ecx
	pop		ebx
	ret		8
showProblem ENDP

; getData

; Procedure to prompt and store the user's answer.
; Receives: user_answer variable reference
; Returns: user_answer reference, its value changed to user input
; Preconditions:  The user's input should be an integer for the rest of
;	the program to work as expected.
; Registers changed: eax, ecx (ebp register changed and restored)

getData PROC 
	push		ebp
	mov		ebp, esp
	mWriteStr	prompt_1

	call		ReadInt

	mov		ecx, [ebp + 8]
	mov		[ecx], eax

	pop		ebp
	ret 4
getData ENDP

; combinations

; Procedure to calculate the number of combinations of size r
;	can be made using n items. 
; Receives: value_n and value_r as variables, answer variable reference
; Returns: value_n and value_r unchanged, answer variable contains the
;	calculation answer, its reference returned
; Preconditions: The factorial procedure must be well-defined, which
;	this procedure uses as a building block to combine its results.
;	The values of n and r must be positive and nonzero and the result
;	variable should be zero.
; Registers changed: eax, ebx, ecx, edx (ebp register changed and restored)


combinations PROC
	push		ebp
	mov		ebp, esp
	
	; calculate n!
	mov		eax, [ebp + 16]
	push		eax				; push n to calculate n!
	push		OFFSET val_a		; this will store n!
	call		factorial

	; calculate r!
	mov		eax, [ebp + 12]
	push		eax
	push		OFFSET val_b
	call		factorial

	; calculate (n - r)!
	mov		eax, [ebp + 16]
	mov		ebx, [ebp + 12]
	sub		eax, ebx
	push		eax
	push		OFFSET val_c
	call		factorial

	; calculate r!*(n-r)!
	mov		eax, val_b
	mov		ebx, val_c
	mul		ebx
	mov		val_b, eax

	; calculate n! / (r! * (n - r)!)
	mov		eax, val_a
	mov		ebx, val_b
	mov		edx, 0
	div		ebx
	mov		ecx, [ebp + 8]
	mov		[ecx], eax

	pop		ebp
	ret 12
combinations ENDP

; factorial

; Recursive procedure to calculate the factorial of a number passed in
; Receives: a single integer value
; Returns: the factorial of the number passed in
; Preconditions: The integer passed in must be nonzero and positive in
;	order for the recursion to work as expected
; Registers changed: eax, ecx, edx (ebp register changed and restored)

factorial PROC
	push		ebp
	mov		ebp, esp
	mov		eax, [ebp + 12]
	mov		current_val, eax
	mov		ecx, [ebp + 8]		; store address of running total 
	mov		edx, [ecx]
	mul		edx
	mov		[ecx], eax
	mov		eax, current_val
	cmp		eax, 1
	je		quit
recurse:
	dec		eax
	push		eax
	push		ecx
	call		factorial

quit:
	pop		ebp
	ret 8
factorial ENDP


; showResults

; Procedure to display the results of one question
; Receives: user_answer and result variables
; Returns: the user's answer and result variables, unchanged
; Preconditions: The user's answer and result variables should
;	be positive and nonzero in order to work as expected
; Registers changed: eax, ebx, (ebp register changed and restored)
;	(edx register changed in mWriteStr macro)

showResults PROC
	push		ebp
	mov		ebp, esp
	mov		eax, [ebp + 12]		; store user answer
	mov		ebx, [ebp + 8]			; store result
	cmp		eax, ebx
	je		correct
incorrect:
	mWriteStr	incorrect_ans
	call		CrLf
	mWriteStr	result_print
	mov		eax, result
	call		WriteDec
	call		CrLf
	jmp		resultEnd

correct:
	inc		score_count
	mWriteStr	correct_ans
	mov		eax, result
	call		WriteDec
	call		CrLf

resultEnd:
	pop ebp
	ret 8
showResults ENDP

END main
