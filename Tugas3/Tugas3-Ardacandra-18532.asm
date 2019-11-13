%include "console.inc"

judul		db "Tugas 3-Ardacandra Subiantoro-18532", 0 
teks1   	db 13,10,"Masukan angka<0 angka terakhir> : ",13,10,0 
pteks1		dd $-teks1 
teks2		db 13,10,"Masukan lagi?<ketik y bila iya>",0
pteks2		dd $-teks2
teks3		db "Invalid input.",13,10,0
pteks3		dd $-teks3
strhasil	db '      ',0
str_len		dd 6	

mbtitle 	db 'Hasil Penjumlahan',0

buff		resb 16
buff_len	dd 16

section .bss 	; Initialisasi variabel: hStdOut, hStdIn, nBytes, iBytes dg type double-word

hStdOut         resd 1 
hStdIn          resd 1 
nBytes          resd 1
iBytes          resd 1
hasil		resd 1

;;================================================================================================
segment .code use32
..start:	

 initconsole judul, hStdOut, hStdIn				; CREATE CONSOLE
 mov dword[hasil], 0						; RESET HASIL PERTAMBAHAN
 call ResetHasil						; RESET STRING STRHASIL MENJADI SPASI KOSONG 
 display_text teks1, pteks1, nBytes, hStdOut			; DISPLAY TEXT MESSAGE

 inputLoop :
 call read_text							; READ TEXT FROM KEYBOARD
 call checkBil							; CEK APAKAH 0 ATAU INVALID INPUT
 call Str2Bil							; CONVERT TO NUMBER
 add [hasil], eax						; ADD NUMBER TO HASIL
 jmp inputLoop

 displayHasil:
 mov eax, [hasil]
 call Numeric2Str						; CONVERT FROM NUMBER TO STRING
 call mbox							; DISPLAY MESSAGE BOX

 display_text teks2, pteks2, nBytes, hStdOut			; DISPLAY TEXT MESSAGE
 call read_text							; READ TEXT FROM KEYBOARD
 mov ebx, dword buff
 cmp byte[ebx], 121						; CEK JIKA INPUT y, ULANG KE START
 je ..start 

 push dword 0
 call [ExitProcess]
 leave
ret


;;================================================================================================
segment .data use32

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

; CHECK APAKAH INPUT 0 ATAU INVALID INPUT
;-------------------------------------------------------------------------------------
checkBil: 
 	mov ebx, dword buff
	mov ecx, [iBytes]
	sub ecx, 2						;;menghilangkan enter
	cmp byte[ebx], 48
	je displayHasil						;;jika awalnya 0, maka hasil ditampilkan
	jmp loop3

 invalidInput:
	display_text	teks3, pteks3, nBytes, hStdOut		;;menampilkan kalimat error
	jmp inputLoop
 loop3:								;;cek apakah yang di input angka atau bukan
	cmp byte[ebx], 48
	jl invalidInput
	cmp byte[ebx], 57
	jg invalidInput
	inc ebx
	loop loop3	
ret

; UNTUK MENAMPILKAN MESSAGE BOX
;-------------------------------------------------------------------------------------
mbox:		

	push dword 30h			; tombol Button
 	push dword mbtitle		; judul windows
 	push dword strhasil  		; Pesan yg ditampilkan, diakhiri 0 (null)
 	push dword 0			; owner windows dari msgbox, atau NULL (tdk punya owner)

 	call [MessageBoxA]
ret

; UNTUK MEMBACA TEXT
;-------------------------------------------------------------------------------------
read_text:
					;; membaca string dari Console(keyboard) dg ReadFile
push dword 0 				;; parameter ke 5 dari ReadFile() adalah 0 
push dword iBytes 			;; parameter ke 4 jumlah byte yg sesungguhnya terbaca (TERMASUK ENTER)
push dword [buff_len] 			;; parameter ke 3 panjang buffer yg disediakan
push dword buff 			;; parameter ke 2 buffer untuk menyimpan string yg dibaca 
push dword [hStdIn] 			;; parameter ke 1 handle stdin
call [ReadFile] 			
ret

; Reset contents of strhasil
;-------------------------------------------------------------------------------------
ResetHasil :
	mov ECX, 6
	mov EBX, strhasil
	reset :
	 mov byte[EBX], 32		;; ganti semua isi strhasil dengan spasi kosong
	 inc EBX
	 loop reset
	mov byte[EBX], 0
ret

 