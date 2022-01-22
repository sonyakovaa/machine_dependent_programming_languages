extrn ExitProcess: proc, ; Функция для завершения работы
      MessageBoxA: proc, ; Функция для вызова окна
      GetUserNameA: proc, ; Функция для получения имени пользователя
      GetComputerNameA: proc, ; Функция для получения имени компьютера
      GetTempPathA: proc, ; Функция для получения пути до директории временных файлов
      wsprintfA: proc ; Функция для подстановки зн-й в строку с форматированием

.data ; Сегмент данных

szMAX_COMP_NAME equ 16 ; Данные макрозамены определяют длины строк
szUNLEN equ 257
szMAX_PATH equ 261

cap db 'Information KovalevaSA', 0 ; Заголовок окна
fmt db 'Username: %s',0Ah, ; Имя пользователя
       'Computer name: %s', 0Ah, ; Имя компьютера
       'TMP Path: %s', 0Ah, ; Путь к папке Temp

.code ; Сегмент кода
Start proc ; Начало программы
local _msg[1024]                 :byte, ; В переменной _msg будет храниться результирующая строка размером до 1024 байт
      _username[szUNLEN]         :byte, ; Переменная для хранения имени пользователя
      _compname[szMAX_COMP_NAME] :byte, ; Переменная для хранения имени компьютера
      _temppath[szMAX_PATH]      :byte, ; Переменная для хранения пути к папке
      _size                      :dword ; Переменная для передачи размера строк в функции

sub RSP, 8*5 ; Выравнивание стека в соответствии со стандартом __fastcall для 5 аргументов
and SPL, 0F0h

mov _size, szUNLEN ; Поместим в переменную _size значение размера строки имени пользователя (szUNLEN)
lea RCX, _username ; Загрузим адрес строки и указатель
lea RDX, _size ; На ее размер в регистры RCX и RDX соответственно
call GetUserNameA ; Вызов функции

mov _size, szMAX_COMP_NAME ; Значение размера строки имени компьютера в рабочей группе (szMAX_COMP_NAME)
lea RCX, _compname ; Загрузим адрес строки и указатель на ее размер
lea RDX, _size ; В регистры RCX и RDX соответственно
call GetComputerNameA ; Вызов функции

mov _size, szMAX_PATH ; Значение размера строки, содержащей путь к папке Temp (szMAX_PATH)
lea RCX, _size ; Передаем указатель на размер
lea RDX, _temppath ; Загрузим адрес строки
call GetTempPathA ; Вызов функции

; Форматирование отформатированной строки
lea rcx, _msg ; Поместим в регистр RCX строку _msg
lea rdx, fmt ; В RDX занесем строку форматирования (fmt)
lea r8, _username ; В R8 поместим строку имени пользователя
lea r9, _compname ; В R9 поместим строку имени компьютера
lea r10, _temppath ; В R10 поместим строку, содержащую путь к папке
mov qword ptr [rsp + 20h], r10 ; Резервируем место для пути к папке в стеке, уменьшая значение RSP, для вывода значения R10
call wsprintfA ; Вызываем функцию для подстановки значений в строку с форматированием

; Отображение полученной информации в окне
xor rcx, rcx ; Обнуляем rcx
xor r9, r9 ; Обнуляем r9
lea rdx, _msg ; Загрузим в rdx адрес строки для вывода на экран
lea r8, cap ; Загрузим в r8 адрес строки, содержащей заголовок окна
call MessageBoxA ; Вызываем вывод окна

; Завершение программы
xor rcx, rcx ; Обнуляем rcx
call ExitProcess ; Выход из программы
Start endp
end
