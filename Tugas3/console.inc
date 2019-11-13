extern GetStdHandle 
extern WriteFile 
extern ReadFile 
extern AllocConsole 
extern FreeConsole 
extern SetConsoleTitleA 
extern SetConsoleCursorPosition 
extern Sleep 
extern ExitProcess 
EXTERN MessageBoxA

import GetStdHandle kernel32.dll 
import WriteFile kernel32.dll 
import ReadFile kernel32.dll 
import AllocConsole kernel32.dll 
import FreeConsole kernel32.dll 
import SetConsoleTitleA kernel32.dll 
import SetConsoleCursorPosition kernel32.dll 
import Sleep kernel32.dll 
import ExitProcess kernel32.dll
IMPORT MessageBoxA user32.dll 

%macro initconsole 3
	
	call [AllocConsole] 

	push dword %1 
	call [SetConsoleTitleA] 

	push dword -11 				;; STD_OUTPUT_HANDLE = -11.
	call [GetStdHandle] 
	mov dword [%2], eax 

	push dword -10				;; STD_INPUT_HANDLE = -10 
	call [GetStdHandle] 
	mov dword [%3], eax 

%endmacro

%macro quitconsole 0
	call [FreeConsole] 
	xor eax, eax 
	push eax 
	call [ExitProcess]
%endmacro

%macro delay 1
	push dword %1 				;; delay %1/1000 second 
	call [Sleep] 
%endmacro

%macro display_text 4
	mov eax, %2			
	sub eax, %1 		
	dec eax 			
	mov dword [%2], eax 

	push dword 0 				;; parameter ke 5 dari WriteFile() adalah 0 
	push dword %3				;; parameter ke 4 jumlah byte yg sesungguhnya tertulis
	push dword [%2] 			;; parameter ke 3 panjang string
	push dword %1				;; parameter ke 2 string yang akan ditampilkan 
	push dword [%4] 			;; parameter ke 1 handle stdout
	call [WriteFile] 
%endmacro
