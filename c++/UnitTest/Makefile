CC=/usr/bin/g++

COREAR=../
TEST=./

SRCS = $(shell ls $(COREAR)*.cpp)
OBJS = $(subst $(COREAR),,$(subst .cpp,.o,$(SRCS)))

TEST_SRCS = $(shell ls $(TEST)*.cpp)
TEST_OBJS = $(subst $(TEST),,$(subst .cpp,.o,$(TEST_SRCS)))

CFLAGS=-O2 -I../ -I/opt/local/include/

test:$(OBJS) $(TEST_OBJS)
	$(CC) -o test $(OBJS) $(TEST_OBJS) -ljpeg -L/opt/local/lib/ -framework Accelerate

main.o:./main.cpp
	$(CC) -c ./main.cpp -I$(TEST)

%.o:$(COREAR)%.cpp
	$(CC) -c $(CFLAGS) $<

%.o:$(TEST)%.cpp
	$(CC) -c $(CFLAGS) $<

clean:
	rm -rf $(OBJS) $(TEST_OBJS) test

valgrind:test
	valgrind --leak-check=full --leak-resolution=high ./test