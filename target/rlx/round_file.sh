#!/bin/bash
#округляет бинарь до границы блока BLOCK_SIZE минус TAIL

FILE_NAME=$1
#размер блока которым округляем
BLOCK_SIZE=$2
#размер CVIMG заголовка, длина которого вычитается из общей длины округленного файла,
#для того чтобы начало скваша было выровнено по границе блока
TAIL=$3

if (($BLOCK_SIZE <= 0))
then
	exit 0
fi

SIZE=$(stat -c%s "$1");

echo "start size: "$SIZE

NBLOCK=$(($SIZE / $BLOCK_SIZE))

if (($SIZE % $BLOCK_SIZE != 0))
then
	NBLOCK=$(($NBLOCK + 1))
fi

if (($NBLOCK * $BLOCK_SIZE - $SIZE < $TAIL))
then
	NBLOCK=$(($NBLOCK + 1))
fi

TARGET_SIZE=$(($NBLOCK * $BLOCK_SIZE - $TAIL))
echo "round size: " $TARGET_SIZE

DIFF=$(($TARGET_SIZE - $SIZE))

if (($DIFF > 0))
then
	dd if=/dev/zero of=$FILE_NAME bs=$DIFF count=1 oflag=append conv=notrunc > /dev/null 2>&1
fi


