CC=/usr/bin/g++

COREAR=../
TEST=./

SRCS = $(shell ls $(COREAR)*.cpp)
OBJS = $(subst $(COREAR),,$(subst .cpp,.o,$(SRCS)))

TEST_SRCS = $(shell ls $(TEST)*.cpp)
TEST_OBJS = $(subst $(TEST),,$(subst .cpp,.o,$(TEST_SRCS)))

CFLAGS=-O0 -ggdb -Wall -I../ -I/opt/local/include/

CoreARTest:$(OBJS) $(TEST_OBJS)
	$(CC) -o CoreARTest $(OBJS) $(TEST_OBJS) -ljpeg -L/opt/local/lib/ -framework Accelerate

%.o:$(COREAR)%.cpp
	$(CC) -c $(CFLAGS) $<

%.o:$(TEST)%.cpp
	$(CC) -c $(CFLAGS) $<

clean:
	rm -rf $(OBJS) $(TEST_OBJS) CoreARTest

valgrind:CoreARTest
	valgrind --leak-check=full ./CoreARTest

test:valgrind