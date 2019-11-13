%INCLUDE "winAPI.inc"		;;Declare external procedure {winapi}
%INCLUDE "Console1.mac"		;;Macro definition

SEGMENT .DATA use32
Title   	db "Calculator-Ardacandra S.-18532",0 

msg1 		db 13,10,13,10,"Masukan operand 1		:",0
msg1_len 	dd $-msg1
msg2 		db 13,10,"Masukan operand 2		:",0
msg2_len 	dd $-msg2
msg3 		db 13,10,"Masukan operator(+,-,*,/)	:",0
msg3_len 	dd $-msg3
msg4		db 13,10,"Hasil				:",0
msg4_len	dd $-msg4
msg5		db 13,10,"Sisa				:",0
msg5_len	dd $-msg5
msg6		db 13,10,"Tipe input salah, tolong masukan lagi.",0
msg6_len	dd $-msg6
msg7		db 13,10,"Hasil				: -",0		;;untuk pengurangan yang hasilnya negatif
msg7_len	dd $-msg7

buff		resb 255
buff_len	dd 255

strhasil	db '      ',0
str_len		db 6   


SEGMENT .BSS  use32
hStdOut		resd 1 
hStdIn		resd 1 
nBytes		resd 1
iBytes		resd 1
Bil1		resd 1
Bil2		resd 1
Hasil		resd 1
Sisa		resd 1


SEGMENT .CODE use32
..start:

BuatConsole 	Title, hStdOut, hStdIn

call ResetHasil							;; untuk mencegah bug
;;-------------------------------------------------------------------------
InputBil1:							;; input bilangan 1
TampilkanText	hStdOut, msg1, msg1_len, nBytes
BacaText	hStdIn, buff, buff_len, iBytes

cmp dword [iBytes],2    					;; if just Enter (2 char) then Exit
je  exit

call CheckAngka1						;; check apakah input angka atau bukan

call Str2Bil
mov  [Bil1], eax
;;-------------------------------------------------------------------------
InputBil2:							;; input bilangan 2
TampilkanText	hStdOut, msg2, msg2_len, nBytes
BacaText	hStdIn, buff, buff_len, iBytes

call CheckAngka2

call Str2Bil
mov  [Bil2], eax
;;-------------------------------------------------------------------------
InputOp:							;;input operator
TampilkanText	hStdOut, msg3,msg3_len, nBytes
BacaText	hStdIn, buff, buff_len, iBytes

call Operation
mov [Hasil], eax

call Numeric2Str						; CONVERT TO STRING
;;-------------------------------------------------------------------------
TampilkanText	hStdOut, msg4, msg4_len, nBytes
TampilkanText	hStdOut, strhasil, str_len, nBytes		; DISPLAY RESULT

jmp ..start

exit: TutupConsole
	
ret

;=================================================================================================
; CONVERT string(buff) to NUMERIC  result in register EAX 
;-------------------------------------------------------------------------------------
Str2Bil:
        xor eax,eax			;set hasil = 0
        mov esi, 10			;pengali 10
        mov ebx, buff
	mov ecx, [iBytes]
	sub ecx, 2
	xor edx,edx
    Loopbil:
        mul esi 			;hasil sebelumnya * 10
        mov dl, byte [ebx]
        sub dl,30h 			;ubah ke 0-9
        add eax,edx 			;tambahkan dg digit terakhir 
        inc ebx
        loop Loopbil
    
ret

; CONVERT Numeric (EAX) TO STRING (strhasil) 
;-------------------------------------------------------------------------------------
Numeric2Str: 

	mov ebx, strhasil	;; hasil konversi disimpan di strhasil  
 
 loop1:				
	inc ebx			;; ebx digunakan sebagai pointer ke strhasil
	cmp byte[ebx],0		;; diposisikan pada akhir string strhasil 
	jne loop1		

	dec ebx

	mov si,10	      		
 loop2:				
	xor edx, edx		;; edx di-nolkan untuk menampung sisa bagi
	div si			;; dilakukan pembagian 10 berulang
	add dl, '0'        	;; sisa bagi pada edx (dl) di ubah ke character
	mov [ebx], dl		;; simpan ke strhasil dari belakang ke depan
	dec ebx			;; majukan pointer
	or  eax,eax		;; test apakah yang dibagi sudah nol
	jnz loop2 		;; selesai perulangan jika yang dibagi sdh nol   
ret

; Operation depending on operator
;-------------------------------------------------------------------------------------
Operation:
	mov ebx, dword buff
	mov ecx, [iBytes]					
	cmp ecx, 3						;; input yang valid hanya 3 byte(2 byte enter, 1 byte operand)
	jne invalid	

	cmp byte [ebx], 43
	je tambah
	cmp byte [ebx], 45
	je kurang
	cmp byte [ebx], 42
	je kali
	cmp byte [ebx], 47
	je bagi
	jmp invalid						;; kalau inputnya tidak valid
 invalid:
	TampilkanText	hStdOut, msg6, msg6_len, nBytes		;;menampilkan kalimat error
	jmp InputOp
 tambah:
	mov eax, [Bil1]
	add eax, [Bil2]
	jmp stop
 kurang:
	mov eax, [Bil1]
	cmp dword[Bil2], eax
	jg negatif						;; bila bilangan2>bilangan1, maka hasil negatif
	sub eax, [Bil2]
	jmp stop
 negatif:
	mov eax, [Bil2]
	sub eax, [Bil1]

	call Numeric2Str					; CONVERT TO STRING

	TampilkanText	hStdOut, msg7, msg7_len, nBytes		;;menampilkan hasil pengurangan negatif
	TampilkanText	hStdOut, strhasil, str_len, nBytes
	jmp ..start
 kali:
	mov eax, [Bil1]
	mul dword [Bil2]
	jmp stop
 bagi:
	mov eax, [Bil1]
	xor edx, edx						;; mengkosongkan edx untuk division
	div dword [Bil2]
	mov [Sisa], edx
								;; untuk pembagian, ada display khusus karena ada sisanya 
	call Numeric2Str					; CONVERT TO STRING

	TampilkanText	hStdOut, msg4, msg4_len, nBytes		;;menampilkan hasil pembagian
	TampilkanText	hStdOut, strhasil, str_len, nBytes
	
	mov eax,[Sisa]		
	
	call ResetHasil
	call Numeric2Str

	TampilkanText	hStdOut, msg5, msg5_len, nBytes		;;menampilkan sisa pembagian
	TampilkanText	hStdOut, strhasil, str_len, nBytes
	jmp ..start

 stop:
ret

; Reset contents of strhasil
;-------------------------------------------------------------------------------------
ResetHasil :
	mov ECX, 6
	mov EBX, strhasil
	reset :
	 mov byte[EBX], 32					;; ganti semua isi strhasil dengan spasi kosong
	 inc EBX
	 loop reset
	mov byte[EBX], 0
ret

; Check apakah input operands angka atau bukan
;-------------------------------------------------------------------------------------
CheckAngka1:
	mov ebx, dword buff
	mov ecx, [iBytes]
	sub ecx, 2						;;menghilangkan enter
	jmp loopA
 error1:
	TampilkanText	hStdOut, msg6, msg6_len, nBytes		;;menampilkan kalimat error
	jmp InputBil1
 loopA:
	cmp byte[ebx], 48
	jl error1
	cmp byte[ebx], 57
	jg error1
	inc ebx
	loop loopA
	
ret

CheckAngka2:
	mov ebx, dword buff
	mov ecx, [iBytes]
	sub ecx, 2						;;menghilangkan enter
	jmp loopB
 error2:
	TampilkanText	hStdOut, msg6, msg6_len, nBytes		;;menampilkan kalimat error
	jmp InputBil2
	
 loopB:
	cmp byte[ebx], 48
	jl error2
	cmp byte[ebx], 57
	jg error2
	inc ebx
	loop loopB
	
ret