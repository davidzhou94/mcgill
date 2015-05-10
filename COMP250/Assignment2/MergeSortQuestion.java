import java.util.*;
import java.io.*;


// No need to change anything in this class
class MergeSortQuestion {

    // merges sorted subarrays A[start...firstThird], A[firstThird+1,secondThird], and A[secondThird+1,stop]
    public static void mergeThreeWay(int A[], int start, int firstThird, int secondThird, int stop) 
    {
    	int tempIndex=start;
    	int i1=start;
    	int i2=firstThird;
    	int i3=secondThird;
    	int tempVal = 0;
    	int tempArray[]=new int[A.length];
    	boolean enter=true;
    	System.out.println("start: "+start);
    	System.out.println("stop: "+stop);
    	System.out.println("s1: "+firstThird);
    	System.out.println("s2: "+secondThird);
    	System.out.println("i1: "+i1);
    	System.out.println("i2: "+i2);
    	System.out.println("i3: "+i3);
    	while (tempIndex<=stop){
    		System.out.println("tempI: "+tempIndex);
        	System.out.println("i1: "+i1);
        	System.out.println("i2: "+i2);
        	System.out.println("i3: "+i3);
        	if (i3>stop && i1<firstThird && i2<secondThird) tempVal=Math.min(A[i1], A[i2]);
        	else if (i3>stop && i1>=firstThird && i2<secondThird) tempVal=A[i2];
        	else if (i3>stop && i2>=secondThird && i1<firstThird) tempVal=A[i1];
        	else if (i3<=stop && i2>=secondThird && i1>=firstThird) tempVal=A[i3];
        	else if (i3<=stop && i2<secondThird && i1>=firstThird) tempVal=Math.min(A[i2], A[i3]);
        	else if (i3<=stop && i2>=secondThird && i1<firstThird) tempVal=Math.min(A[i1], A[i3]);
        	else if (i3<=stop && i2<secondThird && i1<firstThird) tempVal=Math.min(A[i1], Math.min(A[i2], A[i3]));
        	else enter=false;
        	if (enter) {
        		if (A[i1]==tempVal && i1<i2 ) {
            		tempArray[tempIndex]=A[i1];
            		i1++;
            	}
            	else if (A[i2]==tempVal && i2<i3) {
            		tempArray[tempIndex]=A[i2];
            		i2++;
            	}
            	else if (A[i3]==tempVal) {
            		tempArray[tempIndex]=A[i3];
            		i3++;
            	}
        	}
        	tempIndex++;
    	}
    	for (int i=start;i<=stop;i++) A[i]=tempArray[i];
    	
    }



    // sorts A[start...stop]
    public static void mergeSortThreeWay(int A[], int start, int stop) {
    	
    	int thirtyThree;
    	int sixtySeven;
    	int temp;
    	if (start+1<stop) {
    		thirtyThree=((stop-start+1)/3)+start;
    		sixtySeven=2*((stop-start+1)/3)+start;
    		mergeSortThreeWay(A,start,thirtyThree);
    		mergeSortThreeWay(A,thirtyThree+1,sixtySeven);
    		mergeSortThreeWay(A,sixtySeven+1,stop);
    		mergeThreeWay(A,start,thirtyThree,sixtySeven,stop);
    	}
    	else if (start+1==stop){
    		if (A[start]>A[stop]) {
    			temp=A[stop];
    			A[stop]=A[start];
    			A[start]=temp;
    		}
    	}
    }

    
    public static void main (String args[]) throws Exception {
       
	int myArray[] = {3,1,4,1,5,2,6,5,4}; // an example array to be sorted. You'll need to test your code with many cases, to be sure it works.
	//int thirtyThree=Math.round((myArray.length/3))-1;
	//int sixtySeven=Math.round(2*(myArray.length/3))-1;
	
	//System.out.println(thirtyThree);
	//System.out.println(myArray.length-1);
	mergeSortThreeWay(myArray,0,myArray.length-1);


	System.out.println("Sorted array is:\n");
	for (int i=0;i<myArray.length;i++) {
	    System.out.println(myArray[i]+" ");
	}
    }
}
	