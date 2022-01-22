.model tiny						
.code						; начало сегмента кода
org 100h					; выделение памяти 256 байт для стека
start:						; начало стека
mov dx, offset UserPrint	; записываем в dx переменную
call Print					; вызов процедуры Print
mov ax, 3					; число 3 записываем в ax
mov bx, 4					; число 3 записываем в bx
add al, 30h					; добавляем 0 в al
add bl, 30h					; добавляем 0 в bl
mov ah, 02					; вывод одного символа
push ax						; запись в стек регистра ax
call PrintAx				; вызов процедуры
mov dl, 0h					; перенос строки в консоли
int 21h						
call PrintBx				; вызов процедуры
mov dl, 0Ah					; перенос строки в консоли
int 21h
pop ax						; извлечение из стека регистра ax
XCHG al, bl					; меняем местами содержимое двух операндов, стираем то, что находилось в al
call PrintAx				; вызов процедуры
mov dl, 0h					; перенос строки в консоли
int 21h
call PrintBx				; вызов процедуры

mov ax, 4C00h				; завершение программы
int 21h

Print proc
mov ah, 09h
int 21h
ret
Print endp

PrintAx proc
mov dl, al
int 21h
ret
PrintAx endp

PrintBx proc
mov dl, bl
int 21h
ret
PrintBx endp

UserPrint db 'Kovaleva Sofya 241', 0Dh, 0Ah, '$'

end start
