#include <iostream>
#include <vector>
#include <sstream>

#include "priorities.h"

using namespace std;


int main() {
    // test the printing method (0-credit)
    vector<string> maBands = {"Led Zeppelin", "The Beatles", "Pink Floyd", "Queen", "Metallica","ACDC", "Rolling Stones", "Guns N' Roses", "Nirvana", "The Who", "Linkin Park", "Green Day", "Black Sabbath", "RHCP"};
    Heap bandsHeap(maBands);
    cout << "-------------------------------" << endl;
    cout << "-Testing printing method...   -" << endl;
    cout << "-------------------------------" << endl;
    cout << bandsHeap << endl;
    // --------------------
    // test Q3
    cout << "-------------------------------" << endl;
    cout << "- Testing print linear  ...   -" << endl;
    cout << "-------------------------------" << endl;
    for(auto &s : bandsHeap.printLinear()) {
        cout << s << " " << flush;
    }cout << endl;
    // --------------------
    // test Q4
    cout << "-------------------------------" << endl;
    cout << "- Testing operator  []  ...   -" << endl;
    cout << "-------------------------------" << endl;
    for(auto &s : maBands) {
        cout << s << " has priority " <<  bandsHeap[s] << endl;
    }
    // --------------------
    // test Q5
    cout << "-------------------------------" << endl;
    cout << "- Testing heapify up    ...   -" << endl;
    cout << "-------------------------------" << endl;
    Heap h;
    cout << "- Pusing A with priority 3...   -" << endl;
    h.push("A", 3);
    cout << h << endl;
    for(auto &s : h.printLinear()) {
        cout << s << " " << flush;
    }cout << endl;
    cout << "- Pusing B with priority 8...   -" << endl;
    h.push("B", 8);
    cout << h << endl;
    for(auto &s : h.printLinear()) {
        cout << s << " " << flush;
    }cout << endl;
    cout << "- Pusing C with priority 10...   -" << endl;
    h.push("C", 10);
    cout << h << endl;
    for(auto &s : h.printLinear()) {
        cout << s << " " << flush;
    }cout << endl;
    cout << "- Pusing D with priority 4...   -" << endl;
    h.push("D", 4);
    cout << h << endl;
    for(auto &s : h.printLinear()) {
        cout << s << " " << flush;
    }cout << endl;
    cout << "- Pusing E with priority 5...   -" << endl;
    h.push("E", 5);
    cout << h << endl;
    for(auto &s : h.printLinear()) {
        cout << s << " " << flush;
    }cout << endl;
    cout << "- Pusing F with priority 2...   -" << endl;
    h.push("F", 2);
    cout << h << endl;
    for(auto &s : h.printLinear()) {
        cout << s << " " << flush;
    }cout << endl;
    cout << "- Pusing G with priority 1...   -" << endl;
    h.push("G", 1);
    cout << h << endl;
    for(auto &s : h.printLinear()) {
        cout << s << " " << flush;
    }cout << endl;
    cout << "-------------------------------" << endl;
    cout << "- Testing operator  +=  ...   -" << endl;
    cout << "-------------------------------" << endl;
    vector<string> strings = {"a", "b", "c", "d", "e", "f"};
    Heap h2(strings);
    h2 += h;
    cout << h2 << endl;
    for(auto &s : h2.printLinear()) {
        cout << s << " " << flush;
    }cout << endl;
    // --------------------
    // test Q6
    cout << "-------------------------------" << endl;
    cout << "- Testing heapify down...     -" << endl;
    cout << "-------------------------------" << endl;
    cout << "The order of the removal should be: G F A D E B C" << endl;
    while (!h.empty()) {
        cout << "------" << endl << h << endl << "------" << endl;
        for(auto &s : h.printLinear()) {
            cout << s << " " << flush;
        }cout << endl;
        h.pop();
    }
    
    // --------------------
    // test Q7
    cout << "-------------------------------------------" << endl;
    cout << "- Testing input stream constructor...     -" << endl;
    cout << "-------------------------------------------" << endl;
    string woolf("What a lark! What a plunge! For so it always seemed to me when, with a little squeak of the hinges, which I can hear now, I burst open the French windows and plunged at Bourton into the open air. How fresh, how calm, stiller than this of course, the air was in the early morning; like the flap of a wave; the kiss of a wave; chill and sharp and yet (for a girl of eighteen as I then was) solemn, feeling as I did, standing there at the open window, that something awful was about to happen...");
    istringstream virginia(woolf);
    Heap adeline(virginia);
    for(auto &s : adeline.printLinear()) {
        cout << s << " " << flush;
    }cout << endl;
    
    return 0;
}
