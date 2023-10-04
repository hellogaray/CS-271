TITLE String Primitives and Macros    (Proj6_garayl.asm)

; Author: Leonel Garay
; Last Modified: 22/03/15
; OSU email address: garayl@oregonstate.edu
; Course number/section: CS271 Section 400
; Project Number:     6           Due Date: 22/03/15
; Description:	Using macros and procedures the program takes 10 integers (32-bit), checks each input,
;               and returns a list of all accepted inputs, their sum, and a truncated average. 

INCLUDE Irvine32.INC
; ---------------------------------------------------------------------------------
; Name: mGetString
;
; Displays a prompt and gets the user’s keyboard input into a memory location.
;
; Postconditions
;
; Receives: macroPrompt (message prompt to display), macroOutput (holds the user input), 
;           macroCount (lenght of input - max), and macroLength (gets the input lenght)
;
; Returns: macroOutput and macroLenght are variables. eax register is value.
; ---------------------------------------------------------------------------------
mGetString MACRO macroPrompt, macroOutput, macroCount, macroInputSize
    PUSH edx					; Preserve used registers.
    PUSH ebx

	MOV	    edx, macroPrompt
	CALL	WriteString
	MOV	    edx, macroOutput
	MOV	    ecx, macroCount
	CALL	ReadString
    MOV     macroInputSize, eax

    POP ebx                   ; Restore used registers
    POP edx
ENDM

; ---------------------------------------------------------------------------------
; Name: mDisplayString
;
; Print the string which is stored in a specified memory location.
;
; Receives: macroString (the string to be displayed) is a variable.
; ---------------------------------------------------------------------------------
mDisplayString MACRO macroString
    PUSH    edx					; Preserve all registers.

	MOV 	edx, macroString
	CALL	WriteString

    POP     edx                 ; Restore used registers
ENDM

    ; Global Constants.
    MAX_ARRAY_SIZE      EQU 10              ; Change if you want array to be longer than 10 integers.
    MAX_LEN_INPUT       EQU 30              ; Change if you want the input to account for a longer string of numbers.
                                            ; Max number allowed: 999,999,999,999,999,999,999,999,999,999

.data

    ; Variables used to display messages.
    intro1				BYTE	"Designing low-level I/O procedures by Leonel Garay", 0
    intro2				BYTE	"Please provide 10 signed decimal integers (Small enough to fit inside a 32 bit register).", 10, 13, \
                                "The program will then return a list of all accepted inputs, their sum, and a truncated average.", 0
    integerMsg			BYTE	"Please enter a signed number: ", 0
    errorMsg			BYTE	"ERROR: You entered and invalid character (only 0-9) or number is too big.", 0
    listMsg 			BYTE	"You entered the following numbers:", 0
    sumMsg      		BYTE	"The sum of these numbers is: ", 0
    averageMsg			BYTE	"The truncated average is: ", 0
    farewellMsg         BYTE    "Good morning, and in case I don't see ya, good afternoon, good evening, and good night.", 0

    ; Variables used to get user input.
    userInputSize       DWORD   ?

    ; Variables to hold data.
    stringInput         SDWORD  MAX_LEN_INPUT DUP(?)
    stringOutput		SDWORD  MAX_LEN_INPUT DUP(?)
    mainArray           SDWORD  MAX_LEN_INPUT DUP(?)
    sdwordVar		    SDWORD  MAX_LEN_INPUT DUP(?)

    ; Flag for Negative Integers.
    negativeFlag        DWORD    0           ; Flag is set to 0 (positive) by default, change to 1 for negative.

.code
main PROC
    ; Introducing the program title, student name, and description.
    mDisplayString	OFFSET intro1
	CALL	Crlf
    CALL	Crlf
    mDisplayString	OFFSET intro2
	CALL	Crlf
    CALL	Crlf

    ; Sets the amount of integers on a list.
    MOV     ecx, MAX_ARRAY_SIZE             
    MOV     eax, 0
    MOV     edi, OFFSET mainArray

_listLoop:
    ; Loops based on MAX_ARRAY_SIZE (default:10) to create a list.
    PUSH    ecx                             ; Stores ecx for outerloop.

    ; Request integers from user.
    PUSH    OFFSET negativeFlag
    PUSH    OFFSET integerMsg
    PUSH    OFFSET stringOutput
    PUSH    OFFSET errorMsg
    PUSH    OFFSET stringInput
    PUSH    OFFSET userInputSize
    CALL    ReadVal 

_endListLoop:
    ; Stores value in stringOutput and continues the LOOP MAX_ARRAY_SIZE times.
    STOSD
    POP     ecx                             ; Restore ecx for listLoop.
    LOOP    _listLoop
    CALL	Crlf

    ; Displays the List Message.
    mDisplayString	OFFSET listMsg

    ; Gets and displays integers from the list.
    PUSH	OFFSET sdwordVar
	PUSH	OFFSET mainArray
	CALL	getIntegers
	CALL	Crlf

    ; Displays the sum message.
    mDisplayString	OFFSET sumMsg

    ; Gets and displays the total sum of integers.
	CALL	Crlf

    ; Displays the average message.
    mDisplayString	OFFSET averageMsg

    ; Gets and displays truncated average.
    mDisplayString	OFFSET averageMsg
	CALL	Crlf

    ; Farewell message.
    CALL	Crlf
    mDisplayString	OFFSET farewellMsg
	CALL	Crlf

Invoke ExitProcess, 0	                    ; Exit to operating system

main ENDP

; ---------------------------------------------------------------------------------
; Name: ReadVal
;
; Invoke the mGetString macro to get user input in the form of a string of digits.
; Converts string of ascii digits to its numeric value representation (SDWORD).
; Validates input: only numbers or +/-. Store this one value in a memory variable.
;
; Receives: [ebp + 28]  = negativeFlag  - flag to account for negative numbers.
;           [ebp + 24]  = integerMsg    - message to be displayed.
;           [ebp + 20]  = stringOutput   - array to store all integers.
;           [ebp + 16]  = errorMsg      - error message.
;           [ebp + 12]  = stringInput    - stores the user input.
;           [ebp + 8]   = userInputSize - Length of size input.
; ---------------------------------------------------------------------------------
ReadVal PROC
    ; Stack Frame Setup. 
    PUSH	ebp				                ; Build Stack Frame
    MOV		ebp, esp		                ; Base Pointer
    SUB		esp, 12                         ; Makes variables		

    ; Preserve registers
    PUSH	eax
	PUSH	ebx
	PUSH	ecx
	PUSH	edx
	PUSH	esi
	PUSH	edi

_getValue:
    ; Asks user for input and checks every characters. 
    mGetString [ebp + 24], [ebp + 12], MAX_LEN_INPUT, [ebp + 8]

    MOV     esi, [ebp + 12]                 ; Move the array to esi.
    MOV     edi, [ebp + 20]
    MOV     ecx, [ebp + 8]                  ; Set ecx for innerloop.
    MOV		ebx, 0
    
    ; Set as varibales for operation to check size of integer and convert.
    MOV		eax, 0
	MOV		DWORD PTR [ebp - 4], 0           
	MOV		DWORD PTR [ebp - 8], 0          
    CLD                                    

_checkForSign:
    ; Checks if input starts with ASCII 45 (+) or 43 (-), continues if else.
    LODSB
	CMP		al, 45                          ; ASCII 45 = - sign.
	JE		_negative
	CMP		al, 43                          ; ASCII 43 = + sign.
	JE		_positive
    JMP     _validate

_readValLoop:
    ; Inner Loop that checks every character of the input.
    LODSB

_validate:
    ; Checks to make sure each character is ASCII 48-57 (numbers).
    CMP     al, 48                          ; Checks character is not below ASCII 48 (0).
    JB      _invalid
	CMP     al, 57                          ; Checks character is not above ASCII 57 (9).
	JA      _invalid
    JMP     _conversionCheck
    
_positive:
    ; Follow this if a positive sign.
    DEC     ecx                             ; Decrease count by 1, ignoring sign.
    JMP     _readValLoop

 _negative:
    ; Follow this if a negative sign.
    DEC     ecx                             ; Decrease count by 1, ignoring sign.
   
    ; Set Negative Flag to 1 to indicate a negative number.
    PUSH    eax
    MOV     eax, 1
    MOV     [ebp + 28], eax                 
    POP     eax

    JMP     _readValLoop

_conversionCheck:
; ---------------------------------------------------------------------------------
; Convert the string of ascii digits to its numeric value representation.
; Checks that the number fits in a 32-byte register.
; Based on pseudo code from Modeule 8's Exploration 1 - Lower Level Programming
; ---------------------------------------------------------------------------------
	SUB		al, 48
	MOV		[ebp - 8], al                   ; numChar - 48
	MOV		al, [ebp - 4] 
	IMUL	eax, 10                         ; 10 * numInt
	JO		_invalid                        ; Check Overflow Flag
    ADD		eax, [ebp - 8]                  ; (10 * numInt) + (numChar - 48) 
	JO		_invalid                        ; Check Overflow Flag
    MOV		[ebp - 4], eax 
    LOOP    _readValLoop

    ; Check if negative flag is set to 1.
    PUSH    eax
    MOV     eax, 1
    CMP     [ebp + 28], eax
    JE      _twoComponent
    POP     eax

    ; Reset Negative Flag.
    PUSH    eax
    MOV     eax, 0
    MOV     [ebp + 28], eax
    POP     eax
	
    JMP		_endReadValLoop

 _twoComponent:
    ; Using NEG for Two's Component for negative numbers.
    POP     eax
    NEG     eax
    JMP     _endReadValLoop

_invalid:
    ; If a chracter is found to be invalid, ask for a new number.
	mDisplayString	[ebp + 16]
	CALL    Crlf
	JMP 	_getValue

_endReadValLoop:
    ; Restore used registers
    POP		edi
	POP		esi
	POP		edx
	POP		ecx
	POP		ebx
    MOV		esp, ebp 
    POP		ebp

    RET     24    		                    ; De-reference
ReadVal ENDP

; ---------------------------------------------------------------------------------
; Name: WriteVal
;
; onvert a numeric SDWORD value to a string of ASCII digits.
; Invoke the mDisplayString macro to print the ASCII representation of the SDWORD 
; value to the output.
;
; Receives: [ebp + 12]  = sdwordVar - variable to be changed.
;           [ebp + 8]   = values    - variable to obtain from.
; ---------------------------------------------------------------------------------
WriteVal PROC
    ; Stack Frame Setup. 
    PUSH	ebp				                ; Build Stack Frame
    MOV		ebp, esp		                ; Base Pointer

    ; Preserve registers
    	PUSH	eax
	PUSH	ebx
	PUSH	ecx
	PUSH	edi
    	PUSH	edx


	

	; Restore used registers
	POP		edx
	POP		edi
	POP		ecx
	POP		ebx
	POP		eax
	POP		ebp

	RET	    8   		                    ; De-reference
WriteVal ENDP


; ---------------------------------------------------------------------------------
; Name: getSum
;
; onvert a numeric SDWORD value to a string of ASCII digits.
; Invoke the mDisplayString macro to print the ASCII representation of the SDWORD 
; value to the output.
;
; Receives: [ebp + 12]  = sdwordVar - variable to be changed.
;           [ebp + 8]   = values    - variable to obtain from.
; ---------------------------------------------------------------------------------
getSum PROC
    ; Stack Frame Setup. 
    PUSH	ebp				;  Build Stack Frame
    MOV		ebp, esp		; Base Pointer
    PUSHAD					; Preserve all registers.


    ; Restore used registers
    POPAD
    POP		ebp

    RET	    					; De-reference  bytes
getSum ENDP

; ---------------------------------------------------------------------------------
; Name: getAverage
;
; onvert a numeric SDWORD value to a string of ASCII digits.
; Invoke the mDisplayString macro to print the ASCII representation of the SDWORD 
; value to the output.
;
; Receives: [ebp + 12]  = sdwordVar - variable to be changed.
;           [ebp + 8]   = values    - variable to obtain from.
; ---------------------------------------------------------------------------------
getAverage PROC
    ; Stack Frame Setup. 
    PUSH	ebp				;  Build Stack Frame
    MOV		ebp, esp		; Base Pointer
    PUSHAD					; Preserve all registers.


    ; Restore used registers
    POPAD
    POP		ebp

    RET	    					; De-reference  bytes
getAverage ENDP

END main