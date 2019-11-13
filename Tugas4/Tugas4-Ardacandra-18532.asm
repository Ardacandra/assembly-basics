%include "nagoa.inc"

extern GetModuleHandleA
extern GetCommandLineA
extern ExitProcess
extern MessageBoxA
extern LoadIconA
extern LoadCursorA
extern RegisterClassExA
extern CreateWindowExA
extern ShowWindow
extern GetWindowTextA
extern SetWindowTextA
extern SetFocus
extern UpdateWindow
extern GetMessageA
extern SendMessageA
extern TranslateMessage
extern DispatchMessageA
extern PostQuitMessage
extern DefWindowProcA
extern BeginPaint
extern DrawTextA
extern EndPaint

;; Import the Win32 API functions.
import GetModuleHandleA kernel32.dll
import GetCommandLineA kernel32.dll
import ExitProcess kernel32.dll
import MessageBoxA user32.dll
import LoadIconA user32.dll
import LoadCursorA user32.dll
import RegisterClassExA user32.dll
import CreateWindowExA user32.dll
import GetWindowTextA user32.dll
import SetWindowTextA user32.dll
import SetFocus user32.dll
import ShowWindow user32.dll
import UpdateWindow user32.dll
import GetMessageA user32.dll
import SendMessageA user32.dll
import TranslateMessage user32.dll
import DispatchMessageA user32.dll
import PostQuitMessage user32.dll
import DefWindowProcA user32.dll
import BeginPaint user32.dll
import DrawTextA user32.dll
import EndPaint user32.dll
def WinMain
def WinProc

[segment .data USE32]
Instance        dd 0
CmdLine         dd 0
hwndButton      dd 0
hwndEdit1       dd 0
hwndEdit2       dd 0
nhasil1		dd 0
nhasil2		dd 0
nhasil3		dd 0
nhasil4		dd 0

ClassName       db "Calculator",0
AppName         db "Kalkulator",0

ButtonClassName db "button",0
ButtonText1     db "+",0
ButtonText2     db "-",0
ButtonText3	db "*",0
ButtonText4	db "/",0
EditClassName   db "edit",0					;Definisi Class EditBox

Teks_mbox		db "HASILNYA",0
Test_string		db "0000",0
IDM_HELLO       equ 1
IDM_CLEAR       equ 2
IDM_GETTEXT1    equ 3
IDM_GETTEXT2    equ 5
IDM_GETTEXT3	equ 6
IDM_GETTEXT4	equ 7

IDM_EXIT        equ 4


ButtonID1       equ 1111
ButtonID2       equ 4444
ButtonID3	equ 5555
ButtonID4	equ 6666
EditID1         equ 2222
EditID2         equ 3333

buffer1          resb 512
buffer2		 resb 512
shasil1          resb 512
shasil2          resb 512
shasil3		 resb 512
shasil4		 resb 512
   
[segment .code USE32]
..start:
    call GetModuleHandleA, NULL
	mov dword[Instance], eax
	
	call GetCommandLineA, NULL
	mov dword[CmdLine], eax
	call WinMain, [Instance], NULL, eax, SW_SHOWDEFAULT
	call ExitProcess, NULL


proc WinMain, hInstance, hPrevInstance, lpCmdLine, nCmdShow

    stack wc,WNDCLASSEX_size
    stack msg, MSG_size
    stack hwnd, 4

	mov dword[wc+WNDCLASSEX.cbSize], WNDCLASSEX_size
	mov dword[wc+WNDCLASSEX.style], CS_VREDRAW | CS_HREDRAW
	mov dword[wc+WNDCLASSEX.lpfnWndProc], WinProc           ; prosedure yg dijalankan saat windows utama aktif
	mov dword[wc+WNDCLASSEX.cbClsExtra], NULL
	mov dword[wc+WNDCLASSEX.cbWndExtra], NULL
	m2m dword[wc+WNDCLASSEX.hInstance], [Instance]
	mov dword[wc+WNDCLASSEX.hbrBackground],COLOR_BTNFACE+1
	mov dword[wc+WNDCLASSEX.lpszMenuName], NULL
	mov dword[wc+WNDCLASSEX.lpszClassName], ClassName
	call LoadIconA, NULL, IDI_APPLICATION
	mov dword[wc+WNDCLASSEX.hIcon], eax
	mov dword[wc+WNDCLASSEX.hIconSm], eax
	call LoadCursorA, NULL, IDC_ARROW
	mov dword[wc+WNDCLASSEX.hCursor], eax
	lea eax,[wc]
    call RegisterClassExA, eax
	call CreateWindowExA, WS_EX_CLIENTEDGE, ClassName, "KALKULATOR-Ardacandra-18532", WS_OVERLAPPEDWINDOW, 364, 128, 325, 250, NULL, NULL, [hInstance], NULL
	mov dword[hwnd], eax
	call ShowWindow, [hwnd], [nCmdShow]
	call UpdateWindow, [hwnd]
.loop:
	lea eax,[msg]
    call GetMessageA, eax, NULL, 0, 0
	cmp eax, 0
	jb .erro
	je .fin
	lea eax, [msg]
	call TranslateMessage, eax
	lea eax, [msg]
	call DispatchMessageA, eax
	jmp .loop
	.erro:
	call MessageBoxA, 0, "An unexpected error has occurred.", "Report", MB_OK
	.fin:
	mov eax, dword[msg+MSG.wParam]
endproc

proc WinProc, hWnd, uMsg, wParam, lParam
	mov eax, dword[uMsg]
	cmp eax, WM_DESTROY
	je near .DESTROY
    	cmp eax,WM_CREATE
    	je near .CREATE
    	cmp eax,WM_COMMAND
    	je near .COMMAND
	;-------
    	call DefWindowProcA, [hWnd], [uMsg], [wParam],[lParam]
	return

    ;------
    .CREATE:
	call CreateWindowExA, WS_EX_CLIENTEDGE, EditClassName, "", WS_CHILD | WS_VISIBLE | WS_BORDER | ES_LEFT | ES_AUTOHSCROLL, 50,35,200,25,[hWnd],EditID1,[Instance],NULL
	mov [hwndEdit1],eax
	call SetFocus, [hwndEdit1]
	call CreateWindowExA, WS_EX_CLIENTEDGE, EditClassName, "", WS_CHILD | WS_VISIBLE | WS_BORDER | ES_LEFT | ES_AUTOHSCROLL, 50,75,200,25,[hWnd],EditID2,[Instance],NULL
	mov [hwndEdit2],eax
	;call SetFocus, [hwndEdit2]
	call CreateWindowExA, NULL, ButtonClassName, ButtonText1, WS_CHILD | WS_VISIBLE | BS_DEFPUSHBUTTON, 50,130,25,25,[hWnd],ButtonID1,[Instance],NULL
	mov  [hwndButton],eax
	call CreateWindowExA, NULL, ButtonClassName, ButtonText2, WS_CHILD | WS_VISIBLE | BS_DEFPUSHBUTTON, 80,130,25,25,[hWnd],ButtonID2,[Instance],NULL
	mov  [hwndButton],eax
	call CreateWindowExA, NULL, ButtonClassName, ButtonText3, WS_CHILD | WS_VISIBLE | BS_DEFPUSHBUTTON, 110,130,25,25,[hWnd],ButtonID3,[Instance],NULL
	mov  [hwndButton],eax
	call CreateWindowExA, NULL, ButtonClassName, ButtonText4, WS_CHILD | WS_VISIBLE | BS_DEFPUSHBUTTON, 140,130,25,25,[hWnd],ButtonID4,[Instance],NULL
	mov  [hwndButton],eax
    return FALSE
	
    .COMMAND:
	
    	mov eax,[wParam]
    
    	cmp ax, IDM_HELLO
    	jne .L001
	call SetWindowTextA,[hwndEdit1],Test_string
	call SendMessageA,[hwndEdit1],WM_KEYDOWN,VK_END,NULL
	call SetWindowTextA,[hwndEdit2],Test_string
	call SendMessageA,[hwndEdit2],WM_KEYDOWN,VK_END,NULL
 .L001:
    
    	cmp ax, IDM_CLEAR
    	jne .L002
    	call SetWindowTextA,[hwndEdit1],NULL
	call SetWindowTextA,[hwndEdit2],NULL
    
 .L002:
    	cmp ax, IDM_GETTEXT1
	jne .L003
	call GetWindowTextA,[hwndEdit1],buffer1,512     ; MENGAMBIL ISI PADA EDITBOX
	call GetWindowTextA,[hwndEdit2],buffer2,512     ; MENGAMBIL ISI PADA EDITBOX
	str2int buffer1					; mengambil fungsi dari nagoa yaitu str2int
	mov [buffer1],eax
	str2int buffer2
	mov [buffer2],eax
	mov eax,[buffer1]
	mov ebx,[buffer2]

	add eax,ebx

	mov [nhasil1],eax
	int2str [nhasil1],shasil1
	call MessageBoxA,NULL,shasil1, Teks_mbox, MB_OK  ; MENAMPILKAN ISINYA PADA MSGBOX
	
 .L003:
	cmp ax, IDM_GETTEXT2
	jne .L004
	call GetWindowTextA,[hwndEdit1],buffer1,512     ; MENGAMBIL ISI PADA EDITBOX
	call GetWindowTextA,[hwndEdit2],buffer2,512     ; MENGAMBIL ISI PADA EDITBOX
	str2int buffer1					; mengambil fungsi dari nagoa yaitu str2int
	mov [buffer1],eax
	str2int buffer2
	mov [buffer2],eax
	mov eax,[buffer1]
	mov ebx,[buffer2]

	sub eax,ebx

	mov [nhasil2],eax
	int2str [nhasil2],shasil2
	call MessageBoxA,NULL,shasil2, Teks_mbox,MB_OK  ; MENAMPILKAN ISINYA PADA MSGBOX

 .L004:
	cmp ax, IDM_GETTEXT3
	jne .L005
	call GetWindowTextA,[hwndEdit1],buffer1,512     ; MENGAMBIL ISI PADA EDITBOX
	call GetWindowTextA,[hwndEdit2],buffer2,512     ; MENGAMBIL ISI PADA EDITBOX
	str2int buffer1					; mengambil fungsi dari nagoa yaitu str2int
	mov [buffer1],eax
	str2int buffer2
	mov [buffer2],eax
	mov eax,[buffer1]
	mov ebx,[buffer2]

	mul ebx

	mov [nhasil3],eax
	int2str [nhasil3],shasil3
	call MessageBoxA,NULL,shasil3, Teks_mbox,MB_OK  ; MENAMPILKAN ISINYA PADA MSGBOX

 .L005:
	cmp ax, IDM_GETTEXT4
	jne .L006
	call GetWindowTextA,[hwndEdit1],buffer1,512     ; MENGAMBIL ISI PADA EDITBOX
	call GetWindowTextA,[hwndEdit2],buffer2,512     ; MENGAMBIL ISI PADA EDITBOX
	str2int buffer1					; mengambil fungsi dari nagoa yaitu str2int
	mov [buffer1],eax
	str2int buffer2
	mov [buffer2],eax
	mov eax,[buffer1]
	mov ebx,[buffer2]

	div ebx

	mov [nhasil4],eax
	int2str [nhasil4],shasil4
	call MessageBoxA,NULL,shasil4, Teks_mbox,MB_OK  ; MENAMPILKAN ISINYA PADA MSGBOX
	
 .L006:
    	cmp ax, IDM_EXIT
    	jne .L007
    	call PostQuitMessage, 0
    
 .L007:
    	cmp ax, ButtonID1			; PADA SAAT BUTTON DI KLIK ISINYA MSG ADL ButtonID
    	jne .L008
    	shr eax, 16		
    	cmp ax, BN_CLICKED			; EVENT PADA BUTTON setelah digeser 16-bit kekanan
    	jne .L0011	
    	call SendMessageA,[hWnd],WM_COMMAND, IDM_GETTEXT1, 0	; KIRIM MSG KE WINDOWS
 .L008:
	cmp ax, ButtonID2			; PADA SAAT BUTTON DI KLIK ISINYA MSG ADL ButtonID
    	jne .L009
    	shr eax, 16		
    	cmp ax, BN_CLICKED			; EVENT PADA BUTTON setelah digeser 16-bit kekanan
    	jne .L0011	
    	call SendMessageA,[hWnd],WM_COMMAND, IDM_GETTEXT2, 0	; KIRIM MSG KE WINDOWS

 .L009:
    	cmp ax, ButtonID3			; PADA SAAT BUTTON DI KLIK ISINYA MSG ADL ButtonID
    	jne .L0010
    	shr eax, 16		
    	cmp ax, BN_CLICKED			; EVENT PADA BUTTON setelah digeser 16-bit kekanan
    	jne .L0011	
    	call SendMessageA,[hWnd],WM_COMMAND, IDM_GETTEXT3, 0	; KIRIM MSG KE WINDOWS
 .L0010:
    	cmp ax, ButtonID4			; PADA SAAT BUTTON DI KLIK ISINYA MSG ADL ButtonID
    	jne .L0011
    	shr eax, 16		
    	cmp ax, BN_CLICKED			; EVENT PADA BUTTON setelah digeser 16-bit kekanan
    	jne .L0011	
    	call SendMessageA,[hWnd],WM_COMMAND, IDM_GETTEXT4, 0	; KIRIM MSG KE WINDOWS
 .L0011: 
    return FALSE

    .DESTROY:
	call PostQuitMessage, 0
	endproc

; -- end of file
