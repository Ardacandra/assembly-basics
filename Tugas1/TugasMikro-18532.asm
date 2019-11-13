%INCLUDE "winAPI.inc"		;;Declare external procedure {winapi} in file winAPI.inc
%INCLUDE "Console.mac"		;;Declare MACRO in file Console.mac

SEGMENT .DATA use32
Title   	db "Tugas NASM-Ardacandra Subiantoro",0 

msg1 		db 13,10,"WRITE TEXT(ENTER TO QUIT)	:",0
msg1_len 	dd $-msg1
msg2 		db 13,10,"CONVERT TO UPCASE 		:",0
msg2_len 	dd $-msg2
msg3		db 13,10,"REVERSED 			:",0
msg3_len	dd $-msg3
msg4		db 13,10,"NUMBER OF CHARACTER 		:",0
msg4_len	dd $-msg4
msg5		db 13,10,"NUMBER OF WORDS 		:",0
msg5_len	dd $-msg5

buff		resb 255
buff_len	dd 255

str_char	db '      ',0
str_word	db '      ',0
str_len		db 6

SEGMENT .BSS  use32
hStdOut		resd 1 
hStdIn		resd 1 
nBytes		resd 1
iBytes		resd 1

SEGMENT .CODE use32

..start:

CALL ResetStrChar
CALL ResetStrWord	;; kalau tidak di reset jadi ada bug

BuatConsole 	Title, hStdOut, hStdIn

TampilkanText	hStdOut, msg1, msg1_len, nBytes
BacaText	hStdIn, buff, buff_len, iBytes

CMP dword [iBytes],2    ;; Jika hanya ditekan Enter (2 char) maka Exit
JE  exit

CALL UbahKeBesar

TampilkanText	hStdOut, msg2, msg2_len, nBytes
TampilkanText	hStdOut, buff, iBytes, nBytes

CALL Reverse

TampilkanText	hStdOut, msg3, msg3_len, nBytes
TampilkanText	hStdOut, buff, iBytes, nBytes

CALL GetNumberOfChar

TampilkanText	hStdOut, msg4, msg4_len, nBytes
TampilkanText	hStdOut, str_char, str_len, nBytes

CALL GetNumberOfWords

TampilkanText	hStdOut, msg5, msg5_len, nBytes
TampilkanText	hStdOut, str_word, str_len, nBytes


JMP ..start

exit: 
TutupConsole
	
RET

UbahKeBesar:

	MOV ECX, [iBytes]	;; iBytes menyimpan panjang string yang dituliskan, termasuk Enter (2 bytes: 13,10)
	SUB ECX, 2
	MOV EBX, dword buff

	ups:
	 CMP byte [EBX],97
	 JL skip
	 CMP byte [EBX],122
	 JG skip
	 SUB byte [EBX],32
	 INC EBX
	 loop ups
	 RET

	skip:
	 INC EBX
	 DEC ECX
	 JNZ ups
	 RET

Reverse:
	MOV ECX, [iBytes]
	SUB ECX, 2
	MOV EBX, dword buff
	
	push:
	 MOV DX, word[EBX]
	 MOV DH, 0		;; karena PUSH & POP harus word, jadi DH nya di 0 in
	 PUSH DX
	 INC EBX
	 loop push

	MOV ECX, [iBytes]
	SUB ECX, 2	
	MOV EBX, dword buff
	
	pop:
	 POP DX
	 MOV DH, 0
	 MOV word[EBX], DX
	 INC EBX
	 loop pop
	RET

GetNumberOfWords:
	 MOV ECX, [iBytes]
	 SUB ECX, 2
	 MOV EBX, dword buff
	 XOR EDX, EDX

 	loopA:			;;menghitung jumlah spasi
	 CMP byte [EBX], 32
	 JNE bukanSpasi
	 INC EBX
	 LOOP loopA		
	 JMP char2stringWords		;;kalau spasi semua, berarti jumlah kata 0

 	bukanSpasi :
	 INC EBX
	 DEC ECX
	 JZ IncWord
	 CMP byte [EBX], 32
	 JNE bukanSpasi
	 INC EDX
	 JMP loopA

	IncWord:
	 INC EDX			;;jumlah kata = jumlah spasi+1
 
 	char2stringWords:		;;mengubah ke string
	 MOV EBX, str_word

 	 loopB:						
	  INC EBX	
	  CMP byte[EBX],0	
	  JNE loopB		
	  DEC EBX	
	
	 MOV EAX, EDX			
	 MOV SI,10
	
 	 loopC:				
	  XOR EDX, EDX		
	  DIV SI			
	  ADD DL, '0'      	
	  MOV [EBX], DL		
	  DEC EBX				
	  OR  EAX,EAX			
	  JNZ loopC 			
	 RET

GetNumberOfChar:
	 MOV ECX, [iBytes]
	 SUB ECX, 2
	 MOV EBX, dword buff
	 XOR EDX, EDX

 	l1:			;;menghitung jumlah spasi
	 CMP byte [EBX], 32
	 JE adaSpasi
	 INC EBX
	 LOOP l1
	 JMP char2string

 	adaSpasi:
	 INC EDX
	 INC EBX
	 DEC ECX
	 JNZ l1
	
 	char2string:		;;mengubah ke string
	 MOV EBX, str_char
 	 l2:						
	  INC EBX
	  CMP byte [EBX],0	
	  JNE l2
	  DEC EBX

	 MOV EAX, [iBytes]
	 SUB EAX, EDX		;; mengurangi iBytes dengan jumlah spasi
	 SUB EAX, 2	
	 MOV SI,10

 	 l3:				
	  XOR EDX, EDX	
	  DIV SI		
	  ADD DL, '0'	
	  MOV [EBX], DL	
	  DEC EBX			
	  OR EAX, EAX	
	  JNZ l3 
	 stop:		
	 RET

ResetStrChar :
	MOV ECX, 6
	MOV EBX, str_char
	reset :
	 MOV byte[EBX], 32
	 INC EBX
	 LOOP reset
	MOV byte[EBX], 0
	RET

ResetStrWord :
	MOV ECX, 6
	MOV EBX, str_word
	reset1 :
	 MOV byte[EBX], 32
	 INC EBX
	 LOOP reset1
	MOV byte[EBX], 0
	RET

