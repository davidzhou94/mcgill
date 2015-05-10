import java.util.*;
import java.io.*;


// This is the class use to store all the local variables 
// within the recursive version of the fibonacci method
class ProgramFrame {
    int n;
    int firstFib;
    int secondFib;
    int PC;
   
    // Constructor
    public ProgramFrame(int myN, int myFirstFib, int mySecondFib, int myPC) {
	n = myN;
	firstFib = myFirstFib;
	secondFib = mySecondFib;
	PC = myPC;
    }

    // returns a String describing the content of the object
    public String toString() {
	return "ProgramFrame: n = " + n + " firstFib = " + firstFib + " secondFib = " + secondFib + " PC = " + PC;
    }
    
}


class FibonacciNonRecursive {

    // This is the stack we will use to store the set of ProgramFrame mimicking the recursive calls
    static Stack<ProgramFrame> callStack;

    // Our non-recursive version of the fibonacci method, using a stack to mimick recursion
    static int fibonacci(int n) {
	
	// the stack will use
	callStack = new Stack<ProgramFrame>();
	
	// the initial program frame
	ProgramFrame current = new ProgramFrame(n,0,0,1); 

	// put that frame on the stack
	callStack.push(current);

	int result = 0; // eventually, this will contain the answer

	// As long as our recursion stack is not empty...
	while (!callStack.empty()) {

	    // for debugging purposes
	    System.out.println(callStack);

	    // our base cases
	    if (callStack.peek().PC == 1) {
		if (callStack.peek().n<= 1) {
		    result = callStack.peek().n;

		    // we are done with that frame
		    callStack.pop(); 
		    
		    // if there is nothing left on the stack, we are done
		    if (callStack.empty()) break;
		    
		    // update firstFib or secondFib, depending on PC
		    if (callStack.peek().PC == 2) callStack.peek().firstFib = result; 
		    if (callStack.peek().PC == 3) callStack.peek().secondFib = result; 
		    
		    // move PC up by one
		    callStack.peek().PC++;
		}
		else {// not in the base case
		    callStack.peek().PC++;
		}
		continue;
	    }

	    // This corresponds to the recursive call firstFib=Fib(n-1)
	    if (callStack.peek().PC == 2) {
		
		// create a new program frame, corresponding to the recursive call
		current = new ProgramFrame(callStack.peek().n-1,callStack.peek().firstFib,callStack.peek().secondFib,1);
		callStack.push(current);
		continue;
	    }
	    
	    // This corresponds to the recursive call firstFib=Fib(n-2)
	    if (callStack.peek().PC == 3) {
		current = new ProgramFrame(callStack.peek().n-2,callStack.peek().firstFib,callStack.peek().secondFib,1);
		callStack.push(current);
		continue;
	    }

	    // This corresponds to the portion of the recursive algorithm where we add up and return firstFib + secondFib
	    if (callStack.peek().PC == 4) {
		result  =  callStack.peek().firstFib + callStack.peek().secondFib;

		callStack.pop();
		if (!callStack.empty()) {
		    // update firstFib or secondFib, depending on PC
		    if (callStack.peek().PC == 2) callStack.peek().firstFib  =  result; 
		    if (callStack.peek().PC == 3) callStack.peek().secondFib  =  result; 
		    // move PC up by one
		    callStack.peek().PC++;
		    continue;
		}
	    }
	}
	// we are done, just return result
	return result;
    }
    

    
    public static void main (String args[]) throws Exception {
	
	int n = 9;
	System.out.println("Fib("+n+")  =  "+fibonacci(n));

    }
}

	