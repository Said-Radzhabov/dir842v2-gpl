#!/bin/bash
#$1 - входная рутфс
#$2 - рутфс в альфа формате

#добавляем в рутфс заголовок
echo -n "--PaCkImGs--" > $2

#добавяем 5 нулей
dd if=/dev/zero of=$2 bs=1 count=5 oflag=append conv=notrunc

#добавляем 0x5B - что такое не знаю
printf "\x5B" >> $2

#еще 14 нулей
dd if=/dev/zero of=$2 bs=1 count=14 oflag=append conv=notrunc

#сама рутфс
cat $1 >> $2
