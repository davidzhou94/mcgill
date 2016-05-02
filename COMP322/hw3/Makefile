all: testytest

testytest:
	$ g++ -g -std=c++11 -o testytest huffmanTest.cpp huffmanStudent.cpp huffman.h

gradygrade:
	$ g++ -std=c++11 -o gradygrade huffmanGrading.cpp huffmanStudent.cpp huffman.h

testytestmac:
	$ clang++ -std=c++11 -stdlib=libc++ huffmanTest.cpp huffmanStudent.cpp huffman.h

clean: 
	rm -rf *.o testytest gradygrade
