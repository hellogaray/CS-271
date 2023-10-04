TITLE					Basic Logic/Arithmetic Program     (Proj1_garayl.asm)

; Author:				Leonel Garay
; Last Modified:			15/01/22
; OSU email address:			garayl@oregonstate.edu
; Course number/section:		CS271 400
; Project Number: 01			Due Date: 24/01/22
; Description:				This program takes three numbers in descending order from the user and either sum or subtracts them 
;					(A+B, A-B, A+C, A-C, B+C, B-C, and A+B+C)							

INCLUDE Irvine32.inc

.data

; Variables used to display messages.
programTitle		BYTE	"Basic Logic and Arithmetic Program ", 0
studentName		BYTE	"by Leonel Garay", 0
separator		BYTE	"---------------------------------------------------------------------------------------------------", 0
userInstr		BYTE	"Insert three numbers in descending order.", 10 , 13, \						
				"Results will display the sum and differences: A+B, A-B, A+C, A-C, B+C, B-C, and A+B+C.", 0	
extraCredit		BYTE	"**EC: Repeat until the user chooses to quit.", 10, 13, \
				"**EC: Handle negative results and computes B-A, C-A, C-B, C-B-A.", 10, 13, \
				"**EC: Check if numbers are not in strictly descending order.", 10, 13, \
				"**EC: Calculate and display the quotients A/B, A/C, B/C, printing the quotient and remainder", 0
errorMsg		BYTE	"WARNING: The numbers are not in descending order! But I guess will still give you the results.", 0
continueMsg		BYTE	"Do you want to continue? (y/n)", 0
promptNumA		BYTE	"What is number A (Highest)? ", 0
promptNumB		BYTE	"What is number B (Middle)? ", 0
promptNumC		BYTE	"What is number C (Lowest)? ", 0
addition		BYTE	" + ", 0
subtraction		BYTE	" - ", 0
division		BYTE	" / ", 0
remainder		BYTE	" remainder ", 0
equal			BYTE	" = ", 0
goodbye			BYTE	"Calculations are done.", 10, 13, \
				"See you later!", 0

; Variables for user imputs.
numberA			DWORD	?
numberB			DWORD	?
numberC			DWORD	?
continueInp		DWORD	?

; Variables used to store results of each equation.
result_1		DWORD	?			; A+B, to be calculated
result_2		DWORD	?			; A-B, to be calculated
result_3		DWORD	?			; A+C, to be calculated
result_4		DWORD	?			; A-C, to be calculated
result_5		DWORD	?			; B+C, to be calculated
result_6		DWORD	?			; B-C, to be calculated
result_7		DWORD	?			; A+B+C, to be calculated
result_8		DWORD	?			; B-A, to be calculated
result_9		DWORD	?			; C-A, to be calculated
result_10		DWORD	?			; C-B, to be calculated
result_11		DWORD	?			; C-B-A, to be calculated
result_12		DWORD	?			; A/B, to be calculated
remain_12		DWORD	?			; A/B remainder, to be calculated
result_13		DWORD	?			; A/C, to be calculated
remain_13		DWORD	?			; A/C remainder, to be calculated
result_14		DWORD	?			; B/C, to be calculated
remain_14		DWORD	?			; B/C remainder, to be calculated

.code
main PROC
_beginning:
	; Display program title and student's name.
		mov edx, OFFSET programTitle
		call WriteString
		mov edx, OFFSET studentName
		call WriteString
		call Crlf

	; Display instructions for the user.
		mov edx, OFFSET separator
		call WriteString
		call Crlf
		mov edx, OFFSET userInstr
		call WriteString
		call Crlf

	; Display extra credits:
		mov edx, OFFSET extraCredit
		call WriteString
		call Crlf
		mov edx, OFFSET separator
		call WriteString
		call Crlf

; Prompt the user to enter three numbers (A, B, C) in strictly descending order.
_questions:
	; Highest number (A).
	mov edx, OFFSET promptNumA
	call WriteString
	mov edx, OFFSET numberA
	call ReadDec
	mov numberA, eax

	; Middle number (B).
	mov edx, OFFSET promptNumB
	call WriteString
	mov edx, OFFSET numberB
	call ReadDec
	mov numberB, eax

	; Lowest number (C).
	mov edx, OFFSET promptNumC
	call WriteString
	mov edx, OFFSET numberC
	call ReadDec
	mov numberC, eax

	; Separator
	mov edx, OFFSET separator
	call WriteString
	call Crlf

; extra credit: Check if numbers are not in strictly descending order.
; compare the numberA and numberB, if B is higher than A display error mesage (_orderError), else continue to Step 2.
_verificationStep1:
	mov eax, numberB
	cmp eax, numberA
	jg _orderError
	jle _verificationStep2

; compare the numberB and numberC, if C is higher than B display error message (_orderError), else continue to next calculations.
_verificationStep2:
	mov eax, numberC
	cmp eax, numberB
	jg _orderError
	jle _Calculations

; error Message if the values are not in descending order.
_orderError:
	mov edx, OFFSET errorMsg
	call WriteString
	call Crlf

	; Separator
	mov edx, OFFSET separator
	call WriteString
	call Crlf

; Calculate the sum and differences: A+B, A-B, A+C, A-C, B+C, B-C, and A+B+C.
_Calculations:
	; Calculate A+B
	mov eax, numberA
	add eax, numberB
	mov result_1, eax					; store results in var

	; Calculate A-B
	mov eax, numberA
	sub eax, numberB
	mov result_2, eax					; store results in var

	; Calculate A+C
	mov eax, numberA
	add eax, numberC
	mov result_3, eax					; store results in var

	; Calculate A-C
	mov eax, numberA
	sub eax, numberC
	mov result_4, eax					; store results in var

	; Calculate B+C
	mov eax, numberB
	add eax, numberC
	mov result_5, eax					; store results in var

	; Calculate B-C
	mov eax, numberB
	sub eax, numberC
	mov result_6, eax					; store results in var

	; Calculate A+B+C
	mov eax, numberC
	add eax, result_1
	mov result_7, eax					; store results in var
	
	; Calculate B-A
	mov eax, numberB
	sub eax, numberA
	mov result_8, eax					; store results in var

	; Calculate  C-A
	mov eax, numberC
	sub eax, numberA
	mov result_9, eax					; store results in var

	; Calculate  C-B
	mov eax, numberC
	sub eax, numberB
	mov result_10, eax					; store results in var

	; Calculate  C-B-A
	mov eax, numberC
	sub eax, numberB
	sub eax, numberA
	mov result_11, eax					; store results in var

	; Calculate A/B
	mov eax, numberA       
	mov edx, 0						; clear high dividend  
	mov ebx, numberB    
	div ebx        
	mov result_12, eax					; store result in var
	mov remain_12, edx					; store remainder in var      

	; Calculate A/C 
	mov eax, numberA       
	mov edx, 0						; clear high dividend  
	mov ebx, numberC   
	div ebx        
	mov result_13, eax					; store result in var
	mov remain_13, edx					; store remainder in var 

	; Calculate B/C
	mov eax, numberB       
	mov edx, 0						; clear high dividend  
	mov ebx, numberC
	div ebx        
	mov	result_14, eax					; store result in var
	mov remain_14, edx					; store remainder in var 

; Display the sum and differences: A+B, A-B, A+C, A-C, B+C, B-C, and A+B+C.
; Display Results of A+B
	mov eax, numberA
	call WriteDec
	mov edx, OFFSET addition
	call WriteString
	mov eax, numberB
	call WriteDec
	mov edx, OFFSET equal
	call WriteString
	mov eax, result_1
	call WriteInt
	call Crlf

; Display Results of A+B
	mov eax, numberA
	call WriteDec
	mov edx, OFFSET subtraction
	call WriteString
	mov eax, numberB
	call WriteDec
	mov edx, OFFSET equal
	call WriteString
	mov eax, result_2
	call WriteInt
	call Crlf

; Display Results of A+C
	mov eax, numberA
	call WriteDec
	mov edx, OFFSET addition
	call WriteString
	mov eax, numberC
	call WriteDec
	mov edx, OFFSET equal
	call WriteString
	mov eax, result_3
	call WriteInt
	call Crlf

; Display Results of A-C
	mov eax, numberA
	call WriteDec
	mov edx, OFFSET subtraction
	call WriteString
	mov eax, numberC
	call WriteDec
	mov edx, OFFSET equal
	call WriteString
	mov eax, result_4
	call WriteInt
	call Crlf

; Display Results of B+C
	mov eax, numberB
	call WriteDec
	mov edx, OFFSET addition
	call WriteString
	mov eax, numberC
	call WriteDec
	mov edx, OFFSET equal
	call WriteString
	mov eax, result_5
	call WriteInt
	call Crlf

; Display Results of B-C
	mov eax, numberB
	call WriteDec
	mov edx, OFFSET subtraction
	call WriteString
	mov eax, numberC
	call WriteDec
	mov edx, OFFSET equal
	call WriteString
	mov eax, result_6
	call WriteInt
	call Crlf

; Display Results of A+B+C
	mov eax, numberA
	call WriteDec
	mov edx, OFFSET addition
	call WriteString
	mov eax, numberB
	call WriteDec
	mov edx, OFFSET addition
	call WriteString
	mov eax, numberC
	call WriteDec
	mov edx, OFFSET equal
	call WriteString
	mov eax, result_7
	call WriteInt
	call Crlf

; Display the extra credit equations.
; Display Results of B-A
	mov eax, numberB
	call WriteDec
	mov edx, OFFSET subtraction
	call WriteString
	mov eax, numberA
	call WriteDec
	mov edx, OFFSET equal
	call WriteString
	mov eax, result_8
	call WriteInt
	call Crlf

; Display Results of C-A
	mov eax, numberC
	call WriteDec
	mov edx, OFFSET subtraction
	call WriteString
	mov eax, numberA
	call WriteDec
	mov edx, OFFSET equal
	call WriteString
	mov eax, result_9
	call WriteInt
	call Crlf

; Display Results of C-B
	mov eax, numberC
	call WriteDec
	mov edx, OFFSET subtraction
	call WriteString
	mov eax, numberB
	call WriteDec
	mov edx, OFFSET equal
	call WriteString
	mov eax, result_10
	call WriteInt
	call Crlf

; Display Results of C-B-A
	mov eax, numberC
	call WriteDec
	mov edx, OFFSET subtraction
	call WriteString
	mov eax, numberB
	call WriteDec
	mov edx, OFFSET subtraction
	call WriteString
	mov eax, numberA
	call WriteDec
	mov edx, OFFSET equal
	call WriteString
	mov eax, result_11
	call WriteInt
	call Crlf

; Display Results of A/B
	mov	eax, numberA
	call WriteDec
	mov	edx, OFFSET division
	call WriteString
	mov	eax,  numberB
	call WriteDec
	mov	edx, OFFSET equal
	call WriteString
	mov	eax, result_12					; print the result
	call WriteDec
	mov	edx, OFFSET remainder		
	call WriteString
	mov ebx, remain_12					; print the remainder
	call WriteDec
	call CrLf

; Display Results of A/C
	mov eax, numberA
	call WriteDec
	mov edx, OFFSET division
	call WriteString
	mov	eax,  numberC
	call WriteDec
	mov	edx, OFFSET equal
	call WriteString
	mov	eax, result_13					; print the result
	call WriteDec
	mov edx, OFFSET remainder
	call WriteString
	mov eax, remain_13					; print the remainder
	call WriteDec
	call CrLf

; Display Results of B/C
	mov	eax, numberB
	call WriteDec
	mov	edx, OFFSET division
	call WriteString
	mov eax,  numberC
	call WriteDec
	mov edx, OFFSET equal
	call WriteString
	mov eax, result_14					; print the result
	call WriteDec	
	mov edx, OFFSET remainder		
	call WriteString
	mov eax, remain_14					; print the remainder
	call WriteDec
	call CrLf

; Separator
mov edx, OFFSET separator
call WriteString
call Crlf

; Display a closing message
mov edx, OFFSET goodbye
call WriteString
call Crlf

; Separator
mov edx, OFFSET separator
call WriteString
call Crlf

jmp _beginning							; jump back to the beggining and start all over.

	Invoke ExitProcess, 0				; exit to operating system
main ENDP

END main