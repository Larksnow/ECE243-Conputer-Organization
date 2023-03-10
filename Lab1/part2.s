.global _start
_start:
MOV R4, #RESULT // R4 points to result location
LDR R2, [R4, #4] // R2 holds number of elements in the list
MOV R3, #NUMBERS // R3 points to the list of integers
LDR R0, [R3] // R0 holds the largest number so far
LOOP: 
SUBS R2, #1 // decrement the loop counter
BEQ DONE // if result is equal to 0, branch
ADD R3, #4
LDR R1, [R3] // get the next number
CMP R0, R1 // check if larger number found
BGE LOOP
MOV R0, R1 // update the largest number
B LOOP
DONE: STR R0, [R4] // store largest number into result location
END: B END
RESULT: .word 0
N: .word 7 // number of entries in the list
NUMBERS: .word 4, 5, 3, 6 // the data
.word 1, 8, 2
.end
	
	