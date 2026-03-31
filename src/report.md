## Part 1. Установка ОС

- Версия убунты:

   ![UbuntuVersion](./Screenshots/UbuntuVersion.png)

## Part 2. Создание пользователя

- Команда для создания нового пользователя:

   ![passwd](./Screenshots/newUser.png)


- Вывод команды  ```cat /ect/passwd```

   ![passwd](./Screenshots/passwd.png)
- Группы нового пользователя:

   ![groups](./Screenshots/groups.png)

## Part 3. Настройка сети ОС

- Для переименования имени машины я использовал следующую команду: 

   ```sudo hostnamectl set-hostname user-1```

   ![machineRename](./Screenshots/machineRename.png)


- Для времени:

   ```sudo timedatectl set-timezone Europe/Moscow```

   Позволяет установить часовой пояс для машины в формате задачи Регион/Город

   ![newTimezone](./Screenshots/newTimezone.png)


- Сетевые интерфейсы машины:

   ![networkInterfaces](./Screenshots/networkInterfaces.png)

- Io интерфейс необходим для налаживания работы устройства с вводом и выводом данных в и из сети Например, получение данных с сервера или отправление данных на сервер,

- IP от DHCP:

   ![internal IP from DHCP](./Screenshots/internalIP.png)

- Dynamic Host Configuration Protocol - протокол для автоматического назначения IP-адресса и других параметров устройствам в сети.

- Внутренний и внешний IP адресса соответственно:

   ![Internal IP](./Screenshots/internalIP.png)

   ![External IP](./Screenshots/externalIP.png)

- Для задания статичного айпи-адресса машине я изменял netplan самой машины: 

   ![EditingIPs](./Screenshots/editingIPs.png)

- После изменения и перезапуска машины:

   ![Internal IP after edit](./Screenshots/internalIPafterEdit.png)

- Результаты пингования:

   1.1.1.1

   ![Pinging 1.1.1.1](./Screenshots/pinging1.1.1.1.png)

   ya.ru

   ![Pinging ya.ru](./Screenshots/pingingYa.ru.png)

## Part 4. Обновление ОС

- Обновление системы:

   ![Update system](./Screenshots/update.png)

## Part 5. Использование команды sudo

- Команда sudo позволяет временно получить права администратора для выполнения одной команды.

- Добавление sudo прав пользователю:

   ![Adding Sudo To User](./Screenshots/addingSudoToUser.png)

- Переход на нового пользователя:

   ![Changing To A New User](./Screenshots/changingToANewUser.png)

- Изменине имени машины через нового пользователя:

   ![Changing Hostname Via New User](./Screenshots/changingHostnameViaNewUser.png)

## Part 6. Установка и настройка службы времени

- Вывод времени в котором я сейчас нахожусь:

   ![Outputing Timezone](./Screenshots/outputingTimezone.png)

## Part 7. Установка и использование текстовых редакторов

- VI. Для закрытия ввел команду :wq

   ![vi](./Screenshots/vi.png)

- NANO. Для закрытия ввел последовательно: 

   ```Cmnd+X```

   ```Y```

   ```Enter```

   ![NANO](./Screenshots/nano.png)

- MCEdit. Для закрытия нажал fn+F10:

   ![MCedit](./Screenshots/mcedit.png)

- После изменения и выхода без сохранения:

- VI. Для закрытия без сохранения ввел команду :q!

   ![Vi w/o save](./Screenshots/ViWoSave.png)

- NANO. Для закрытия ввел последовательно: 

   ```Cmnd+X```

   ```N```

   ```Enter```
   
   ![NANO w/o save](./Screenshots/NanoWoSave.png)

- MCEdit. Для закрытия нажал fn+F10 и отказался от сохранения:

   ![MC w/o save](./Screenshots/MCWoSave.png)

- VI. 

   Для поиска была введена комада / и после написан искомый текст:

   ![Vi Find](./Screenshots/viFind.png)

   Для поиска и замены было использована команда \:s/заменяемый текст/заменяющий текст/

   ![Vi Find Replace](./Screenshots/viFindReplace.png)

- NANO.

   Для поиска была введена комада Crtl+W и после написан искомый текст:

   ![Nano Find](./Screenshots/nanoFind.png)

   Для поиска и замены было использована команда Ctrl+/ и введено заменяемое слово:

   ![Nano Find Replace](./Screenshots/nanoFindReplace1.png)
   
   Ввод заменяющего слова:
   
   ![Nano Find Replace](./Screenshots/nanoFindReplace2.png)
   
   Результат:
   
   ![Nano Find Replace](./Screenshots/nanoFindReplace3.png)

- MCEdit.

   Для поиска была введена команда fm+F7 и после написан искомый текст:
   ![NC Find](./Screenshots/MCFind.png)

   Для поиска и замены было использована команда fn+F4 и введено заменяемое слово:

   ![MC Find Replace](./Screenshots/MCFindReplace.png)

   Выбор заменяемого найденного слова:

   ![MC Find Replace](./Screenshots/MCFindReplace2.png)

   Результат:

   ![MC Find Replace](./Screenshots/MCFindReplace3.png)

## Part 8. Установка и базовая настройка сервиса SSHD
- Установка SSHD происходила по вводу команды:

   ```sudo apt install openssh-server```

- Проверка запущенной сервиса SSHd:

   ![SSH status](./Screenshots/sshStatus.png)

- Открытие порта 2022 для SSHd:

   ![SSH allowing 2022](./Screenshots/sshAllowing2022.png)

- Проверяем наличие процесса ssh через ps:

   ![ps SSH](./Screenshots/psSsh.png)

- a: Отображает процессы всех пользователей

   u: Использует формат вывода, который включает дополнительные сведения

   x: Показывает все процессы

- Изменение айпи на статический:

   ![SSH file](./Screenshots/sshFile.png)

- Информация с netstat:

   ![netstat ssh](./Screenshots/netstatSsh.png)

   Флаг а используется для отображения всех сокетов машины, t - для отображения tcp сокетов, n - отображает IP и номера портов вместо цисловых айдишников.

   Столбцы: Proto - протокол, Recv-Q - количество полученных байтов, Send-Q - отправленных, Local Address - локальные айпи с портом процесса,  Foreging Address - внешние айпи с портом процесса, State - статус процесса.

## Part 9. Установка и использование утилит top, htop

- Вывод htop:

   ![htop](./Screenshots/htop.png)
   
   Столбцы: PID - уникальный айди процесса, USER - пользователь процесса, PRI - приоритет процесса для процессора, NI - уровень "nice" процесса, VIRT - занимаемый обьем виртуальной памяти процесса, RES - занимаемый обьем ОЗУ у процессора, SHR - обьем памяти который может быть разделен с другими процессами, S - статус процесса, CPU% - нагрузка на процессор процессом, MEM% - нагрузка на память процессом, TIME+ - время работы процесса, Command - путь к исходному файлу процесса.

- Сортировка по PID:

   ![sort By PID](./Screenshots/SortByPID.png)

- Сортировка по MEM:

   ![sort By MEM](./Screenshots/SortByMEM.png)

- Сортировка по CPU:

   ![sort By CPU](./Screenshots/sortByCPU.png)

- Сортировка по TIME:

   ![sort By TIME](./Screenshots/SortByTIME.png)

- Фильтр по sshd:

   ![filter By SSHD](./Screenshots/filetForSSHD.png)

- syslog:

   ![find syslog](./Screenshots/searchForSYSLOG.png)

- hostname, clock, uptime:

   ![htop With HOSTNAME clock UPTIME](./Screenshots/htopWithHOSTNAMEclockUPTIME.png)

## Part 10. Использование утилиты fdisk

- Название диска: /dev/sda

   Размер: 25 гигабайт

   Количество секторов: 52428800

   SWAP: нету в виду отсутствия файла подкачки

   ![fdisk](./Screenshots/fdisk.png)
 

## Part 11. Использование утилиты df

- Запуск команды df:

   ![df](./Screenshots/df.png)

- Размер раздела: 11758760,

   Размер занятого пространства: 4950428 килобайт,

   Размер свободного пространства: 6189224 килобайт, 45%.

   df выводит размеры диска в килобайтах (по умолчанию).

- Запуск команды df -Th:

   ![dfth](./Screenshots/dfth.png)

- Размер раздела: 12 гигабайт,

   Размер занятого пространства: 4.8 гигабайт,

   Размер свободного пространства: 6 гигабайт, 45%.

   Тип файловой системы для раздела / - ext4

## Part 12. Использование утилиты du

- Запуск команды du:

   ![du](./Screenshots/du.png)

- Размер папки /home:

   ![du home](./Screenshots/duHome.png)

- Размер папки /var:

   ![du var](./Screenshots/duVar.png)

- Размер папки /var/log:

   ![du varlog](./Screenshots/duVarlog.png)

- Размер всего содержимого в /var/log:

   ![du varlog*](./Screenshots/duVarlog*.png)

## Part 13. Установка и использование утилиты ncdu

- Размер папки /home:

   ![ncdu home](./Screenshots/ncduHome.png)

- Размер папки /var:

   ![ncdu var](./Screenshots/ncduVar.png)

- Размер папки /var/log:

   ![ncdu varlog](./Screenshots/ncduVarlog.png)

## Part 14. Работа с системными журналами

- Последний логин:

   ![last Login](./Screenshots/lastLogin.png)

- Время логина: 13:19:58

   Имя пользователя: newuser

   Метод входа в систему: ssh

- Перезапуск SSHd:

   ![restart SSHd](./Screenshots/restartSSHD.png)

## Part 15. Использование планировщика заданий CRON

- Добавление задачи в CRON. Вписывается в конец файла, после выполнения команды crontab -e:

   ![cron Tasks](./Screenshots/cronTasks.png)

- Результат выполнения:

   ![cron Result](./Screenshots/cronResult.png)

- Очищаем список задач командой crontab -r и выводим все текущие задачи:

   ![Removing And Showing cron tasks](./Screenshots/removingAndShowing.png)
