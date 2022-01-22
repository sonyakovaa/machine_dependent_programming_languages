; F = 18 + (17 - A - B), A - слово со знаком, В - слово со знаком, 12h = 18, 11h = 17
 
extrn GetStdHandle: proc, ; Ф-я для получения дескриптора для потока
	WriteConsoleA: proc, ; Ф-я для записи строки в консоль
	ReadConsoleA: proc, ; Ф-я для чтения строки из потока
	lstrlenA: proc, ; Ф-я для получения длины строки
	ExitProcess: proc ; Ф-я для завершения работы программы
 
.data ; Сегмент данных
STACKALLOC macro arg ; Макрос для выравнивания стека
  push R15 ; Берем указатель на старый стек
  mov R15, RSP ; Помещаем значение RSP
  sub RSP, 8*4 ; Освобождение места для 4-х обязательных аргументов
  if arg ; Если число аргументов макроса не равно нулю, то освобождаем место для них
    sub RSP, 8*arg
  endif
  and SPL, 0F0h ; Выравниваем стек (регистр SPL) по 16-байтовой границе
endm
 
STACKFREE macro arg ; Макрос для освобождения выделенной памяти
	mov RSP, R15
	pop R15
endm
 
NULL_FIFTH_ARG macro arg ; Макрос для установки пятого аргумента в нуль 
	mov qword ptr [RSP + 32], 0
endm
 
; Макрозамены
STD_OUTPUT_HANDLE = -11 ; Номер стандартного потока вывода в WinAPI
STD_INPUT_HANDLE = -10 ; Номер стандартного потока ввода в WinAPI
 
; Неопределенные qword-значения для дескрипторов ввода и вывода
hStdInput qword ?
hStdOutput qword ?
res qword ? ; Неопределенная переменная, в которой будет храниться результат действий a и b
 
; Переменные, содержащие строки пользовательского интерфейса
aOutput db 'a = ', 0
bOutput db 'b = ', 0
result db 'F = 18 + (17 - A - B) = ', 0
invalid db 'Invalid character',0
exitOutput db 0Ah, 'Press any key to exit...', 0
strError db 0Ah, 'Error Range', 0
 
.code ; Сегмент кода
Start proc ; Начало главной процедуры
	STACKALLOC 1 ; Выделение места в стеке под аргументы
	mov RCX, STD_OUTPUT_HANDLE ; Поток вывода
	call GetStdHandle ; Вызовем GetStdHandle (возвращаемое значение окажется в RAX)
	mov hStdOutput, RAX ; Значение дескриптора 
 
	mov RCX, STD_INPUT_HANDLE ; Поток ввода 
	call GetStdHandle ; Вызов считывания числа
	mov hStdInput, RAX	
	mov R8, 12h ; Заносим значение 12h
 
	; Выведем строку 'a = '
	lea RAX, aOutput 
	push RAX
	call StringWrite
	call StringRead
	cmp R10, 0 ; Проверка R10. Если зн-е регистра равно 0, то покажем сообщение о неправильном символе и перейдем на выход
	je wrongSymbol
	sub R8, RAX ; Вычитание `a` из результата
 
	; Выведем строку b =
	lea RAX, bOutput
	push RAX
	call StringWrite
	call StringRead
	cmp R10, 0 ; Проверка R10. Если зн-е регистра равно 0, то покажем сообщение о неправильном символе и перейдем на выход
	je wrongSymbol
 
	sub R8, RAX ; Вычитание `b`
	add R8, 11h ; Прибавим 11h
	mov res, R8
 
	; Вывод строки суммы
	lea RAX, result
	push RAX
	call StringWrite
	call PrintSignedNumber
	jmp wrongSymbol
	wrongSymbol:
		call inputAwaiting ; Удержание консоли
		xor RCX, RCX
	call ExitProcess
Start endp
 
StringWrite proc uses RAX RCX RDX R8 R9, string: qword ; Процедура для вывода строки
	local bytesWritten: qword ; Введем локальную переменную для аргумента lpNumberOfCharsWritten функции записи
	STACKALLOC 1 ; Выделим место в стеке
	mov RCX, string ; Поместим в регистр первого аргумента указатель на выводимую строку
	call lstrlenA ; Получим ее длину
	; Поместим аргументы в регистры
	mov RCX, hStdOutput
	mov RDX, string
	mov R8, RAX
	lea R9, bytesWritten
	NULL_FIFTH_ARG ; Обнулим значение пятого аргумента
	call WriteConsoleA
	STACKFREE ; Освободим стек
	ret 8 ; Вернемся в основную программу, очищая стек от одного аргумента
StringWrite endp
 
; Процедура чтения знакового числа из строки
StringRead proc uses RBX RCX RDX R8 R9
	; Локальные переменные
	local readStr[64]: byte, ; Строка, в которую будут занесены считанные символы
      bytesRead:   dword ; Число прочитанных символов
	STACKALLOC 2 ; Выделим место в стеке
	; Разместим аргументы в нужные регистры
	mov RCX, hStdInput
	lea RDX, readStr ; Загружаем адрес readStr
	mov R8, 64
	lea R9, bytesRead ; Загружаем адрес bytesRead
	NULL_FIFTH_ARG
	call ReadConsoleA
	; Начнем вычисление строки
	xor RCX, RCX ; Сброс RCX 
	mov ECX, bytesRead ; Число прочитанных байт
	sub ECX, 2 ; Вычтем из него 2: избавимся от символов переноса строки и возврата каретки
	mov readStr[RCX], 0 ; Сделаем строку нуль-терминированной
	xor RBX, RBX ; Сбросим RBX
	mov R8, 1 ; В R8 занесем 1 (там будут храниться степени десятки для умножения)
 
	; Конвертация строки в число. В RCX хранится длина строки. Уменьшая RCX, анализируем строку
	mov BL, readStr[0]
	cmp BL, 0h
	je error
	xor RBX, RBX
	rangeChecking: ; Определим метку прохода по строке
	cmp RBX, 32767
	jge errorLen
	dec RCX ; Уменьшим RCX на 1
	; Проверяем знак числа
	cmp RCX, -1
	je scanningComplete ; Если RCX стал равен -1, то перейдем на метку scanningComplete
	xor RAX, RAX ; Если RCX не равен -1, установим RAX в 0 и будем хранить там очередную цифру
	mov AL, readStr[RCX] ; В AL поместим очередной символ
	cmp RCX, 0
	jne K
	cmp AL, '-' ; Если он равен '-', то меняем знак числа в RBX и перейдем на метку scanningComplete
	jne eval ; Иначе перейдем на метку eval
	cmp RBX, 0
	je error
	neg RBX
	jmp scanningComplete
 
	K:
	cmp AL,'-'
	je error
 
	eval: ; Проверим, является ли символ десятичной цифрой
	; Если нет, то перейдем на метку error. Иначе получим число из кода символа и прибавим его к RBX. 
	; Увеличим RAX в 10 раз для записи следующей цифры в следующем разряде. 
	; Затем перейдем на метку прохода по строке.
	cmp AL, 30h
	jl error
	cmp AL, 39h
	jg error
	sub RAX, 30h
	mul R8
	add RBX, RAX
	mov RAX, 10
	mul R8
	mov R8, RAX
	jmp rangeChecking
 
	error:
	xor R10, R10 ; Заносим 0
	lea RAX, invalid ; Адрес строки с выводом ошибкой
	push RAX
	call StringWrite
	STACKFREE
	ret 8*2
	; Проверка выхода за границу числа
	errorLen:
	xor R10, R10 ; Заносим 0
	; Адрес строки с выводом ошибки
	lea RAX, strError
	push RAX
	call StringWrite
	STACKFREE ; Очищаем стек
	ret 8*2
	scanningComplete: ; Завершение сканирования
	mov R10, 1
	mov RAX, RBX
	STACKFREE ; Очищаем стек
	ret 8*2
StringRead endp
 
; Процедура вывода знакового числа
PrintSignedNumber proc uses RAX RCX RDX R8 R9 R10 R11
	local numberStr[22]: byte ; Введем локальную байтовую переменную - выводимая строка
	xor R8, R8 ; Обнулим регистр-счётчик
	mov RAX, res ; Занесем в RAX аргумент функции 
	; Выясним, является ли это число положительным или отрицательным
	mov RBX, 63 ; Сравнить 63-й бит аргумента
	btc res, RBX ; Занести результат в Carry Flag
	jae digitDivision
	; Если отрицательное, то первым символом должен стать '-'
	mov numberStr[0], 2Dh ; Занесем его в строку
	inc R8 ; Увеличим R8 на 1
	neg RAX ; Делаем это число положительным
	digitDivision:
	mov RBX, 10 ; Занесем в RBX 10 для осуществления деления
	xor RCX, RCX ; Сбросим значение RCX для записи длины строки
	stackIterating: ; Создадим метку для деления
	xor RDX, RDX ; Сбросим RDX
	; Разделим RAX на RBX
	div RBX
	add RDX, '0'
	push RDX ; Поместим остаток в стек
	inc RCX ; Увеличим RCX
	; Проверим, если RAX стал нулем, то мы закончили деление
	cmp RAX, 0
	jne stackIterating ; Иначе перейдем на метку деления
	numberCollecting: ; Метка переноса в стек
	pop RDX ; Переместим в регистр символ цифры из стека
	mov numberStr[R8], DL ; Возьмем его младшую часть и занесем ее со смещением, указанным в R8
	inc R8 ; Увеличиваем зн-е R8 
	; Повторим эти действия, пока RCX не станет нулем
	loop numberCollecting
	mov numberStr[R8], 0 ; В конце строки необходимо поставить нуль-терминатор
	lea RAX, numberStr ; Занесем адрес начала строки в регистр RAX
	push RAX ; Затем занесем его в стек
	call StringWrite ; Вызовем процедуру для вывода строки
	ret 8
PrintSignedNumber endp
 
; Процедура ожидания ввода
inputAwaiting proc uses RAX RCX RDX R8 R9 R10 R11
	local readStr: byte, ; Введем локальные переменные
		bytesRead: dword
	STACKALLOC 1 ; Выровняем стек
	; Передадим в регистры все необходимы параметры
	lea RAX, exitOutput
	push RAX
	call StringWrite
	; Установим значения всех аргументов
	mov RCX, hStdInput
	lea RDX, readStr
	mov R8, 1
	lea R9, bytesRead
	NULL_FIFTH_ARG
	call ReadConsoleA
	STACKFREE
	ret
inputAwaiting endp
end
