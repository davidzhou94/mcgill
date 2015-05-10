package a1posted;

import java.util.ArrayList;

public class Heap {

	/*  
	 * 
	 * Here am I providing an array based implementation.   Since we don't know the array size in advance, 
	 * we use an ArrayList rather than an array.   (This is not what you'd want to do in if you
	 * cared about speed.  I do it only to spare us the administration of having to expand the 
	 * array when it is full.)  
	 * 
	 * This heap only has (priority) keys.   More generally you would want to associate objects 
	 * (or names of objects) with the keys.   The IndexedHeap class has priorities and names.  
	 *
	 * We could use a generic type (something that extends Comparable) for the priorities  
	 * instead of Double.  But since we'll be using numbers for our priorities, Double is good enough for us.
	 *
	 * Remember from COMP 250:  array based heaps start indexing at array element 1 rather than 0.
	 *
	 * This code is a modified version of Wayne and Sedgewick's code 
	 * (from their book, see link from their Coursera Algorithms course website).
	 */  
	
	ArrayList<Double>  priorities;   

	private int parent(int i){     
		return i/2;
	}
	    		
	private int leftChild(int i){ 
	    return 2*i;
	}
	
	private int rightChild(int i){ 
	    return 2*i+1;
	}
	
	private boolean is_leaf(int i){
		return (leftChild(i) >= priorities.size()) && (rightChild(i) >= priorities.size());
	}
	
	private boolean oneChild(int i){ 
	    return (leftChild(i) < priorities.size()) && (rightChild(i) >= priorities.size());
	}

	private void swap(int i, int j){
		Double tmp;
		tmp = priorities.get(j);
		priorities.set( j, priorities.get(i) );
		priorities.set( i, tmp );
	}
	
	private void upHeap(int i){
		if (i > 1) {   // min element is at 1, not 0
			if ( priorities.get(i).compareTo(priorities.get(parent(i))) < 0) {
				swap(parent(i),i);
				upHeap(parent(i));
			}
		}
	}

	private Double min(Double x, Double y){
		if (x.compareTo(y) < 0)	return x;  else return y;
	}

	private void downHeap(int i){
		Double tmp = null;  // needed for swaps

		// If i is a leaf, heap property holds
		if ( !is_leaf(i)){

			// If i has one child...
			if (oneChild(i)){
				//  check heap property
				if (priorities.get(i) > priorities.get(leftChild(i))){
					// If it fails, swap, fixing i and its child (a leaf)
					swap(i, leftChild(i));
				}
			}
			else	// i has two children...

				// check if heap property fails i.e. we need to swap with min of children

				if  (min( priorities.get(leftChild(i)), priorities.get(rightChild(i))) < priorities.get(i)){ 

					//  see which child is the smaller and swap i's value into that child, then recurse

					if  (priorities.get(leftChild(i)) < priorities.get(rightChild(i))){
						swap(i,   leftChild(i));
						downHeap( leftChild(i) );
					}
					else{
						swap(i,  rightChild(i));
						downHeap(rightChild(i));
					}
				}
		}
	}

	// constructor

	public Heap(){
		priorities = new ArrayList<Double>();
		priorities.add( new Double(0.0) );    //  fill the array slot in index 0 with a junk term.  
	}

	public String toString(){
		String out = "";
		for (Double s : priorities){
			out += s.toString() + ", ";
		}
		return out;

	}
	public Double removeMin(){
		Double tmp = priorities.get(1);
		if (priorities.size() > 2){  //  we have more than one element in the heap
			priorities.set(1,  priorities.remove( priorities.size() - 1 ));   
			downHeap(1);
		}
		else //  priorities.size == 2  i.e.  it can't be less than 2 since we would then be asking to remove the dummy element at 0.
			priorities.remove( 1 );
		return tmp;
	}	

	public void  add(double priority){
		priorities.add( new Double(priority) );  // appends to end of list
		upHeap( priorities.size() - 1 );
	}
	
	public int sizePQ(){
		return priorities.size()-1;   //  not to be confused with the size() of the underlying ArrayList, which included a dummy element at 0
	}

	public boolean isEmpty(){
		return sizePQ() == 0;   
	}
}
