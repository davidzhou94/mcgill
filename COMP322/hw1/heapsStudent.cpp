#include "heaps.h"
#include <cstdlib>
#include <iostream>
#include <string>

Heap *recHeapFromArray(string *input, int length, int rootIndex) {
    // allocate a new heap node, the root of this sub-tree
    Heap *root = new Heap;
    // name the node
    root->name = input[rootIndex];
    // compute the index of the left child candidate
    int leftIndex = 2 * rootIndex + 1;
    // if this node has a left child
    if (leftIndex < length) {
        // recursively build the left child
        root->left = recHeapFromArray(input, length, leftIndex);
    } else {
        // otherwise null the pointer
        root->left = nullptr;
    }
    // compute the index of the right child candidate
    int rightIndex = 2 * rootIndex + 2;
    // if this node has a right child
    if (rightIndex < length) {
        // recursively build the right child
        root->right = recHeapFromArray(input, length, rightIndex);
    } else {
        // otherwise null the pointer
        root->right = nullptr;
    }
    
    return root;
}

Heap *heapFromArray(string *input, int length) {
    // build the heap recursively
    return recHeapFromArray(input, length, 0);
}

int numElements(Heap h) {
    // recursively add up the number of nodes by adding the
    // number of nodes in the left sub tree and right sub tree
    int ret = 1;
    if (h.left) { // check whether there is a left child
        // recursively add the number of elements
        // in the left sub tree
        ret += numElements(*h.left);
    }
    if (h.right) { // check if there is a right child
        // recursively add the number of elements 
        // in the right sub tree
        ret += numElements(*h.right);
    }
    return ret;
}

size_t lengthOfContent(Heap h) {
    // recursively add up the length of content in the right
    // sub tree and the left sub tree
    size_t ret = h.name.size();
    if (h.left) { // check whether there is a left child
        // recursively add the total content 
        // length in the left sub tree
        ret += lengthOfContent(*h.left);
    }
    if (h.right) { // check whether there is a right child
        // recursively add the total content 
        // length in the right sub tree
        ret += lengthOfContent(*h.right);
    }
    return ret;
}

void writeToArray(Heap *h, Heap **array, int index) {
    // allocate a new heap node
    array[index] = new Heap;
    // copy this node to the position in the array.
    array[index]->name = h->name;
    if (h->left) {
        // recursively populate the array with the left child.
        writeToArray(h->left, array, index * 2 + 1);
        array[index]->left = array[index * 2 + 1];
    } else {
        // be safe with pointers
        array[index]->left = nullptr;
    }
    if (h->right) {
        // recursively populate the array with the right child.
        writeToArray(h->right, array, index * 2 + 2);
        array[index]->right = array[index * 2 + 2];
    } else {
        array[index]->right = nullptr;
    }
}

Heap **returnAllHeaps(Heap h) {
    // create an array to return of the size of the number of 
    // elements in the heap h.
    Heap **array = new Heap*[numElements(h)];
    // use the helper function to write to the array.
    writeToArray(&h, array, 0);
    
    return array;
}

string *printLinear(Heap h) {
    // determine the length of the array needed.
    int length = numElements(h);
    // get the array of heaps in order.
    Heap **array = returnAllHeaps(h);
    // allocate the appropriate sized array of strings.
    string *ret = new string[length];

    //writeToArray(&h, ret, 0);

    // iterate through the array of heaps and assign strings.
    for (int i = 0; i < length; i++) {
        ret[i] = array[i]->name;
    }

    return ret;
}

string printSpaces(int n) {
    // prints n blank spaces into a string and returns the string
    string ret(n, ' ');
    return ret;
}

string printPretty(Heap h) {
    // get an array representation of the heap
    Heap **array = returnAllHeaps(h);
    // get the length of the array representation
    int length = numElements(h);
    string ret;               // placeholder of return value
    int levelNodeCount = 1;   // node capacity of the current level
    int endIndex = 1;         // total nodes up to the current level
    // loop through all the levels
    for (int i = 0; i < length; ) {
        // loop through each node in this level
        for (; i < endIndex && i < length; i++) {
            // if the node has a left child
            if (array[i]->left) {
                // find the content length in the left sub-tree
                int n = lengthOfContent(*array[i]->left);
                // add the length in spaces
                ret += printSpaces(n);
            }
            // add the name of the current node
            ret += array[i]->name;
            // if the node has a right child
            if (array[i]->right) {
                // find content length and append like above
                int n = lengthOfContent(*array[i]->right);
                ret += printSpaces(n);
            }
            // if the current node is a left child 
            // and it can't be the root
            if (i % 2) { 
                // find its parent and add the length of 
                // the parent's name in spaces
                int parent = (i - 1)/2;
                int n = array[parent]->name.size();
                ret += printSpaces(n);
            }
            // if the current node is a right child and not the root
            else if (i > 1) {
                int ancestor = (i - 2)/2;
                // loop on searching the ancestors, stop when we
                // are at the root node
                while (ancestor > 0) { 
                    // if the current ancestor is a left child
                    if (ancestor % 2) { 
                        // find the parent of this ancestor
                        int parent = (ancestor - 1)/2;
                        // find the length of the spaces
                        int n = array[parent]->name.size();
                        // add this space to the return and break
                        ret += printSpaces(n);
                        break;
                    } else {
                        // otherwise it's a right child and we want 
                        // to check it's parent
                        ancestor = (ancestor - 2)/2;
                    }
                }
            }
        }
        // we are at the end of the level so add a new line
        ret += "\n";
        // find the capacity of the next level
        levelNodeCount = levelNodeCount * 2;
        // find the new total number of nodes for the next level
        endIndex += levelNodeCount;
    }
    return ret;
}
