.model small
.stack 100h
.data
	UserPrint db 'Kovaleva Sofya 241', 0Dh, 0Ah, '$'
.386
.code
start:
mov ax, @data
mov ds, ax

mov ah, 09
mov dx, offset UserPrint ;запись строки в dx
int 21h

mov ax, 12382 ;Заносим число в регистр AL
mov bx, 10 ;Заносим основание системы счисления, равное 10, в регистр BL

;Алгоритм решения состоит в выводе числа "поразрядно" и заключается в следующей последовательности шагов:
mov cx, 0
algorithm:
	; 1 Положить номер разряда числа равным 0: k=0.
	mov dx, 0
	; 2 Вычислить частное и остаток от деления числа X на 10 и частное в дальнейшем принимать за X.
	div bx ; ax поделили на bx
	; 3 Запомнить остаток - он соответствует цифре числа в k-ом разряде.
	push dx
	; 4 Увеличить номер разряда числа на единицу.
	add cx, 1
	; 5 Если X=0, то перейти к шагу 6, иначе перейти к шагу 2.
	CMP ax, 0
JNZ algorithm
; 6 Конец вычислений.
; Алгоритм выделит цифры в записи числа, начиная с его младшего (самого правого) разряда.
print_remainder:
	pop dx
	call print
loop print_remainder

mov ax,4C00h ;Завершение программы
int 21h

print proc ;Процедура print вывода на экран одной цифры
	push ax
	push dx
	mov ah, 02h
	add dl, 30h
	int 21h
	pop dx
	pop ax
	ret ;Возврат в программу
print endp ;Конец процедуры

end start ;Конец программы
