import java.util.Stack;
import java.lang.Math;


class ProgramFrame {
	int start;
	int stop;
	int PC;
	int a[];
	public ProgramFrame(int myArray[],int myStart,int myStop,int myPC) {
		a=myArray;
		start=myStart;
		stop=myStop;
		PC=myPC;
	}
	// returns a String describing the content of the object
	public String toString() {
		return "ProgramFrame: start = " + start + " stop = " + stop + " PC = " + PC;
	}
}


class MergeSortNonRecursive {

	static Stack<ProgramFrame> callStack;

	// this implement the merge algorithm seen in class. Feel free to call it.
	public static void merge(int A[], int start, int mid, int stop) 
	{
		int index1=start;
		int index2=mid+1;
		int tmp[]=new int[A.length];
		int indexTmp=start;

		while (indexTmp<=stop) {
			if (index1<=mid && (index2>stop || A[index1]<=A[index2])) {
				tmp[indexTmp]=A[index1];
				index1++;
			}
			else {
				if (index2<=stop && (index1>mid || A[index2]<=A[index1])) {
					tmp[indexTmp]=A[index2];
					index2++;
				}
			}
			indexTmp++;
		}
		for (int i=start;i<=stop;i++) A[i]=tmp[i];
	}


	static void mergeSort(int A[]) {
		callStack = new Stack<ProgramFrame>();
		ProgramFrame current=new ProgramFrame(A,0,A.length-1,1);
		callStack.push(current);
		while (!callStack.empty()) {
			System.out.println(callStack);
			if (callStack.peek().PC==1) {
				if (!(callStack.peek().start<callStack.peek().stop)){
					callStack.pop();
					callStack.peek().PC++;
				}
				else callStack.peek().PC++;
				continue;
			}
			int mid = (int) Math.floor((callStack.peek().start+callStack.peek().stop)/2);
			if (callStack.peek().PC==2) {
				current=new ProgramFrame(callStack.peek().a,callStack.peek().start,mid,1);
				callStack.push(current);
				continue;
			}
			if (callStack.peek().PC==3) {
				current=new ProgramFrame(callStack.peek().a,mid+1,callStack.peek().stop,1);
				callStack.push(current);
				continue;
			}
			if (callStack.peek().PC==4) {
				merge(callStack.peek().a,callStack.peek().start,mid,callStack.peek().stop);
				callStack.pop();
				if (!callStack.empty()) callStack.peek().PC++;
			}
		}
	}

	public static void main (String args[]) throws Exception {
		// just for testing purposes
		int myArray[]={3,1,4,5,9,2,6,5,3,5,8,9,7,9,3,2,3,8,4,6,2,6};
		mergeSort(myArray);
		System.out.println("Sorted array is:\n");
		for (int i=0;i<myArray.length;i++) {
			System.out.print(myArray[i]+" ");
		}
		System.out.println();
	}
}