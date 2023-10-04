TITLE Data Validation, Looping, & Constants     (Proj3_garayl.asm)

; Author: Leonel Garay
; Last Modified:
; OSU email address: garaylD@oregonstate.edu
; Course number/section: CS271 Section 400
; Project Number:     3           Due Date: 07/02/22
; Description:	Collects negative number inputs from user in range [limitOne-limitTwo] or [limitThree-limitFour]
;				until a positive number is given and outputs Min, Max, Count, Sum, and Average.
;				range should be only negative numbers, sorted, with LIMITONE being the lowest, and LIMITFOUR the highest

INCLUDE Irvine32.inc

LIMITONE		EQU		-200
LIMITWO			EQU		-100
LIMITTHREE		EQU		-50
LIMITFOUR		EQU		-1
POSITIVE		EQU		0
ROUNDNUM		EQU		51
.data

; Variables used to display messages.
programTitle		BYTE	"Data Validation, Looping, and Constants ", 0
studentName		BYTE	"by Leonel Garay", 0
separator		BYTE	"---------------------------------------------------------------------------------------------------", 0
userInstr		BYTE	"Instructions:", 10 , 13, \
				"Please enter numbers in [-200, -100] or [-50, -1].", 10 , 13, \
				"Enter a non-negative number when you are finished to see results.", 0	
extraCredit		BYTE	"**EC: Number the lines during user input. Increment the line number only for valid number entries.", 10, 13, \
				"**EC: Calculate and display the average as a decimal-point number , rounded to the nearest .01.", 0
askName			BYTE	"What is your name? ", 0
greetUser		BYTE	"Hello there, ", 0
byeUser			BYTE	"We have to stop meeting like this. Farewell, ", 0
numQuestion		BYTE	" Enter number: ", 0
invalidInput		BYTE	"Number Invalid!", 0
cntMsg			BYTE	"** You entered ", 0
cntMsg2			BYTE	" valid numbers.", 0
maxMsg			BYTE	"** The maximum valid number is ", 0
minMsg			BYTE	"** The minimum valid number is ", 0
sumMsg			BYTE	"** The sum of your valid numbers is ", 0
avrMsg			BYTE	"** The rounded average is ", 0
bullet			BYTE	".", 0
ecMsg			BYTE	"** Extra Credit 2 Result is ", 0

; Variables for user imputs.
userName		BYTE	33 DUP(0)
askNum			DWORD	?

; Variables for results
minNum			DWORD	?
maxNum			DWORD	?
cntNum			DWORD	?
sumNum			DWORD	?
avrNum			DWORD	0
avrNum2			DWORD	0
remainder		DWORD	?

.code
main PROC
_beginning:
	; Display program title and student's name.
		mov edx, OFFSET programTitle
		call WriteString
		mov edx, OFFSET studentName
		call WriteString
		call Crlf

	; Display extra credits:
		call Crlf
		mov edx, OFFSET extraCredit
		call WriteString
		call Crlf
		mov edx, OFFSET separator
		call WriteString
		call Crlf
		call Crlf

_questions:
	; Ask user for their name.
		mov edx, OFFSET askName
		call WriteString
		mov edx, OFFSET userName
		mov ecx, 32
		call ReadString

_greeting:
	; Print a greeting for user.
		mov edx, OFFSET greetUser
		call WriteString
		mov edx, OFFSET userName
		call WriteString
		call Crlf
		call Crlf

_instructions:
	; Display instructions for the user.
		mov edx, OFFSET separator
		call WriteString
		call Crlf
		mov edx, OFFSET userInstr
		call WriteString
		call Crlf
		mov edx, OFFSET separator
		call WriteString
		call Crlf
		call Crlf

_inputLoop:
	; Ask for a number until user inputs a positive number.
		inc cntNum
		mov	eax, cntNum
		call WriteDec
		mov	edx, OFFSET bullet
		call WriteString
		mov edx, OFFSET numQuestion
		call WriteString
		call ReadInt
		mov askNum, eax
	; If number is not signed jump to results.
		jns _displayResults
	; If number is less than LIMIT ONE.
		cmp askNum, LIMITONE
		jl _displayError
	; If number is less than  or equal to LIMIT TWO.
		cmp askNum, LIMITWO
		jle _calculateSum
	; If number is less than LIMIT THREE.	
		cmp askNum, LIMITTHREE
		jl _displayError
	; Continue if number is in range.


_calculateSum:
	; Calculating the sum
		mov eax, askNum
		add	sumNum, eax
		
_validateMax:
	; Check if maxNum is 0, if so than replace else calculate the max.
		mov eax, maxNum
		cmp eax, 0
		je _replaceMax
		mov eax, askNum
		cmp eax, maxNum 
		jl _calculateMin
		mov maxNum, eax

_replaceMax:
	; If the max is 0 (not intialized) replace it with askNum.
		mov eax, askNum
		mov maxNum, eax
		jl _calculateMin

_calculateMin:
	; Calculating the min.
		mov eax, askNum
		cmp eax, minNum 
		jg _inputLoop
		mov minNum, eax
		jmp _inputLoop	

_displayError:
	; Ask the user to retry the number.
		mov edx, OFFSET invalidInput
		call WriteString
		sub cntNum, 1
		call Crlf
		jmp _inputLoop

_displayResults:
	; Display instructions for the user.

	; Show the count result.
		call Crlf
		sub cntNum, 1
		mov eax, cntNum
		mov edx, OFFSET separator
		call WriteString
		call Crlf
		mov edx, OFFSET cntMsg
		call WriteString
		mov edx, cntNum
		call WriteDec
		mov edx, OFFSET cntMsg2
		call WriteString
		call Crlf

	; Show the max result.
		mov edx, OFFSET maxMsg
		call WriteString
		mov eax, maxNum
		call WriteInt
		mov edx, OFFSET bullet
		call WriteString
		call Crlf

	; Show the min result.
		mov edx, OFFSET minMsg
		call WriteString
		mov eax, minNum
		call WriteInt
		mov edx, OFFSET bullet
		call WriteString
		call Crlf

	; Show the sum result.
		mov edx, OFFSET sumMsg
		call WriteString
		mov eax, sumNum
		call WriteInt
		mov edx, OFFSET bullet
		call WriteString
		call Crlf

	; Calculating the average.
		mov eax, 0
		mov eax, sumNum
		cdq 
		idiv cntNum     
		mov	avrNum, eax
		mov remainder, edx
		mov avrNum2, eax
	
_decAvr:
	; Get the Remainder to be used in EX.
	; Multiply remainder by 100
		mov eax, remainder
		imul eax, remainder, -100	
		mov remainder, eax
	; Divide result by number count.
		mov edx, 0
		mov ebx, cntNum
		div ebx
		mov remainder, eax
	; Check if remainder is greater than 51.
		mov EAX, remainder
		mov EBX, ROUNDNUM
		CMP EAX, EBX 
		jl _displayAvr
		
_rounderAvr:
	; If less than 51 add 1 to total.
		add avrNum, -1

_displayAvr:
	; Show the average result.
		mov edx, OFFSET avrMsg
		call WriteString
		mov eax, avrNum
		call WriteInt
		mov edx, OFFSET bullet
		call WriteString
		call Crlf

_extraPoints:
		mov edx, OFFSET ecMsg
		call WriteString
		mov eax, avrNum2
		call WriteInt
		mov edx, OFFSET bullet
		call WriteString 
		mov eax, remainder
		call WriteDec
		mov edx, OFFSET bullet
		call WriteString 
		call Crlf
		jmp _partingMessage

_partingMessage:
	; Say goodbye to the user.
		mov edx, OFFSET byeUser
		call WriteString
		mov edx, OFFSET userName
		call WriteString
		mov edx, OFFSET bullet
		call WriteString
		call Crlf
		call Crlf

	Invoke ExitProcess,0	; exit to operating system
main ENDP

; (insert additional procedures here)

END main
