#include "huffman.h"
#include <iostream>
#include <sstream>

//QUESTION 1 - 0 credit

HuffmanTree::HuffmanHeap::HuffmanHeap(istream &instr) {
  // create a map of word counts
  map<string, int> counts;
  string word; // current word to examine
  // iterate over the words in the input stream
  while (instr >> word) {
    // increment the count for this word by 1
    counts[word] = counts[word] + 1;
  }
  // iterate over the counts in the map
  for (auto const &count : counts) {
    // push this word and its count as priority to the Heap
    TreeNode *node = new TreeNode(count.first);
    this->push(node, count.second);
  }
}

void HuffmanTree::HuffmanHeap::pop() {
  if (this->content.size() < 2) return;
  unsigned int prioritySum = 0;
  TreeNode *top1 = this->top();
  prioritySum += (*this)[top1];
  Heap::pop();
  TreeNode *top2 = this->top();
  prioritySum += (*this)[top2];
  Heap::pop();
  TreeNode *newNode = new TreeNode(top1, top2);
  Heap::push(newNode, prioritySum);
}

// QUESTION 2
void HuffmanTree::dfs(HuffmanCode& hc, TreeNode *tn, string &s) {
  if (tn->word != nullptr) {
    hc[(*tn->word)] = string(s);
  } else {
    if (tn->children[0] != nullptr) {
      s += '0';
      dfs(hc, tn->children[0], s);
      s.pop_back();
    }
    if (tn->children[1] != nullptr) {
      s += '1';
      dfs(hc, tn->children[1], s);
      s.pop_back();
    }
  }
}

//QUESTION 3
HuffmanCode::HuffmanCode(istream &input) {
  string line; // current line to examine
  // iterate over the lines in the input stream
  while (getline(input, line)) {
    stringstream words(line);
    string word;
    if (!(words >> word)) {
      throw 0;
    }
    string code;
    if (!(words >> code)) {
      throw 0;
    }
    if (code.find_first_not_of("01") != string::npos) {
      throw 0;
    }
    string temp;
    if (words >> temp) {
      throw 0;
    }
    (*this)[word] = code;
  }
}

//QUESTION 4
HuffmanTree::HuffmanTree(const HuffmanCode &hc) {
  this->root = new TreeNode;
  this->iter = this->root;
  for (auto const &e : hc) {
    string word = e.first;
    string code = e.second;
    this->resetIterator();
    for (char &c : code) {
      if (this->iter->word != nullptr) throw 1;
      if (c == '0') {
        try {
          this->moveDownOnZero();
        } catch (...) {
          this->iter->children[0] = new TreeNode;
          this->moveDownOnZero();
        }
      } else if (c == '1') {
        try {
          this->moveDownOnOne();
        } catch (...) {
          this->iter->children[1] = new TreeNode;
          this->moveDownOnOne();
        }
      } else {
        throw 2;
      }
    }
    if (this->iter->word != nullptr) throw 1;
    if (this->iter->children[0] != nullptr) throw 1;
    if (this->iter->children[1] != nullptr) throw 1;
    this->iter->word = new string(e.first);
  }
}

// QUESTION 5
void HuffmanEncoder::encode(istream &fin, ostream &fout) const {
  string word; // current word to examine
  // iterate over the words in the input stream
  while (fin >> word) {
    // check whether this word is in the dictionary
    if (this->code.count(word) < 1) {
      throw 1;
    }
    fout << this->code.at(word);
  }
}

//QUESTION 5
void HuffmanDecoder::push(istream &f) {
  this->resetIterator();
  char c; // current char to examine
  const string *word; // decoded word
  // iterate over the chars in the input stream  
  while (f.get(c)) {
    try {
      if (c == '0') {
        this->moveDownOnZero();
      } else if (c == '1') {
        this->moveDownOnOne();
      } else {
        throw 2;
      }
    } catch (int e) {
      if (e == 2) throw 0;
      try {
        word = this->getWordFromIter();
      } catch (...) {
        throw 1;
      }
      savedWords.push(word);
      this->resetIterator();
      switch (e) {
        case 0: 
          this->moveDownOnZero();
          break;
        case 1:
          this->moveDownOnOne();
          break;
        default:
          throw e;
      }
    }
  }
  try {
    word = this->getWordFromIter();
    savedWords.push(word);
  } catch (...) {
    throw 1;
  }
}
