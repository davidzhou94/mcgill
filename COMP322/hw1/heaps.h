
#ifndef heaps_h
#define heaps_h

#include <string>

using namespace std;

/** 0-credit question */
/* We will use a struct named Heap to store the contents of a heap based on the tree structure. That is: */

struct Heap {
    string name;
    Heap *left = nullptr;
    Heap *right = nullptr;
};

/* Write a function that takes as input an array of strings and returns the Heap struct built using the strategy in Question 1. If a node does not have a left or a right child, the pointer that corresponds to the missing child should be equal to null pointer (i.e. left = nullptr;). The declaration of the function is: */

Heap *heapFromArray(string *input, int length);


/** QUESTION 3 ***/
/* Write a function that takes as input a Heap struct and returns the number of elements in that heap. The declaration of the function is:
 */

int numElements(Heap h);


/** QUESTION 4 ***/
/* Write a function that takes as input a Heap struct and returns sum of the lengths of all the strings in that heap. The declaration of the function is: */

size_t lengthOfContent(Heap h);

/** QUESTION 5 ***/
/* Write a function that takes as input a Heap struct and returns the content of the heap as an array, based on the following property:
 - the item at position 0 is the head of the heap.
 - the item at position i in the returned array has the items at positions 2*i+1 and 2*i+2, as the left child and as the right child, respectively.
 
 The declaration of the function is: */

string *printLinear(Heap h);


/** QUESTION 6 ***/
/* Write a function that takes as input a Heap struct and return a single string that represents a visual representation of the heap that follows the following characteristics: 
        - prints items at level k on the (k + 1)th line.
        - all content in the left heap is horizontally to the left of the content of a node.
        - all content in the left heap is horizontally to the right of the content of a node.
 Note that to do this you have to print just enough white spaces before you print the content of a node. To know how many white spaces you need to print to the left of the content, you can use the functions in Questions 1 to 4. The declaration of the function is:
 */

string printPretty(Heap h);


#endif /* heaps_h */
