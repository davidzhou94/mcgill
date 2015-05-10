// STUDENT1_NAME: Yang (David) Zhou
// STUDENT1_ID: 260517397

import java.io.*;    
import java.util.*;

class studentList {
    int studentID[];
    int numberOfStudents;
    String courseName;
    
    // A constructor that reads a studentList from the given fileName and assigns it the given courseName
    public studentList(String fileName, String course) {
	String line;
	int tempID[]=new int[4000000]; // this will only work if the number of students is less than 4000000.
	numberOfStudents=0;
	courseName=course;
	BufferedReader myFile;
	try {
	    myFile = new BufferedReader(new FileReader( fileName ) );	

	    while ( (line=myFile.readLine())!=null ) {
		tempID[numberOfStudents]=Integer.parseInt(line);
		numberOfStudents++;
	    }
	    studentID=new int[numberOfStudents];
	    for (int i=0;i<numberOfStudents;i++) {
		studentID[i]=tempID[i];
	    }
	} catch (Exception e) {System.out.println("Can't find file "+fileName);}
	
    }
    

    // A constructor that generates a random student list of the given size and assigns it the given courseName
    public studentList(int size, String course) {
	int IDrange=2*size;
	studentID=new int[size];
	boolean[] usedID=new boolean[IDrange];
	for (int i=0;i<IDrange;i++) usedID[i]=false;
	for (int i=0;i<size;i++) {
	    int t;
	    do {
		t=(int)(Math.random()*IDrange);
	    } while (usedID[t]);
	    usedID[t]=true;
	    studentID[i]=t;
	}
	courseName=course;
	numberOfStudents=size;
    }
    
    // Returns the number of students present in both lists L1 and L2
    public static int intersectionSizeNestedLoops(studentList L1, studentList L2) {
    	/* Write your code for question 1 here */
    	int inters=0;
    	int m=L1.studentID.length;
    	int n=L2.studentID.length;
    	for (int i=0;i<m;i++) {
    		for (int j=0;j<n;j++){
    			if (L1.studentID[i] == L2.studentID[j]) inters++;
    		}
    	}
	return inters;
    }
    
    
    // This algorithm takes as input a sorted array of integers called mySortedArray, the number of elements it contains, and the student ID number to look for
    // It returns true if the array contains an element equal to ID, and false otherwise.
    public static boolean myBinarySearch(int mySortedArray[], int numberOfStudents, int ID) {
	/* For question 2, Write your implementation of the binary search algorithm here */
    	int left=0;
    	int right=numberOfStudents;
    	int mid;
    	while (right>left+1){
    		mid=((left+right)/2);
    		if (mySortedArray[mid]>ID) {
    			right=mid;
    		} else {
    			left=mid;
    		}
    	}
    	if (mySortedArray[left]==ID) return true;
    	else return false;
    }
    
    
    public static int intersectionSizeBinarySearch(studentList L1, studentList L2) {
	/* Write your code for question 2 here */
    	int inters=0;
    	int m=L1.studentID.length;
    	int n=L2.studentID.length;
    	Arrays.sort(L1.studentID);
    	for (int i=0;i<n;i++){
    		if (myBinarySearch(L1.studentID, m, L2.studentID[i])) inters++;
    	}
    	
	return inters;
    }
    
    
    public static int intersectionSizeSortAndParallelPointers(studentList L1, studentList L2) {
	/* Write your code for question 3 here */
    	int inters=0;
    	int m=L1.studentID.length;
    	int n=L2.studentID.length;
    	int[] a1 = new int[m];
    	Arrays.sort(L1.studentID);
    	a1 = L1.studentID;
    	
    	int[] a2 = new int[m];
    	Arrays.sort(L2.studentID);
    	a2 = L2.studentID;
    	int ptrA=0;
    	int ptrB=0;
    	while (ptrA<m && ptrB<n) {
    		if (a1[ptrA]==a2[ptrB]) {
    			inters++;
    			ptrA++;
    			ptrB++;
    		}
    		else if (a1[ptrA]<a2[ptrB]) ptrA++;
    		else ptrB++;
    	}
	return inters;
    }
    
    
    public static int intersectionSizeMergeAndSort(studentList L1, studentList L2) {
	/* Write your code for question 4 here */
    	int inters=0;
    	int ptr=0;
    	int m=L1.studentID.length;
    	int n=L2.studentID.length;
    	int[] C = new int[m+n];
    	for (int i=0;i<m;i++) C[i]=L1.studentID[i];
    	for (int i=0;i<n;i++) C[i+m]=L2.studentID[i];
    	Arrays.sort(C);
    	while (ptr<m+n-1) {
    		if (C[ptr]==C[ptr+1]) {
    			inters++;
    			ptr=ptr+2;
    		}
    		else ptr++;
    	}
    	
	return inters;
    }
    
    
    
    /* The main method */
    /* Write code here to test your methods, and evaluate the running time of each. 2013f */
    /* This method will not be marked */
    public static void main(String args[]) throws Exception {
	
	studentList firstList;
	studentList secondList;
	int numReps=1;
	//int listLength=1024000;
	
	// This is how to read lists from files. Useful for debugging.
	
	//	firstList=new studentList("COMP250.txt", "COMP250 - Introduction to Computer Science");
	//	secondList=new studentList("MATH240.txt", "MATH240 - Discrete Mathematics");
	
	// get the time before starting the intersections
	long startTime = System.nanoTime();
	
	// repeat the process a certain number of times, to make more accurate average measurements.
	for (int rep=0;rep<numReps;rep++) {
	    
	    // This is how to generate lists of random IDs. 
	    // For firstList, we generate 16000 IDs
	    // For secondList, we generate 16000 IDs
	    
	    firstList=new studentList(1024000 , "COMP250 - Introduction to Computer Science"); 
	    secondList=new studentList(32000 , "MATH240 - Discrete Mathematics"); 
	    
	    // run the intersection method
	    int intersection=studentList.intersectionSizeMergeAndSort(firstList,secondList);
	    System.out.println("The intersection size is: "+intersection);
	}
	
	// get the time after the intersection
	long endTime = System.nanoTime();
	
	
	System.out.println("Running time: "+ (endTime-startTime)/numReps + " nanoseconds");
    }
    
}