.global _start
.equ  KEY_BASE, 0xFF200050
.equ  HEX_BASE, 0xFF200020

_start:  ldr r0,=KEY_BASE		// set r0 to base KEY port
	 ldr r4,=HEX_BASE		// set r4 to base of HEX port
	 mov  r2, #0			// first value of HEX output

poll:	ldr r1, [r0]		// load edge capture reg			// 'select' bit for Key2
	    cmp r1,#0			//check which key is pressed down by checking the load register value
		beq	poll			// if no key pressed, do nothing
	    cmp r1,#0x1 		//if key0 is pressed
		beq key0
		cmp r1,#0x2			//if key1 is pressed
		beq key1
		cmp r1,#0x4			//if key2 is pressed
		beq key2
		cmp r1,#0x8			//if key3 is pressed
		beq key3 
back:	b	poll			// go back to poll loop
	
key0: ldr r1, [r0]			//when key 0 is pressed
      cmp r1,#0
      bgt key0				
      mov r2,#0
	  bl  display
      b   back
key1: ldr r1, [r0]			//when key 1 is pressed
      cmp r1,#0
      bgt key1
      cmp r2,#9				//check if 9 is reached
	  beq skip9
	  push {r2}
	  ldr r2,[r4]
	  cmp r2,#0
	  beq skip9
	  pop  {r2}
	  add r2,#1
skip9:bl  display
      b   back
key2: ldr r1, [r0]			//when key2 is pressed
      cmp r1,#0
      bgt key2
      cmp r2,#0				//check when 0 is reached
	  beq skip0
      sub r2,#1
skip0:bl  display	  
      b   back
key3: ldr r1, [r0]			//when key3 is pressed
      cmp r1,#0
      bgt key3
      mov r2,#0
	  str r2,[r4]
      b   back    

display:    MOV     R3, #BIT_CODES  
            push    {R2}
			LDRB    R2, [R3,R2]       // R3 holds bit code for output value
            str     R2, [R4]
			pop     {R2}
			MOV     PC, LR     
			
BIT_CODES:  .byte   0b00111111, 0b00000110, 0b01011011, 0b01001111, 0b01100110
            .byte   0b01101101, 0b01111101, 0b00000111, 0b01111111, 0b01100111
            .skip   2      // pad with 2 bytes to maintain word alignment