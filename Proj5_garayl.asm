TITLE MASM Integer Sorter and Calculator    (Proj5_garayl.asm)

; Author: Leonel Garay
; Last Modified: 22/02/16
; OSU email address: garaylD@oregonstate.edu
; Course number/section: CS271 Section 400
; Project Number:     5           Due Date: 28/02/28
; Description:	Using global constants it generates an array of <ARRAYSIZE> with numbers in range of
;               <LO> - <HI>. It displays and generates a original list, a sorted list, the median, 
;               and a count of the times each number appears on the list.

INCLUDE Irvine32.INC
    ; Global Constants.
    ARRAYSIZE			EQU		200
    LO					EQU		15	
    HI					EQU		50		

.data
    ; Variables used to display messages.
    intro1				BYTE	"Nested Loops and Procedures by Leonel Garay", 0
    intro2				BYTE	"This program generates 200 random numbers in the range [15 ... 50].", 10, 13, \
							    "Generates: a list, a sorted list, a median value, and a count of each instance starting at 10.", 10, 13, \
                                "Then displays: original list, a sorted list, the median value, and a count of each instance.", 0
    unsortedMsg			BYTE	"Your unsorted random numbers: ", 0
    mediandMsg			BYTE	"The median value of the array: ", 0
    sortedMsg			BYTE	"Your sorted random numbers: ", 0
    instancesdMsg		BYTE	"Your list of instances of each generated number, starting with the number of 10s:", 0
    farewellMsg			BYTE	"Goodbye, and thanks for using this program! ", 0

    ; Array variables.
    randArray			DWORD	ARRAYSIZE DUP(?)
    countArray          DWORD   ARRAYSIZE DUP(?)

.code
main PROC
    ; Per instrutions use Randomize once in main to generate a random seed.
    CALL	Randomize

    ; Introducing the program title, student name, and description.
    PUSH	OFFSET intro1
    PUSH	OFFSET intro2
    CALL	introduction

    ; Fill in randArray with random numbers.
    PUSH	OFFSET randArray
    CALL	fillArray

    ; Display the original list.
    PUSH    OFFSET ARRAYSIZE
    PUSH	OFFSET unsortedMsg
    PUSH	OFFSET randArray
    CALL	displayList

    ; Generate a Sorted list based on original array.
    PUSH    OFFSET mediandMsg
    PUSH    OFFSET randArray
    CALL    sortList   

    ; Generate and display the median. number.
    PUSH	OFFSET randArray
    CALL	displayMedian

    ; Display the sorted list.
    PUSH    OFFSET ARRAYSIZE
    PUSH	OFFSET sortedMsg
    PUSH	OFFSET randArray
    CALL	displayList

    ; Generate the count of instances of each number on the array.
    PUSH    OFFSET countArray
    PUSH	OFFSET randArray
    CALL    countList

    ; Display the count of instances.
    PUSH    OFFSET HI - LO + 1
    PUSH	OFFSET instancesdMsg
    PUSH	OFFSET countArray
    CALL	displayList

    ; Farewell for the user, end of the program.
    PUSH	OFFSET farewellMsg	; Address OFFSETs are 4 bytes
    CALL	farewell

Invoke ExitProcess, 0	    ; Exit to operating system

main ENDP

; ---------------------------------------------------------------------------------
; Name: introduction
;
; Introduces the title of the program and the name of the student, followed by
; the extra credit and user instructions.
; ---------------------------------------------------------------------------------
introduction PROC
    ; Stack Frame Setup. 
    PUSH	ebp				;  Build Stack Frame
    MOV		ebp, esp		; Base Pointer
    PUSHAD					; Preserve all registers.

    MOV		edx, [ebp + 12]

    ; Display intro1 (title of the program and student's name)
    CALL	WriteString
    CALL	Crlf
    CALL	Crlf
    POP		edx

    ; Display intro2 (description of the program)
    PUSH	edx
    MOV		edx, [ebp + 8]
    CALL	WriteString	
    CALL	Crlf
    CALL	Crlf

    ; Restore used registers
    POPAD
    POP		ebp

    RET	    8					; De-reference 4 + 4 = 8 bytes
introduction ENDP

; ---------------------------------------------------------------------------------
; Name: fillArray
;
; Generates an array of <ARRAYSIZE> with random numbers between <LO> and <HI>.
;
; Receives: passed randArray as a refence.
; It uses global constant LO, HI, and ARRAYSIZE
;
; Returns: an array of random numbers (randArray).
; ---------------------------------------------------------------------------------
fillArray PROC
    ; Stack Frame Setup. 
    PUSH	ebp				;  Build Stack Frame
    MOV		ebp, esp		; Base Pointer
    PUSHAD					; Preserve all registers.

    MOV		edi, [ebp + 8]	; EDI is used for destination operand operations(i.e., overwriting an element of an array)
    MOV		ecx, ARRAYSIZE	; Copy ARRASIZE to maintain original and use in LOOP.

_fillArrayLoop:
    ; Loop to fill in randArray.

    MOV		eax, HI
    SUB		eax, LO
    INC     eax
    CALL	RandomRange		
    ADD		eax, LO         ; Generates each random number.  
    MOV		[edi], eax      
    ADD		edi, 4			; 4 for the next location on the array.
    DEC		ecx
    CMP		ecx, 0
    JE		_ending			; Once completed jump to ending to finish proc.
    JMP		_fillArrayLoop

_ending:                
    ; No action taken.

    ; Restore used registers
    POPAD
    POP		ebp

    RET	    4				; De-reference 4 bytes
fillArray ENDP

; ---------------------------------------------------------------------------------
; Name: sortList
;
; Sorts the original array (randArray). Uses SUB-procedures to swap elements.
;
; Preconditions: randArray most be filled before it can be sorted.
;
; Receives: passed randArray as a refence.
; It uses global constant ARRAYSIZE
;
; Returns: a sorted array of random numbers (randArray).
; ---------------------------------------------------------------------------------
sortList PROC
    ; Stack Frame Setup. 
    PUSH	ebp				;  Build Stack Frame
    MOV		ebp, esp		; Base Pointer
    PUSHAD					; Preserve all registers.

    MOV		ecx, ARRAYSIZE
    DEC		ecx

_sortListLoop:
    ; Starts the LOOP to sort all numbers.

    PUSH	ecx						
    MOV		esi, [ebp + 8]

_sortListInnerLoop:
    ; Inner LOOP for sorting, CALLs exchangeElements to exchange places.

    MOV		eax, [esi]
    CMP		[esi + 4], eax
    JG		_sortListInnerLoop2
    MOV     edx, [esi + 4]
    CALL    exchangeElements    ; CALLs SUB-procedure to exchange elements.
    MOV     [esi + 4], edx
    MOV		[esi], eax									

_sortListInnerLoop2:
    ; Yet another LOOP for sorting.

    ADD		esi, 4
    LOOP	_sortListInnerLoop

    POP		ecx	
    LOOP	_sortListLoop

    ; Restore used registers
    POPAD
    POP		ebp

    RET	    4				; De-reference 4 bytes
sortList ENDP

; ---------------------------------------------------------------------------------
; Name: exchangeElements
;
; Exchanges the elements of randArray (randArray[i] <==> randArray[j]). 
;
; Receives: passed randArray[i] and randArray[j] as a refence.
;
; Returns: randArray[i] with the value of randArray[j] and viceversa.
; ---------------------------------------------------------------------------------
exchangeElements PROC
    ; Stack Frame Setup. 
    PUSH	ebp				;  Build Stack Frame
    MOV		ebp, esp		; Base Pointer
    PUSH    esi

    ; swap the values of eax and edx
    MOV     esi,  eax       ; eax register into ESI
    MOV     edi,  edx       ; edx register into EDI
    MOV     eax, edi
    MOV     edx, esi

    ; Restore used registers
    POP     esi
    POP		ebp

    RET		               ; return to sortList procedure
exchangeElements ENDP

; ---------------------------------------------------------------------------------
; Name: displayMedian
;
; Using the sorted list, it finds the middle number to get the median of the array.
; If array is odd then the middle number is the median, if array is even then it 
; calculates the median by dividing the middle number and the number before it by 2.
;
; Preconditions: randArray most be sorted in ascending number.
;
; Receives: passed mediandMsg and randArray as a refence.
;
; Returns: Displays the results and a message.
; ---------------------------------------------------------------------------------
displayMedian PROC
    ; Stack Frame Setup. 
    PUSH	ebp				;  Build Stack Frame
    MOV		ebp, esp		; Base Pointer
    PUSHAD					; Preserve all registers.
    MOV     edi, [ebp + 8]  ; Move list to edi.

    ; Prepare DIV to find middle of array.
    MOV		eax, ARRAYSIZE									
    MOV		edx, 0		
    MOV		ebx, 2

    ; Find middle of array.
    DIV		ebx              ; Get pseudo-middle
    MOV     ecx, eax         ; Move pseudo-middle to ecx for LOOP

_findMiddle:
    ; Starts calculations to find the median.

    ADD     edi, 4          ; Move to the following number in array.
    LOOP    _findMiddle

    ; Checks remainder to determine if array is even or odd.
    CMP		edx, 0
    JG      _oddMedian
    JMP     _evenMedian 

_oddMedian:
    ; For odd array: use middle number

    MOV     eax, [edi]
    JMP     _display

_evenMedian: 
    ; For even array: (middle + number before middle)/2

    MOV     eax, [edi - 4]
    ADD     eax, [edi]
    MOV     edx, 0
    MOV     ebx, 2
    DIV     ebx

_display:
    ; Display message and median.

    MOV		edx, [ebp + 12] ; Displays median message.
    CALL	WriteString
    CALL    WriteDec        ; Display median
    CALL	crlf
    CALL	crlf

    ; Restore used registers
    POPAD
    POP		ebp

    RET		8			    ; De-reference 4 + 4 = 8 bytes
displayMedian ENDP

; ---------------------------------------------------------------------------------
; Name: countList
;
; Using the sorted list, it finds the middle number to get the median of the array.
; If array is odd then the middle number is the median, if array is even then it 
; calculates the median by dividing the middle number and the number before it by 2.
;
; Preconditions: randArray most be sorted in ascending number.
;
; Receives: passed mediandMsg and randArray as a refence.
;
; Returns: Displays the results and a message.
; ---------------------------------------------------------------------------------
countList PROC
    ; Stack Frame Setup. 
    PUSH	ebp			    ; Build Stack Frame
    MOV		ebp, esp	    ; Base Pointer
    PUSHAD	                ; Preserve all registers.

    MOV     esi, [ebp + 8]  ; randArray
    MOV     edi, [ebp + 12] ; countArray
    MOV     edx, LO           
    MOV     ebx, 0          ; counter
    MOV     ecx, ARRAYSIZE  ; set times to LOOP
    
_newArrayLoop:
    ; Will LOOP <ARRAYSIZE> times to find the amount of times a number is on array.

    MOV     eax, [esi]      ; move current position to eax
    CMP     eax, edx
    JE      _increaseCounter

    INC     edx
    MOV     ebx, 0
    ADD     edi, 4
    MOV     [edi], ebx
    JMP     _newArrayLoop

_increaseCounter:
    ; if the eax = edx, counter + 1, and ADD it to currnet countArray position.

    INC     ebx
    MOV     [edi], ebx
    ADD     esi, 4

_ending:
    ;no action taken

    LOOP    _newArrayLoop

    ; Restore used registers
    POPAD
    POP		ebp

    RET		8			    ; De-reference 4 + 4 = 8 bytes
countList ENDP

; ---------------------------------------------------------------------------------
; Name: displayList
;
; Displays a message based on a message passed and a corresponding list also passed. 
; It uses PUSHAD/POPAD to preserve all registers.
;
; Receives: passed message and randArray as a refence. It uses global ARRAYSIZE.
;
; ---------------------------------------------------------------------------------
displayList PROC
    ; Stack Frame Setup. 
    PUSH	ebp			    ;  Build Stack Frame
    MOV		ebp, esp        ; Base Pointer
    PUSHAD				    ; Preserve all registers.
    
    ; pass variables
    MOV		ebx, 0                    
    MOV		edi, [ebp + 8]           
    MOV		ecx, [ebp + 16]

    ; Print message for the associated array.
    MOV		edx, [ebp + 12] 
    CALL	WriteString
    CALL	crlf

_displayLoop:
    ; Loop for displaying array.

    ; Spacing for numbers.
    MOV		eax, [edi] 
    CMP     eax, 9          
    JG      _continueLoop

    ; IF number is under 10, add 0 to make it a 2 digit (for looks only).
    MOV     al, "0"                    
    CALL	WriteChar

_continueLoop:
    ; Display the number.
    MOV		eax, [edi]          
    CALL	WriteDec

    ; Display an empty space.
    MOV     al, " "                    
    CALL	WriteChar

    ; Counter for LOOP.
    DEC		ecx 
    CMP		ecx, 0
    JE		_ending
    INC		ebx                
    CMP		ebx, 20
    JE		_newLine
    ADD		edi, 4              
    JMP     _displayLoop
    
_newLine:
    ; Creates a new line once there's 20 numbers in a line.

    CALL	crlf
    ADD		edi, 4
    MOV		ebx, 0              
    JMP		_displayLoop

_ending:
    ; No action taken.

    CALL	crlf
    CALL	crlf
        
    ; Restore used registers
    POPAD
    POP		ebp

    RET		12			    ; De-reference 4 + 4 + 4= 12 bytes
displayList ENDP

; ---------------------------------------------------------------------------------
; Name: farewell
;
; Displays a farewell message for the user and states that the program has ended.
; ---------------------------------------------------------------------------------
farewell PROC
    ; Stack Frame Setup. 
    PUSH	ebp				;  Build Stack Frame
    MOV		ebp, esp		; Base Pointer
    PUSHAD					; Preserve all registers.

    ; pass variables
    MOV		edx, [ebp + 8]
    CALL	WriteString	
    CALL	Crlf

    ; Restore used registers
    POPAD
    POP		ebp

    RET	    4					; De-reference 4 bytes
farewell ENDP

END main