#include <string>
#include <vector>

using namespace std;

class Heap {
private:
    struct Node {
        unsigned int priority;
        string data;
    };
    vector<Node> content;
    
    void swap(Node &n1, Node &n2){
        Node tmp;
        tmp.data = n2.data;
        tmp.priority = n2.priority;
        n2.data = n1.data;
        n2.priority = n1.priority;
        n1.data = tmp.data;
        n1.priority = tmp.priority;
    }
    
    size_t lengthOfContent(unsigned long) const;
    
    void heapifyUp(unsigned long);
    void heapifyDown(unsigned long);
    
public:
    Heap() {} //default constructor
    Heap(const vector<string> &); //Heap from array
    Heap(const Heap&); //copy constructor
    Heap(istream &); //constructor that reads all words from a file
    
    string top() const { return (content.empty()) ? "" : content[0].data; }
    
    bool has(string s) const {
        for(auto &n : content) {
            if(n.data == s) return true;
        }
        return false;
    }
    
    bool empty() const { return content.empty(); }
    
    void push(string, unsigned int);
    string pop();
    
    vector<string> printLinear() const;
    
    unsigned int operator[](string) const;
    Heap & operator+=(const Heap&);
    
    friend ostream &operator<<(ostream &, const Heap&);
    
};


// Question 2

ostream &operator<<(ostream &, const Heap& h);

