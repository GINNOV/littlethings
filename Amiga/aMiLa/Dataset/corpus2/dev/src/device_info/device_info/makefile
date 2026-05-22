CC	= gcc
#CC	= dcc

test_device_info: device_info.o test_device_info.o
	$(CC) -o test_device_info test_device_info.o device_info.o
device_info.o: device_info.c device_info.h
	$(CC) -o device_info.o -c device_info.c

test_device_info.o: test_device_info.c
	$(CC) -o test_device_info.o -c test_device_info.c
