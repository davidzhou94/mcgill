#include "heaps.h"
#include <iostream>


int main() {
    // input for testing
    string maBands[] = {"Led Zeppelin", "The Beatles", "Pink Floyd", "Queen", "Metallica","ACDC", "Rolling Stones", "Guns N' Roses", "Nirvana", "The Who", "Linkin Park", "Green Day", "Black Sabbath", "RHCP"};
    int numBands = 14; // if you change maBands, make sure you update this!!!
    
    // creat heap
    Heap *heapOfBands = heapFromArray(maBands, numBands);
    
    // test number of elements
    cout << "-------------------------------" << endl;
    cout << "-Testing number of elements...-" << endl;
    cout << "-------------------------------" << endl;
    cout << numElements(*heapOfBands) << endl;

    // test lenght of content
    cout << "------------------------------" << endl;
    cout << "-Testing length of content...-" << endl;
    cout << "------------------------------" << endl;
    cout << "Length of content should be 129" << ". My code gives " << lengthOfContent(*heapOfBands) << "." << endl;

    // test linear print
    cout << "-------------------------" << endl;
    cout << "-Testing linear print...-" << endl;
    cout << "-------------------------" << endl;
    cout << "It should be: " << endl;
    for (int i=0; i< numBands; i++) {
        cout << maBands[i] << " ";
    }cout << endl;
    
    cout << "Code gives: " << endl;
    string *pl = printLinear(*heapOfBands);
    for (int i=0; i<14; i++) {
        cout << pl[i] << " ";
    }cout << endl;
    
    
    // test pretty print
    cout << "------------------------------" << endl;
    cout << "-Testing length of content...-" << endl;
    cout << "------------------------------" << endl;
    cout << endl << printPretty(*heapOfBands) << endl;
}



