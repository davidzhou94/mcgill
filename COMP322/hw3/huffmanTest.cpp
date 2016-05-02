#include "huffman.h"
#include <iostream>
#include <sstream>

using namespace std;

int main() {

    // test the dfs method
    string simple = "TheBeatles TheBeatles LedZeppelin LedZeppelin Queen TheBeatles LedZeppelin TheBeatles TheBeatles LedZeppelin TheBeatles TheBeatles TheBeatles Nirvana Queen";
    istringstream syrup(simple);
    cout << "-------------------------------" << endl;
    cout << "- Testing dfs...              -" << endl;
    cout << "-------------------------------" << endl;
    HuffmanTree htSimple(syrup);
    HuffmanCode hcDFS = htSimple.getCode();
    for(auto entry : hcDFS) {
        cout << entry.first << " " << entry.second << endl;
    }
    cout << "- The output should be the following, or the negative (0s replaced with ones)-" << endl;
    cout << "LedZeppelin 01\nNirvana 000\nQueen 001\nTheBeatles 1" << endl;
    
    // test the Huffman Code form input string
    cout << "-------------------------------" << endl;
    cout << "- Testing Huffman Code...     -" << endl;
    cout << "-------------------------------" << endl;
    string abcd = "a 0\nb 10\nc 110\nd 111\n";
    istringstream hcinputstream(abcd);
    HuffmanCode hcFromInput(hcinputstream);
    for(auto entry : hcFromInput) {
        cout << entry.first << " " << entry.second << endl;
    }
    cout << "- The output should be the following, " << endl << abcd;
    
    // test the encode method
    cout << "-------------------------------" << endl;
    cout << "- Testing encoding...         -" << endl;
    cout << "-------------------------------" << endl;
    // test Huffman Encoder
    HuffmanEncoder he(hcFromInput);
    istringstream syrup2("a a b b a a c c d d");
    ostringstream squeeze;
    he.encode(syrup2, squeeze);
    cout << squeeze.str() << endl;
    cout << "- The output should be the following, " << endl;
    cout << "00101000110110111111" << endl;
    
    
    // test the Huffman Tree from Huffman Code
    cout << "-------------------------------" << endl;
    cout << "- Testing Trees from Codes... -" << endl;
    cout << "-------------------------------" << endl;
    HuffmanTree ht2(hcFromInput);
    for(auto entry : ht2.getCode()) {
        cout << entry.first << " " << entry.second << endl;
    }
    
    
    // test Huffman Decoder
    cout << "-------------------------------" << endl;
    cout << "- Testing decoder...          -" << endl;
    cout << "-------------------------------" << endl;
    HuffmanDecoder hd(hcFromInput);
    istringstream syrup3("00101000110110111111");
    hd.push(syrup3);
    try {
        while (true) {
            cout << hd.next() << " ";
        }
    }catch(int) {
        // DONE poping;
        cout << endl;
    }
    cout << "- The output should be the following, " << endl;
    cout << "a a b b a a c c d d" << endl;
    cout << endl;
    
    
    cout << "-------------------------------" << endl;
    cout << "- Testing woolf...            -" << endl;
    cout << "-------------------------------" << endl;
    
    
    string woolf("What a lark! What a plunge! For so it always seemed to me when, with a little squeak of the hinges, which I can hear now, I burst open the French windows and plunged at Bourton into the open air. How fresh, how calm, stiller than this of course, the air was in the early morning; like the flap of a wave; the kiss of a wave; chill and sharp and yet (for a girl of eighteen as I then was) solemn, feeling as I did, standing there at the open window, that something awful was about to happen...");
    // simulate a file containing this text
    istringstream virginia(woolf);
    
    // create a decoder based on this text
    HuffmanDecoder hdv(virginia);
    
    // get code
    HuffmanCode hcv = hdv.getCode();
    
    // create an encoder based on the code corresponding to the text
    HuffmanEncoder hev(hcv);
    
    // encode text
    istringstream syrupv(woolf);
    ostringstream squeezev;
    hev.encode(syrupv, squeezev);
    istringstream syrupvw(squeezev.str());
    hdv.push(syrupvw);
    
    // decode text
    try{
        while (true)
            cout << hdv.next() << " ";
    }catch(int) {
        // DONE poping;
        cout << endl;
    }
    
    
    // not prefix code
   try {
       string abcd34 = "a 0\nb 11\nc 110\nd 111\n";
       istringstream hcinputstream34(abcd34);
       cout << "istringstream gets executed" << endl;
       HuffmanCode hcFromInput34(hcinputstream34);
       cout << "normally the HuffmanCode constructor throws an error" << endl; //THE WAY I WROTE MY HuffmanCode constructor
       
       // change hcFromInput34
       //hcFromInput34.insert(std::pair<string,string>("e","11"));
       
       
       HuffmanTree ht234(hcFromInput34);
       for(auto entry : ht234.getCode()) {
           cout << entry.first << " " << entry.second << endl;
       }

   }
   catch(int) {
       cout << "Code not a prefix code" << endl;
   }
   return 0;
}



// Other implementations






