.model tiny
.code				; сегмент кода
org 100h			; выделение 256 байт для стека
start:				; начало стека
mov dx, offset UserPrint	; записываем в dx переменную
call Print			; вызов процедуры Print
mov ax, 1			; число 1 записываем в ax
mov bx, 2			; число 2 записываем в bx
add al, 30h			; добавляем 0 в al, чтобы программа воспринимала число
add bl, 30h			; добавляем 0 в bl, 30h по таблице ASCII
mov ah, 02h			; вывод одного символа
mov dl, al			; запись в dl из al для вывода
int 21h				; прерывание
mov dl, 0h			; запись в dl пробела для раздельного вывода
int 21h				; прерывание
mov dl, bl			; запись в dl из bl для вывода
int 21h				; прерывание
mov ax, 4C00h		; завершение программы с кодом 0
int 21h

Print proc			; начало процедуры
mov ah, 09h			; запись в ah для вывода строки
int 21h				; прерывание
ret					; выход из процедуры
Print endp			; конец процедуры

UserPrint db 'Kovaleva Sofya 241', 0Dh, 0Ah, '$' ; строка с символами перехода на новую строку

end start ; конец программы
