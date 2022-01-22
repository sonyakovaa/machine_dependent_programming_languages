extrn ExitProcess :proc, ; Сообщаем, что в коде будут использоваться ф-ии, опр-е вне модуля WinAPI
      MessageBoxA :proc ; Вызов окна

.data ; Сегмент памяти
caption db '64-bit hello!', 0 ; Переменная для заголовка окна, DB-байт
message db 'Kovaleva Sofya, 241',  0 ; Переменная для содержимого окна, DB-байт

.code ; Сегмент кода
Start proc ; Начало основной программы
  sub RSP, 8*5 ; Подготовка стека для 4-х аргументов и выравнивания. Выделяется 40 байт - 32 (на аргументы), 8 (для смещения)

  xor RCX, RCX ; RCX присваиваем 0
  lea RDX, message ; Передача адреса переменной
  lea R8, caption ; Передача адреса переменной
  xor R9, R9 ; R9 присваиваем 0

  call MessageBoxA ; Вызов функции

  xor RCX, RCX ; RCX присваиваем 0

  call ExitProcess ; Вызов функции
Start endp ; Завершение работы
end
