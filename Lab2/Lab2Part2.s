/* Program that counts consecutive 1's */

          .text                   // executable code follows
          .global _start                  
_start:   
          MOV     R1, #0	//initialize R0 to 0
          MOV     R2, #0	//initialize R2 to 0
		  MOV     R3, #TEST_NUM   // load the data word ...

		  MOV     R5, #0          //R5 holds the largest result, initialize to 0
LOOP:	  BL      ONES		//count the number of 1s in one word
          CMP     R0, #0	//if there is no consecutive 0, meaning terminal
		  BEQ     END
		  ADD     R3, #4	//switch to the next word
		  CMP     R0,R5		//update with the bigger value, loop to the next word
		  BLT     LOOP
		  MOV     R5,R0
		  B       LOOP
END:      B       END             

ONES:     MOV     R0, #0          // R0 will hold the result
          LDR     R1, [R3]   // load the data word into R1
SUBLOOP:  CMP     R1, #0          // loop until the data contains no more 1's
          BEQ     ONES_END             
          LSR     R2, R1, #1      // perform SHIFT, followed by AND
          AND     R1, R1, R2      
          ADD     R0, #1          // count the string length so far
          B       SUBLOOP            
ONES_END: MOV     PC,LR

TEST_NUM: .word   0x102da003
          .word   0x103fe01f
		  .word   0x103fe00f
		  .word   0x103ee036
		  .word   0x135be0cf
		  .word   0x137ae2c4
		  .word   0x17aeffc2
		  .word   0x15a6f129
		  .word   0x1dfefe2e
		  .word   0x14a6cd2d
		  .word   0x00000000
          .end                            
