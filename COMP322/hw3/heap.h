
#ifndef heap_h
#define heap_h

#include <vector>
#include <unordered_map>
#include <string>

using namespace std;


template <class T>
class Heap {
protected:
    // ----
    // Nodes
    struct Node {
        unsigned int priority;
        const T *data;
    };
    // ----
    // Content -> pointers to nodes
    vector<Node *> content;
    typedef typename vector<Node *>::size_type heapIndex;
    // default constructor
    // ---- map of existing Nodes
    unordered_map<T, Node> items;
    // default constructor
    // ---- private methods
    void swap(Node* &a, Node* &b);
    void heapifyUp(heapIndex);
    void heapifyDown(heapIndex);
    // ----
public:
    // ---------
    // default constructor
    Heap() {} //default constructor
    // ---------
    // ----- top() ------
    // returns the element with best priority
    // EXEPT: throws 0 if the heap is empty
    T top() const;
    // ---------
    // ----- empty() ------
    // returns true only if there are no elements in the heap
    bool empty() const;
    // ---------
    // ----- push(T, unsigned int) -----
    // inserts the element 'data' in the heap with the given priority
    // the method performs heapify up
    // if item is already there, will not push it again.
    void push(T data, unsigned int priority);
    // ---------
    // ----- pop() -----
    // removes the top element and heapifies down the last element in the heap.
    // does not do anything if the heap is empty
    void pop();
    // ---------
    // ----- operator[] ----
    // returns the priority of the element
    // EXEPT: throws 0 if the heap does not contain that element
    unsigned int operator[](T) const;
};


// -------------------------------------------- //
// ---------------HEAP IMPLEMENTATION----------- //
// -------------------------------------------- //
template <class T>
void Heap<T>::swap(Node* &a, Node* &b){
    Node *tmp;
    tmp = a;
    a = b;
    b = tmp;
}

template <class T>
void Heap<T>::heapifyUp(Heap<T>::heapIndex index) {
    // base case and invalid input
    if (index == 0 || index >= content.size()) return;
    
    // get items to compare
    auto &child = content[index];
    auto indexParent = (index - 1) / 2;
    auto &parent = content[indexParent];
    
    // swap if heap property is violated
    if(child->priority < parent->priority){
        swap(child, parent);
        // recursively heapify up the item at index of parent
        heapifyUp(indexParent);
    }
}

template <class T>
void Heap<T>::heapifyDown(Heap<T>::heapIndex index) {
    // save length
    auto length = content.size();
    // ----
    // base case
    if (2 * index + 1 >= length ) return;
    // ----
    // find index of best priority
    auto indexOfBest = index;
    auto indexLeft = 2*index + 1;
    auto indexRight = 2*index + 2;
    // if priority of left child is better than the current best, update best
    if (content[indexLeft]->priority < content[indexOfBest]->priority) {
        indexOfBest = indexLeft;
    }
    // ----
    // if right child exists and its priority is better than the current best, update best
    if (indexRight < length &&
        content[indexRight]->priority < content[indexOfBest]->priority) {
        indexOfBest = indexRight;
    }
    // ----
    // if bestIndex changed, swap content at the best index with the index of the parent
    if (indexOfBest != index) {
        swap(content[indexOfBest], content[index]);
        // recursively heapify down content
        heapifyDown(indexOfBest);
    }
}

template <class T>
T Heap<T>::top() const {
    if(empty()) throw 0;
    return *(content[0]->data); 
}


template <class T>
bool Heap<T>::empty() const { return content.empty(); }

template <class T>
void Heap<T>::push(T data, unsigned int priority) {
    // if item is already there, will not push it again.
    if (items.find(data) != items.end()) return;
    auto insertionResult = items.insert(make_pair(data, Node()));
    if (!insertionResult.second) return;
    // get the insertion result
    const T &insertedString = insertionResult.first->first;
    Node &insertedNode = insertionResult.first->second;
    // set data
    insertedNode.data = &insertedString;
    // set priority
    insertedNode.priority = priority;
    
    
    // push the Node at the end of the content list
    content.push_back(&insertedNode);
    
    // the heap priority might be violated. Use heapify up to fix this
    heapifyUp(content.size()-1);
}

template <class T>
void Heap<T>::pop() {
    // save the data at the top
    auto toRet = content.front()->data;
    // store data at the last element to the top
    content.front() =  content.back();
    
    
    //remove the item from the map
    items.erase(items.find(*toRet));
    // remove the last element in content
    content.pop_back();
    
    // heapify down the top element
    heapifyDown(0);
}

template <class T>
unsigned int Heap<T>::operator[](T s) const {
    // search for element and return the priority
    auto item = items.find(s);
    if (item != items.end()){
        return item->second.priority;
    } else throw 0;
}


#endif /* heap_h */
