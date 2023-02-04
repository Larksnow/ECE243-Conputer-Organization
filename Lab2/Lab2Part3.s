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

LOOP:	  BL      ONES			//find the biggest one in one word
          CMP     R0, #0		//if all 0, terminate
		  BEQ     END			
		  CMP     R0,R5			//compare with the previous value and update the largest
		  BLT     NEXT1
		  MOV     R5,R0
NEXT1:	  BL      ZEROS			//find the biggest zero in one word
		  CMP     R0,R6			//compare with the previous value and update the largest
		  BLT     NEXT2		
		  MOV     R6,R0
NEXT2:	  BL      ALTERNATE		//find the biggest alternate in one word
          CMP     R0,R7			//compare with previous value and update
		  ADD     R3,#4			//change to the next word
		  BLT     LOOP
		  MOV     R7,R0
		  B       LOOP

END:      B       END             

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
          MVN     R1, R1		 //perform bitwise not operation, switch 1 and 0 and count 1
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
          EOR     R1,R1,R2 		//perform XOR on aaaaaaaa
		  LDR     R2, [R4,#4]
		  EOR     R8,R8,R2		//perform XOR on 5555555
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
          CMP     R0,R9		//choose the larger value between resulted from 555555 and aaaaa
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
