/* Program that counts consecutive 1's */

          .text                   // executable code follows
          .global _start                  
_start:   
          MOV     R1, #0          // R1 always holds value in words
          MOV     R2, #0          // R2 holds value after shifting
		  MOV     R3, #TEST_NUM   // R3 holds word list's address
          MOV     R4, #ALTERNATE_NUM
		  MOV     R5, #0          //R5 holds the largest result of consecutive 1's
          MOV     R6, #0          //R6 holds the largest result of consecutive 0's
		  MOV     R7, #0          //R7 holds the largest result of consecutive alternating

LOOP:	  BL      ONES
          CMP     R0, #0
		  BEQ     DISPLAY
		  CMP     R0,R5
		  BLT     NEXT1
		  MOV     R5,R0
NEXT1:	  BL      ZEROS
		  CMP     R0,R6
		  BLT     NEXT2
		  MOV     R6,R0
NEXT2:	  BL      ALTERNATE
          CMP     R0,R7
		  ADD     R3,#4
		  BLT     LOOP
		  MOV     R7,R0
		  B       LOOP

SEG7_CODE:  MOV     R1, #BIT_CODES  
            ADD     R1, R0         // index into the BIT_CODES "array"
            LDRB    R0, [R1]       // load the bit pattern (to be returned) Load Register Byte
            MOV     PC, LR              

BIT_CODES:  .byte   0b00111111, 0b00000110, 0b01011011, 0b01001111, 0b01100110
            .byte   0b01101101, 0b01111101, 0b00000111, 0b01111111, 0b01100111
            .skip   2      // pad with 2 bytes to maintain word alignment

/* code for Part III (not shown) */

/* Display R5 on HEX1-0, R6 on HEX3-2 and R7 on HEX5-4 */
DISPLAY:    LDR     R8, =0xFF200020 // base address of HEX3-HEX0
            MOV     R0, R5          // display R5 on HEX1-0
            BL      DIVIDE          // ones digit will be in R0; tens
                                    // digit in R1
            MOV     R9, R1          // save the tens digit
            BL      SEG7_CODE       
            MOV     R4, R0          // save bit code
            MOV     R0, R9          // retrieve the tens digit, get bit
                                    // code
            BL      SEG7_CODE       
            LSL     R0, #8	//shift eight to reach HEX1 (logical shift left)
            ORR     R4, R0	//bit wise or operation
            
	    MOV     R0, R6          // display R5 on HEX1-0
            BL      DIVIDE          // ones digit will be in R0; tens
                                    // digit in R1
            MOV     R9, R1          // save the tens digit
            BL      SEG7_CODE       
            LSL     R0, #16	//shift 16
	   ORR     R4, R0          // save bit code
            MOV     R0, R9          // retrieve the tens digit, get bit
                                    // code
            BL      SEG7_CODE       
            LSL     R0, #24	//shift 24
            ORR     R4, R0
			
            STR     R4, [R8]        // display the numbers from R6 and R5
            LDR     R8, =0xFF200030 // base address of HEX5-HEX4
            
			MOV     R0, R7          // display R5 on HEX1-0
            BL      DIVIDE          // ones digit will be in R0; tens
                                    // digit in R1
            MOV     R9, R1          // save the tens digit
            BL      SEG7_CODE       
            MOV     R4, R0          // save bit code
            MOV     R0, R9          // retrieve the tens digit, get bit
                                    // code
            BL      SEG7_CODE       
            LSL     R0, #8
            ORR     R4, R0
            STR     R4, [R8]        // display the number from R7

END:      B       END

DIVIDE:     MOV    R2, #0
CONT:       CMP    R0, #10
            BLT    DIV_END
            SUB    R0, #10
            ADD    R2, #1
            B      CONT
DIV_END:    MOV    R1, R2     // quotient in R1 (remainder in R0)
            MOV    PC, LR
            

ONES:     MOV     R0, #0          // R0 will hold the result
          LDR     R1, [R3]        // load the data word into R1
ONES_LOOP:CMP     R1, #0          // loop until the data contains no more 1's
          BEQ     ONES_END             
          LSR     R2, R1, #1      // perform SHIFt
          AND     R1, R1, R2      
          ADD     R0, #1          // count the string length so far
          B       ONES_LOOP            
ONES_END: MOV     PC,LR


ZEROS:    MOV     R0, #0          // R8 will hold the result
          LDR     R1, [R3]        // load the data word into R1
          MVN     R1, R1
ZEROS_LOOP:
          CMP     R1, #0          // loop until the data contains no more 1's
          BEQ     ZEROS_END             
          LSR     R2, R1, #1      // perform SHIFt
          AND     R1, R1, R2      
          ADD     R0, #1          // count the string length so far
          B       ZEROS_LOOP            
ZEROS_END:MOV     PC,LR


ALTERNATE:    
          MOV     R0, #0          // R0 will hold the result for aaaaaaaa xor
          MOV     R9, #0          // R9 will hold the result for 55555555 xor
		  LDR     R1, [R3]        // load the data word into R1
          MOV     R8, R1          // create a copy of input
		  LDR     R2, [R4]
          EOR     R1,R1,R2 
		  LDR     R2, [R4,#4]
		  EOR     R8,R8,R2
ALTERNATE_LOOP1:
          CMP     R1, #0          // loop until the data contains no more 1's
          BEQ     ALTERNATE_LOOP2            
          LSR     R2, R1, #1      // perform SHIFt
          AND     R1, R1, R2      
          ADD     R0, #1          // count the string length so far
          B       ALTERNATE_LOOP1            
ALTERNATE_LOOP2:
          CMP     R8, #0          // loop until the data contains no more 1's
          BEQ     ALTERNATE_END            
          LSR     R2, R8, #1      // perform SHIFt
          AND     R8, R8, R2      
          ADD     R9, #1          // count the string length so far
          B       ALTERNATE_LOOP2 
ALTERNATE_END:   
          CMP     R0,R9
		  BLT     DECIDE 
          MOV     PC,LR
DECIDE:   MOV     R0,R9
          MOV     PC,LR

ALTERNATE_NUM: .word 0xaaaaaaaa
               .word 0x55555555
TEST_NUM: .word   0x102da003
          .word   0x103fe01f
		  .word   0x103fe00f
		  .word   0x103ee036
		  .word   0x135be0cf
		  .word   0x137ae2c4
		  .word   0x17aeffc2
		  .word   0x15a6f129
		  .word   0x1dfefe2e
		  .word   0x55555555
		  .word   0x00000000
          .end                            
