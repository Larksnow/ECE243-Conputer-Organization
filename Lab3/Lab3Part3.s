.global _start
.equ  KEY_BASE, 0xFF20005c		
.equ  HEX_BASE, 0xFF200020
.equ  CONTROL_BASE, 0xFFFEC600
_start:
		  LDR R1, =KEY_BASE		//set R1 to base of key
		  LDR R4, =HEX_BASE		//set R4 to base of hex
		  MOV R0, #0
COUNTER:  ADD R0, #1			//count up to 99 renew to 0 if 99 is reached
          BL DISPLAY
		  CMP R0, #99		
		  BEQ RESET
		  B  DO_DELAY			//branch to ARM A9 private counter
BACK:	  LDR R1, =KEY_BASE
		  LDR R2, [R1]			//check for edge capture
		  CMP R2,#0
		  BNE CHECKSTOP
		  B COUNTER
RESET:	  MOV R0, #0
		  B COUNTER
DO_DELAY:	  PUSH {R1}			//ARM A9 private counter
		  PUSH {R3}
		  LDR R1, =CONTROL_BASE
		  LDR R3, =49999999
		  STR R3, [R1]
		  mov R3, #3
		  STR R3, [R1, #8]		//enable and A
		  
TEST:	  LDR R3, [R1, #12]		//check for interrupter
		  CMP R3, #1
		  Bne TEST
		  MOV R3, #1			//reset interrupter
		  STR R3, [R1, #12]
		  POP {R1}
		  POP {R3}
		  B BACK
		  
		  
CHECKSTOP: LDR R1, =KEY_BASE		//check for any key pressed
		   MOV R2, #15
		   STR R2, [R1]
WAIT:	   LDR R2, [R1]
		   CMP R2, #0
		   BEQ WAIT
		   MOV R2, #15				//reset edge 
		   STR R2, [R1]
		   B COUNTER

DISPLAY:	MOV     R3, #BIT_CODES
			push {R2}
			push {R0}
			MOV R2,#0

DIVIDE:		CMP		R0, #10
			BLT		DIVIDEND
			SUB		R0, #10
			ADD		R2, #1
			B DIVIDE
DIVIDEND:	
            LDRB    R0, [R3,R0] // load the bit pattern (to be returned)
			LDRB	R2, [R3,R2]
			LSL		R2, #8
			ORR		R0, R2
			STR 	R0, [R4]
			pop {R0}
			pop {R2}
            MOV     PC, LR              

BIT_CODES:  .byte   0b00111111, 0b00000110, 0b01011011, 0b01001111, 0b01100110
            .byte   0b01101101, 0b01111101, 0b00000111, 0b01111111, 0b01100111
            .skip   2      // pad with 2 bytes to maintain word alignment



	