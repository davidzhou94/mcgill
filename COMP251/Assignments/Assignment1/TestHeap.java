package a1posted;
import java.util.ArrayList;
import java.util.Random;

public class TestHeap {

	/*  Here's a simple test to make sure the Heap is working. 
	 *  Add in a list of random numbers.  Then use remove them from the heap
	 *  and put them in another list.  If the heap is implemented properly,
	 *  then the numbers in the latter list should be sorted.
	 */  
	
	public static void main(String[] args) {
		Random generator = new Random();
		int  numRandoms = 103;
		ArrayList<Double> sorted = new ArrayList<Double>();
		
		Heap  pq = new Heap();
		for (int i=0; i < numRandoms; i++){
			pq.add( generator.nextDouble());
		}
		while (!pq.isEmpty()){
			sorted.add( pq.removeMin() );
		}
		for (Double d : sorted){
			System.out.println( d);
		}
	}
}
