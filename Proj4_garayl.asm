TITLE MASM Prime Calculator    (Proj4_garayl.asm)

; Author: Leonel Garay
; Last Modified: 22/02/16
; OSU email address: garaylD@oregonstate.edu
; Course number/section: CS271 Section 400
; Project Number:     4           Due Date: 22/02/22
; Description:	Program that caculates prime numbers based on the user's input. PRogram has a defined
;		range of allowed inputs. If n is out of range the user is re-promted until they enter a value in the range.
;		Change constants to change the limit ( to UPPER_LIMIT), MAX_PRIME_LINE to change amount of primes per line, and PAGE_LIMIT to change amount of lines per page.

INCLUDE Irvine32.inc

UPPER_LIMIT		EQU		4000		; sets the range (1 to UPPER_LIMIT)
MAX_PRIME_LINE		EQU		10		; sets the limit of primes per line 
PAGE_LIMIT		EQU		20		; sets the limt of lines per page

.data

; Variables used to display messages.
programTitle		BYTE	"Nested Loops and Procedures ", 0
studentName		BYTE	"by Leonel Garay", 0
separator		BYTE	"---------------------------------------------------------------------------------------------------", 0
introMsg		BYTE	"Instructions:", 10 , 13, \
				"Enter the number offset prime numbers you would like to see.", 10 , 13, \
				"The acceptable range is 1 to ", 0	
ecMsg			BYTE	"**EC: Align the output columns (the first digit of each number on a row should match with the row above)",10, 13, \
				"**EC: Extend the range of primes to display up to 4000 primes, shown 20 rows of primes per page.", 0
primeMsg		BYTE	"Enter the number of primes to display: ", 0
errorMsg		BYTE	"No primes for you! Number out of range. Try again.", 0
byemsg			BYTE	"Results certified by Leonel Garay. Goodbye.", 0
bullet			BYTE	".", 0

; Variable for user input
requestedPrimes		DWORD	0

; Variables for displaying primes.
curNumber		DWORD	1
counterPerLine		DWORD	0
lineCounter		DWORD	0
pageMsg			BYTE	"This is currently showing 10 primes per line, 20 lines per page. ", 10, 13, \
				"Press any key to continue.", 0
space			BYTE	" ", 0


.code
main PROC

	call introduction
	call getUserData
	call showPrimes
	call farewell	

	Invoke ExitProcess, 0	; exit to operating system

main ENDP

; ---------------------------------------------------------------------------------
; Name: introduction
;
; Introduces the title of the program and the name of the student, followed by
; the extra credit and user instructions.
;
; Receives: programTitle, studentName, ecMsg, separetor, and introMsg 
; are variables.
; ---------------------------------------------------------------------------------
introduction PROC

	_beginning:
		; Display program title and student's name.
			mov edx, OFFSET programTitle
			call WriteString
			mov edx, OFFSET studentName
			call WriteString
			call Crlf

		; Display extra credits:
			call Crlf
			mov edx, OFFSET ecMsg
			call WriteString
			call Crlf
			mov edx, OFFSET separator
			call WriteString
			call Crlf

	_instructions:
		; Display instructions for the user.
			mov edx, OFFSET introMsg
			call WriteString
			mov eax, OFFSET UPPER_LIMIT
			call WriteDec
			mov edx, OFFSET bullet
			call WriteString
			call Crlf
			mov edx, OFFSET separator
			call WriteString
			call Crlf

	ret		; return to Main procedure
introduction ENDP

; ---------------------------------------------------------------------------------
; Name: getUserData
;
; Gets an input from the user to be used as the amount of primes to be shown.
;
; Preconditions: input needs to be withint range of 1 and UPPER_LIMIT
;
; Postconditions: requestedPrimes is changed to the user input
;
; Receives: primeMsg and requestedPrimes are varibales.
;
; Returns: eax = requested number of Primes
; ---------------------------------------------------------------------------------
getUserData PROC

	; Ask for a amount of prime numbers.
	_inputLoop:
		; print message requesting the amount of primes to be shown.
		mov edx, OFFSET primeMsg		
		call WriteString
		call ReadInt
		mov requestedPrimes, eax
		call validate	
		call Crlf

	ret		; return to Main procedure
getUserData ENDP

; ---------------------------------------------------------------------------------
; Name: validate
;
; Checks whether the user's input is wthint range (1 - UPPERLIMIT), display an error
; message if the input is outside of the allowed range.
;
; Preconditions: input needs to be withint range of 1 and UPPER_LIMIT
;
; Receives: requestedPrimes and errorMsg are global variables. UPPER_LIMIT is a constant. 
; ---------------------------------------------------------------------------------
validate PROC
	
	; Validate input user to make sure it is within range.
	_validation:
		cmp requestedPrimes, 1
			jl _displayError
		cmp requestedPrimes, UPPER_LIMIT
			jg _displayError
	
	ret		; return to getUserData procedure

	; Displays error if input is out of the range allowed.
	_displayError:
		mov edx, OFFSET errorMsg
		call WriteString
		call Crlf
		call getUserData	

validate ENDP

; ---------------------------------------------------------------------------------
; Name: showPrimes
;
; display n prime numbers; utilize counting loop and the LOOP instruction to keep 
; track of the number primes displayed; candidate primes are generated within 
; counting loop and are passed to isPrime for evaluation
;
; Postconditions: changes eax and ecx registers. 
; 
; Receives: Receives is like the input of a procedure; it describes everything
;     the procedure is given to work. Parameters, registers, and global variables
;     the procedure takes as inputs should be described here.
;
; Returns: a list of n amount of integers sorted in lines of 10 integers per line withint the allowed range.
; ---------------------------------------------------------------------------------
showPrimes PROC

	; move requestedPrimes to ecx for loop
	mov ecx, requestedPrimes		
	
	; using isPrime will decide wether to print a number or move to the next one.	
	_counterLoop:		
		_tryNextNumber:
			mov requestedPrimes, ecx
			inc curNumber		; keeps track of the current number to be reviewed with isPrime
			mov eax, curNumber
			call isPrime		; checks whether a number is prime, returns 0 for composite, 1 for prime
			cmp eax, 1
				je _primeNumber
		
		; if a composite number is found then move to next number.
		_compositeNumber:		
			jmp _tryNextNumber

		; if a prime number is found then print and align before moving to next number
		_primeNumber:		
			mov eax, curNumber
			call WriteDec
			inc counterPerLine	
			call spacing		; call spacing sub proc to align numbers per EC.
	loop _counterLoop
	; after exiting the loop give space for farewell message.
	call Crlf		
	call Crlf

	ret			; return to Main procedure
showPrimes ENDP

; ---------------------------------------------------------------------------------
; Name: spacing
;
; Aligns the output columns to the left using the space variable, first
; digit of each number on a row should match with the row above.
;
; Preconditions: curNumber must be a prime number.
;
; Receives: curNumber is a global variable.
; ---------------------------------------------------------------------------------
spacing PROC
	
	; depending on the amount of digits of a number allowed for different spacing between digits.
	_spacer:
		cmp counterPerLine, 0
			je _noSpace
		cmp curNumber, 9999
			jg _oneSpacing
		cmp curNumber, 999
			jg _twoSpacing
		cmp curNumber, 99
			jg _threeSpacing
		cmp curNumber, 9
			jg _fourSpacing
		; if 1 digit, give 5 spaces
			mov edx, OFFSET space
			call WriteString
			mov edx, OFFSET space
			call WriteString
			mov edx, OFFSET space
			call WriteString
			mov edx, OFFSET space
			call WriteString
					mov edx, OFFSET space
			call WriteString
		cmp counterPerLine, MAX_PRIME_LINE
			je _line
		jmp _endSpacing

	; if 2 digit, give 4 spaces and check if max number per line is reached.
	_fourSpacing:		
		mov edx, OFFSET space
		call WriteString
		mov edx, OFFSET space
		call WriteString
		mov edx, OFFSET space
		call WriteString
		mov edx, OFFSET space
		call WriteString
		mov edx, OFFSET space
		cmp counterPerLine, MAX_PRIME_LINE
			je _line
		jmp _endSpacing

	; if 3 digit, give 3 spaces and check if max number per line is reached.
	_threeSpacing:		
		mov edx, OFFSET space
		call WriteString
		mov edx, OFFSET space
		call WriteString
		mov edx, OFFSET space
		call WriteString
		mov edx, OFFSET space
		cmp counterPerLine, MAX_PRIME_LINE
			je _line
		jmp _endSpacing

	; if 4 digits, give 2 spaces and check if max number per line is reached.
	_twoSpacing:		
		cmp counterPerLine, MAX_PRIME_LINE
			je _line
		mov edx, OFFSET space
		call WriteString
		mov edx, OFFSET space
		call WriteString

		jmp _endSpacing

	; if 5 digits, give 1 space and check if max number per line is reached.
	_oneSpacing:		
		mov edx, OFFSET space
		call WriteString
		cmp counterPerLine, MAX_PRIME_LINE
			je _line
		jmp _endSpacing

	; if is the first number of a line then no space is needed
	_noSpace:		
		cmp counterPerLine, MAX_PRIME_LINE
			je _line
		jmp _endSpacing
				
	; if the max number per line has been reacher create new line.
	_line:		
		mov counterPerLine, 0
		inc lineCounter
		call Crlf
		cmp lineCounter, PAGE_LIMIT
		je _newPage
		jmp _endSpacing

	; if 20 lines have been printed, ask for input before showing 20 more
	_newPage:		
		call Crlf
		call Crlf

		mov edx, OFFSET pageMsg
		call WriteString
		call ReadInt

		call Crlf
		call Crlf
		mov lineCounter, 0
		call _spacer

	_endSpacing:

	ret		; return to showPrimes procedure.
spacing ENDP

; ---------------------------------------------------------------------------------
; Name: isPrime
;
; Using eax (has curNumber stored) checks whether the number is a prime or a composite.
;
; Preconditions: Outerloop must not have completed.
;
; Postconditions: changes eax and edx registers
;
; Receives: eax register (current number to check)
;
; Returns: eax = 0 (if composite) or eax = 1 (if prime), edx is set back to the
; original value for the outerloop to continue without ending earlier. 
; ---------------------------------------------------------------------------------
isPrime PROC
	mov ebx, eax	 

	; if number is 2, then it is prime - ignore one as 1 is not prime
		cmp eax, 2
			je _foundPrime

	; if number is not 2, start calculatorLoop at 2.
		mov ecx, 2
		mov edx, 0
		div ecx
		mov ecx, eax

		_calculatorLoop:
			; if we reached 1 in the loop then the number is Prime.
			cmp ecx, 1		
				je _foundPrime
			mov eax, ebx
			mov edx, 0
			div ecx
			; if remaider of div (2 to n-1) is 0 then number is not prime.
			cmp edx, 0
				je _foundComposite		
		loop _calculatorLoop

	; if n is a compsite, eax = 0
	_foundComposite:		
		mov eax, 0
		jmp _endIsPrimeLoop

	; if n is a prime, eax = 1
	_foundPrime:		
		mov eax, 1
		
	; return value to ecx for outerloop
	_endIsPrimeLoop:
		mov ecx, requestedPrimes		

	ret		; return to showPrimes procedure
isPrime ENDP

; ---------------------------------------------------------------------------------
; Name: farewell
;
; Prints out a farewell messsage for the user.
;
; Preconditions: showPrimes should have completed.
; ---------------------------------------------------------------------------------
farewell PROC

	; Say goodbye to the user.
	_partingMessage:
		mov edx, OFFSET separator
		call WriteString
		call Crlf

		mov edx, OFFSET byemsg
		call WriteString

		call Crlf
		call Crlf

	ret		; return to Main procedure
farewell ENDP

END main
