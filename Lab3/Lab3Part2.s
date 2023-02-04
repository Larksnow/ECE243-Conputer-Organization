.global _start
.equ  KEY_BASE, 0xFF200050
.equ  HEX_BASE, 0xFF200020
_start:
		  LDR R1, =KEY_BASE		//set R1 to base of key
		  LDR R4, =HEX_BASE		//set R4 to base of Hex
		  MOV R0, #0
COUNTER:  ADD R0, #1			//count up 1 unil 99
          BL DISPLAY
		  CMP R0, #99
		  BEQ RESET				//renew once 99
		  B  DO_DELAY
BACK:	  LDR R1, =KEY_BASE
		  LDR R2, [R1,#0xC]		//check for edge if pressed
		  CMP R2,#0
		  BNE CHECKSTOP
		  B COUNTER
RESET:	  MOV R0, #0
		  B COUNTER
DO_DELAY: LDR R7, = 500000		//counter delay
SUB_LOOP: SUBS R7, R7, #1
		  BNE SUB_LOOP
		  B	  BACK
CHECKSTOP: MOV R2, #15		//renew everytime
		   STR R2, [R1,#0xC]
WAIT:	   LDR R2, [R1,#0xC]
		   CMP R2, #0		//branch if pressed again
		   BEQ WAIT
		   MOV R2, #15		//renew again
		   STR R2, [R1,#0xC]
		   B BACK

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



	