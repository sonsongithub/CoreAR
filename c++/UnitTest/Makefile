CC=/usr/bin/g++

COREAR=../
TEST=./darwin/CoreARUnitTest/Test/

SRCS = $(shell ls $(COREAR)*.cpp)
OBJS = $(subst $(COREAR),,$(subst .cpp,.o,$(SRCS)))

TEST_SRCS = $(shell ls $(TEST)*.cpp)
TEST_OBJS = $(subst $(TEST),,$(subst .cpp,.o,$(TEST_SRCS)))

CFLAGS=-O2 -I../ -I/opt/local/include/

test:$(OBJS) $(TEST_OBJS) main.o
	$(CC) -o test $(OBJS) $(TEST_OBJS) main.o -ljpeg -L/opt/local/lib/ -framework Accelerate

main.o:./main.cpp
	$(CC) -c ./main.cpp -I$(TEST)

%.o:$(COREAR)%.cpp
	$(CC) -c $(CFLAGS) $<

%.o:$(TEST)%.cpp
	$(CC) -c $(CFLAGS) $<

clean:
	rm -rf $(OBJS) $(TEST_OBJS) main.o test

valgrind:
	valgrind --leak-check=full --leak-resolution=high --show-reachable=yes ./test