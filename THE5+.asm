; ATM Program for DOS + LED (Arabic labels included)
; Terminal input/output (INT 21h) + LED output on port 300h (MTS-86C compatible)
CNT3  		EQU    	3FD6H
BPORT3		EQU     3FD2H

CODE        SEGMENT
            ASSUME CS:CODE, DS:CODE
            org 0h
MAIN:
    MOV AX, CS
    MOV DS, AX
    MOV ES, AX

   
	jmp MAIN_LOOP

; User database: 6-digit card + 4-digit password each
DB_TABLE DB '1234561111$'
         DB '2345672222$'
         DB '3456783333$'
         DB '4567894444$'
         DB '5678905555$'
         DB '6789016666$'
         DB '7890127777$'
         DB '8901238888$'
         DB '9012349999$'
         DB '0123450000$'
         DB '1122331212$'
         DB '2233442323$'
         DB '3344553434$'
         DB '4455664545$'
         DB '5566775656$'
         DB '6677886767$'
         DB '7788997878$'
         DB '8899008989$'
         DB '9900119090$'
         DB '0011220101$'

ENTERED_ACC DB 6 DUP(?)
ENTERED_PWD DB 4 DUP(?)

WELCOME_MSG   DB 'ATM Authorization System$'
CARD_PROMPT   DB 0Dh,0Ah,'Enter 6-digit card number: $'
PASS_PROMPT   DB 0Dh,0Ah,'Enter 4-digit password: $'
AUTH_SUCCESS  DB 0Dh,0Ah,'Access Granted$'
AUTH_FAILED   DB 0Dh,0Ah,'Access Denied$'



MAIN_LOOP:
    ; Welcome message
    MOV AH, 09H
    LEA DX, WELCOME_MSG
    INT 21H

    ; Get card
    CALL GET_CARD_NUMBER

    ; Get password
    CALL GET_PASSWORD

    ; Check auth
    CALL AUTHENTICATE_USER
    CMP AL, 1
    JE ACCESS_GRANTED

    ; Access Denied
    MOV AH, 09H
    LEA DX, AUTH_FAILED
    INT 21H
    MOV	SP,4000H
    MOV	AL,90H
    MOV	DX,CNT3
    OUT	DX,AL
	MOV	AL,00H
	MOV	DX,BPORT3
	OUT	DX,AL
    JMP MAIN_LOOP

ACCESS_GRANTED:
    MOV AH, 09H
    LEA DX, AUTH_SUCCESS
    INT 21H
    MOV	SP,4000H
    MOV	AL,90H
    MOV	DX,CNT3
    OUT	DX,AL
	MOV	AL,01H
	MOV	DX,BPORT3
	OUT	DX,AL
		



    JMP MAIN_LOOP


; Read 6-digit card
GET_CARD_NUMBER:
    MOV AH, 09H
    LEA DX, CARD_PROMPT
    INT 21H

    LEA DI, ENTERED_ACC
    MOV CX, 6
CARD_LOOP:
    MOV AH, 01H
    INT 21H
    MOV [DI], AL
    INC DI
    LOOP CARD_LOOP
    RET


; Read 4-digit password (masked)
GET_PASSWORD:
    MOV AH, 09H
    LEA DX, PASS_PROMPT
    INT 21H

    LEA DI, ENTERED_PWD
    MOV CX, 4
PASS_LOOP:
    MOV AH, 01H
    INT 21H
    MOV [DI], AL
    INC DI
    LOOP PASS_LOOP
    RET


; Authenticate input
AUTHENTICATE_USER:
    LEA SI, DB_TABLE
    MOV CX, 20
NEXT_ENTRY:
    PUSH CX 
    PUSH SI
    LEA DI, ENTERED_ACC
    MOV CX, 6
    MOV BX, SI
    REPE CMPSB
    JNE SKIP_ENTRY

    LEA DI, ENTERED_PWD
    MOV CX, 4  
    MOV SI, BX
    ADD SI, 6
    REPE CMPSB
    JNE SKIP_ENTRY

    ; Match success
    MOV AL, 1
    POP SI
    POP CX
    RET

SKIP_ENTRY:
    POP SI
    POP CX 
    ADD SI, 11
    LOOP NEXT_ENTRY
    MOV AL, 0
    RET
CODE ENDS

END MAIN