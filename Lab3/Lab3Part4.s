.global _start
.equ  KEY_BASE, 0xFF20005c
.equ  HEX_BASE, 0xFF200020
.equ  CONTROL_BASE, 0xFFFEC600
_start:
		  LDR R1, =KEY_BASE			//set R1 to base key port
		  LDR R4, =HEX_BASE			//set R4 to base hex port
		  MOV R0, #0
COUNTER:  ADD R0, #1				//count up to 5999
          BL DISPLAY
		  LDR R5,=5999
		  CMP R0, R5
		  BEQ RESET					//delay 0.01s
		  B  DO_DELAY
BACK:	  LDR R1, =KEY_BASE			//check for key pressed
		  LDR R2, [R1]
		  CMP R2,#0
		  BNE CHECKSTOP
		  B COUNTER
RESET:	  MOV R0, #0				//reset to 0 after reaching 5999
		  B COUNTER
DO_DELAY:	  PUSH {R1}				//delay
		  PUSH {R3}
		  LDR R1, =CONTROL_BASE
		  LDR R3, =1999999
		  STR R3, [R1]
		  mov R3, #3
		  STR R3, [R1, #8]
		  
TEST:	  LDR R3, [R1, #12]			//check for interruption
		  CMP R3, #1
		  Bne TEST
		  MOV R3, #1
		  STR R3, [R1, #12]
		  POP {R1}
		  POP {R3}
		  B BACK
		  
		  
CHECKSTOP: LDR R1, =KEY_BASE		//check for key pressed
		   MOV R2, #15
		   STR R2, [R1]
WAIT:	   LDR R2, [R1]
		   CMP R2, #0
		   BEQ WAIT
		   MOV R2, #15
		   STR R2, [R1]
		   B COUNTER

DISPLAY:	push {R1}
			push {R3}
			push {R2}
			push {R0}
			MOV  R2, #BIT_CODES
			MOV R3,#0
			MOV R1,#0

DIVIDE:		CMP		R0, #1000			//divide and display each time
			BLT		STRTHOUSAND
			SUB		R0, #1000
			ADD		R1, #1
			B DIVIDE
STRTHOUSAND:LDRB R1,[R2,R1]
            LSL  R1,#24
			ORR  R3,R1
			MOV  R1,#0
DIVIDEHUNDRED:		
			CMP     R0, #100
			BLT		STRHUNDRED
			SUB		R0, #100
			ADD		R1, #1
			B DIVIDEHUNDRED
STRHUNDRED: LDRB R1,[R2,R1]
            LSL  R1,#16
			ORR  R3,R1
			MOV  R1,#0
DIVIDETEN:  CMP     R0, #10
			BLT		STRREST
			SUB		R0, #10
			ADD		R1, #1
			B DIVIDETEN
STRREST:    LDRB R1,[R2,R1]
            LDRB R0,[R2,R0]
			LSL  R1,#8
			ORR  R3,R1
			ORR  R3,R0
			STR  R3, [R4]
			pop {R0}
			pop {R2}
			POP {R1}
			POP {R3}
            MOV     PC, LR              

BIT_CODES:  .byte   0b00111111, 0b00000110, 0b01011011, 0b01001111, 0b01100110
            .byte   0b01101101, 0b01111101, 0b00000111, 0b01111111, 0b01100111
            .skip   2      // pad with 2 bytes to maintain word alignment



	