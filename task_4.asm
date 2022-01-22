.model small
.stack 100h
.186 ;Разрешение трансляции команд процессора 80186
.data ;Сегмент данных
simple DW 2 DUP(10 DUP (?)) ;Массив simple, содержащий числа от 1 до 10
result DB '     $' ;Строка символов result, определяющая формат вывода чисел на экран
.code

CreateArray proc ;создание массива
	create:
		push AX ;добавляем AX в стек
		mul AX ;AX = AX * AX
		mov simple[BX][DI], AX ;заполняем результат во вторую строку
		pop ax ;возвращаем изначальное значение AX
		mov simple[DI], AX ;заносим изначальное значение AX в первую строку
		add AX, 5 ;увеличиваем АХ на 5
		add DI, 2 ;увеличиваем индекс на 2, тк работает с массивом DW
	loop create ;цикл выполняется CX=10
	ret
endp CreateArray
	
PrintLine proc ;перевод на новую строку
	pusha ;заносим регистры в стек
	MOV DL, 10
	MOV AH, 02h ;переход на новую строку
	int 21h
	popa ;возвращаем регистры
	ret
endp PrintLine


PrintNumber proc
	pusha ;добавляем в стек регистры
	mov DI, 4 ;счетчик
	print:
		MOV DX, 0 ;обнуляем регистр
		MOV BX, 10 ;выбираем 10-СС 
		DIV BX ;делим BX на AX
		ADD DL, 30h
		MOV result[DI], DL ;меняем позицию на DI
		DEC DI ;уменьшаем счетчик
		CMP AX, 0 ;сравниваем с 0
		jne print
	MOV AH, 09h
	MOV DX, offset result ;заносим пробельные символы
	int 21h ;выводим на экран строку
	popa ;возвращаем регистры
	ret
endp PrintNumber

PrintArray proc
	mov CX, 2 ;кол-во строк
	MOV BX, 0 ;обнуляем регистр
	collumns: ;столбцы
		MOV AX, 0
		push CX ;заносим кол-во строк
		MOV CX, 10 ;заносим кол-во элементов в строке
		MOV DI, 0 ;начинаем с нулевого индекса
		rows: ;строки
			MOV AX, simple[BX][DI] ;берем элемент из массива
			call PrintNumber ;вывод очередного элемента на экран
			add DI, 2 ;добавляем +2 к индексу
		loop rows ;повторяем 10 раз
		
		call PrintLine ;переход на новую строку
		pop CX ;берем из стека текущее кол-во строк 
		MOV BX, 20 ;переход ко 2 строке
		loop collumns ;повторяем 2 раза
	ret
endp PrintArray

start:
MOV AX, @DATA
MOV DS, AX
MOV AH, 09h
MOV DI, 0 ;обнуляем регистр индекса
MOV AX, 5 ;с какого значения нужно заносить элементы в массив
MOV CX, 10 ;кол-во элементов в строке
MOV BX, 20 ;адрес 2 строки

call CreateArray ;создание массива
call PrintArray ;печать массива
MOV AX, 4C00h
int 21h
end start
