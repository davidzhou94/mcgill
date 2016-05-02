all: testytest

testytest:
	$ g++ -g -std=c++11 prioritiesTest.cpp prioritiesStudent.cpp priorities.h

gradygrade:
	$ g++ -g -std=c++11 -o gradygrade prioritiesGrading.cpp prioritiesStudent.cpp priorities.h

clean: 
	rm -rf *.o testytest gradygrade
