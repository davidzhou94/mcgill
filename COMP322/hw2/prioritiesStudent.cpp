//QUESTION 1

#include "priorities.h"
#include <iostream>
#include <vector>
#include <map>
#include <sstream>

//QUESTION 1

Heap::Heap(const vector<string> & dataToAdd) {
  // loop through the dataToAdd and add each element to the heap
  for (int i = 0; i < dataToAdd.size(); i++) {
    // create a node and copy the information
    Node *n = new Node;
    n->priority = i;
    n->data = dataToAdd[i];
    // push to back of content vector
    this->content.push_back(*n);
  }
}

Heap::Heap(const Heap& h) {
  // loop through the content of the given heap
  for (int i = 0; i < h.content.size(); i++) {
    // create a node and copy the information
    Node *n = new Node;
    n->priority = h.content[i].priority;
    n->data = h.content[i].data;
    // push to back of content vector
    this->content.push_back(*n);
  }
}

//Question 2

size_t Heap::lengthOfContent(unsigned long index) const {
  // count the lenth of the name of current node
  size_t num = this->content[index].data.length();
  // ----
  int leftChild = 2 * index + 1;
  if (leftChild < this->content.size()) {
    // count the length of the content the left heap recursively
    num += lengthOfContent(leftChild);
    // ----
    if (leftChild + 1 < this->content.size()) {
      // count the length of the content the left heap recursively
      num += lengthOfContent(leftChild + 1);
    }
  }
  // return the calculated value
  return num;
}

ostream &operator<<(ostream & out, const Heap& h) {
  // we will need the number of elements
  int length = h.content.size();
  // elementsPerRowToDo counts the number of elements that have to
  // be printed per row. It starts at 1, and then it doubles
  // on every other row... 1,2,4,8,16,etc.
  int elementsPerRowToDo = 1;
  // elementsPerRowDone counts the number of elements that have
  // already been printed on each row. When this value reaches
  // elementsPerRowToDo, then we go to the next row
  int elementsPerRowDone = 0;
  // print all elements in the order returned by returnAllHeaps
  for (int ada = 0; ada < length; ada++) {
    // print white spaces for the left sub-tree
    if (2 * ada + 1 < length) {
      // use lengthOfContent to know how many white spaces to print
      size_t whiteSpaces = h.lengthOfContent(2 * ada + 1);
      // output enough spaces to out
      for (int bee = 0; bee < whiteSpaces; bee++) {
        out << " ";
      }
    }
    // print name of current node
    out << h.content[ada].data;
    // print white spaces for the right sub-tree
    if (2 * ada + 2 < length) {
      // use lengthOfContent to know how many white spaces to print
      size_t whiteSpaces = h.lengthOfContent(2 * ada + 2);
      // output enough spaces to out
      for (int bee = 0; bee < whiteSpaces; bee++) {
        out << " ";
      }
    }
    // element was printed.
    elementsPerRowDone++;
    // What next? New row, or skip space for a node above
    if (elementsPerRowDone == elementsPerRowToDo) {
      // next tow has to print double the amount of nodes
      elementsPerRowToDo *= 2;
      // reset the counter elementsPerRowDone
      elementsPerRowDone = 0;
      // output a newline to out
      out << "\n";
    } else {
      // find the node above for which we need to leave space
      // go up on the tree to the grand-grand-parents until one
      // is the parent of a left child
      int kid = ada; // start at current node
      // go up while kid is a right child
      // note that all right childen have even index
      while(kid % 2 == 0 /* kid is a right child */ ) {
        kid = (kid - 1) / 2; // go up to the parent
      }
      // found the ascendant for which we have to print white space
      int parent  = (kid - 1) / 2;
      // get length of parent's name
      size_t whiteSpaces = h.content[parent].data.length();
      // output enough spaces to out
      for (int bee = 0; bee < whiteSpaces; bee++) {
        out << " ";
      }
    } // end if...else on elementsPerRowDone
  } // end of for loop
  return out;
}

//QUESTION 3

vector<string> Heap::printLinear() const{
  // declare a variable to return
  vector<string> ret;
  // loop through each Node in the content vector
  for (int i = 0; i < this->content.size(); i++) {
    // append each piece of the string according to the 
    // desired format
    string s ("(");
    s += this->content[i].data;
    s += ", ";
    s += to_string(this->content[i].priority);
    s += ")";
    // push the string to the back of the vector
    ret.push_back(s);
  }
  // return the vector to return
  return ret;
}

//QUESTION 4

unsigned int Heap::operator[](string s) const{
  // loop through each Node in the content vector
  for (int i = 0; i < this->content.size(); i++) {
    // check whether this is the data in this Node matches the
    // given string
    if (s.compare(this->content[i].data) == 0) {
      // return the priority
      return this->content[i].priority;
    }
  }
  // if not found, we return 0
  return 0;
}

//QUESTION 5

void Heap::heapifyUp(unsigned long index) {
  // if we are out of bounds, return
  if (index <= 0) return;
  // compute where to find the parent depending on the parity 
  // of the index (even is right child, odd is left)
  unsigned long parent;
  // index is even is a right child
  if (index % 2 == 0) {
    // find the parent
    parent = (index - 2) / 2;
  } else {
    // find the parent
    parent = (index - 1) / 2;
  }
  // swap if the current index Node has a higher priority than
  // the parent
  if (this->content[index].priority < 
      this->content[parent].priority) {
    // do the swap
    this->swap(this->content[index], this->content[parent]);
  }
  // recursively heap up the parent
  heapifyUp(parent);
}

void Heap::push(string data, unsigned int priority) {
  // check whether the string being pushed already exists, return
  // if it does exist
  if (this->has(data)) return;
  // create a new Node and copy over the data and priority
  Node *n = new Node;
  n->data = data;
  n->priority = priority;
  // push the Node to the back of the content vector
  this->content.push_back(*n);
  // find the index of this node in the content vector
  unsigned long index = this->content.size() - 1;
  // enforce the heap property on this insertion
  this->heapifyUp(index);
}

Heap& Heap::operator+=(const Heap& h) {
  // loop through all the elements of the given Heap
  for (int i = 0; i < h.content.size(); i++) {
    // push the current Node onto this heap
    this->push(h.content[i].data, h.content[i].priority);
  }
  // return this heap
  return *this;
}

// QUESTION 6

void Heap::heapifyDown(unsigned long index) {
  // if the index is out of bounds, return
  if (index >= this->content.size()) return;
  // compute the index of the left child
  unsigned long leftChild = 2 * index + 1;
  // check whether the right child is out of bounds
  if (leftChild + 1 < this->content.size()) {
    // check whether the left child has a higher priority than the
    // parent and the right child
    if (this->content[leftChild].priority < 
        this->content[index].priority &&
        this->content[leftChild].priority <=
        this->content[leftChild + 1].priority) {
      // swap the left child with the parent
      this->swap(this->content[leftChild], this->content[index]);
      // recursively heap down on the left child and return
      heapifyDown(leftChild);
      return;
    }
    // check whether the right child has a higher priority than 
    // the parent and the left child
    if (this->content[leftChild + 1].priority < 
        this->content[index].priority &&
        this->content[leftChild + 1].priority <=
        this->content[leftChild].priority) {
      // swap the right child with the parent
      this->swap(this->content[leftChild + 1], this->content[index]);
      // recursively heap down on the right child and return
      heapifyDown(leftChild + 1);
      return;
    }
  }
  // we are here because the right child is out of bounds, 
  // now we check whether the left child is still in bounds
  if (leftChild < this->content.size()) {
    // check whether the left child has higher priority than
    // the parent
    if (this->content[leftChild].priority < 
        this->content[index].priority) {
      // swap the left child and the parent
      this->swap(this->content[leftChild], this->content[index]);
      // left child must have been the last node if we are in
      // this case so no need to recursively call heapifyDown
      // and we are done
      return;
    }
  }
}

string Heap::pop() {
  // set the return value to the data at the front of the Heap
  string ret = this->content.front().data;
  // swap the front and the back
  this->swap(this->content.front(), this->content.back());
  // remove the back (pop it)
  this->content.pop_back();
  // ensure the heap property by heaping down the front of the Heap
  this->heapifyDown(0);
  // return the value to return
  return ret;
}

// QUESTION 7

Heap::Heap(istream &in) {
  // create a map of word counts
  map<string, int> counts;
  string word; // current word to examine
  // iterate over the words in the input stream
  while (in >> word) {
    // increment the count for this word by 1
    counts[word] = counts[word] + 1;
  }
  int max = 0; // current max count
  // iterate over the counts in the map
  for (auto const &count : counts) {
    // if the current count is bigger, update max
    max = (count.second > max) ? count.second : max;
  }
  // iterate over the counts in the map
  for (auto const &count : counts) {
    // push this word and its count priority to the Heap
    this->push(count.first, max - count.second);
  }
}