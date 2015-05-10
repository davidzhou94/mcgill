//David (Yang) Zhou 260517397

package a3posted;

import java.util.LinkedList;
import java.util.HashSet;

public class FlowNetwork {

	//   The data structures follow what I presented in class.  Use three graphs which 
	//   represent the capacities, the flow, and the residual capacities.
	
	Graph capacities;      		// weights are capacities   (G)
	Graph flow;            		// weights are flows        (f)
	Graph residualCapacities;   // weights are determined by capacities (graph) and flow (G_f)
	
	//   Constructor.   The input is a graph that defines the edge capacities.
	
	public FlowNetwork(Graph capacities){
				
		this.capacities    = capacities;
		
		//  The flow and residual capacity graphs have the same vertices as the original graph.
		
		flow               = new Graph( capacities.getVertices() );
		residualCapacities = new Graph( capacities.getVertices() );
		
		//  Initialize the flow and residualCapacity graphs.   The flow is initialized to 0.  
		//  The residual capacity graph has only forward edges, with weights identical to the capacities. 

		for (String u : flow.getVertices()){
			for (String v : capacities.getEdgesFrom(u).keySet() ){
				
				//  Initialize the flow to 0 on each edge
				
				flow.addEdge(u, v, new Double(0.0));
				
				//	Initialize the residual capacity graph G_f to have the same edges and capacities as the original graph G (capacities).
				
				residualCapacities.addEdge(u, v, new Double( capacities.getEdgesFrom(u).get(v) ));
			}
		}
	}

	/*
	 * Here we find the maximum flow in the graph.    There is a while loop, and in each pass
	 * we find an augmenting path from s to t, and then augment the flow using this path.
	 * The beta value is computed in the augment method. 
	 */
	
	public void  maxFlow(String s,  String t){
		
		LinkedList<String> path;
		double beta;
		while (true){
			path = this.findAugmentingPath(s, t);
			if (path == null)
				break;
			else{
				beta = computeBottleneck(path);
				//System.out.println("Augmenting");
				augment(path, beta);
			}
		}	
	}
	
	/*
	 *   Use breadth first search (bfs) to find an s-t path in the residual graph.    
	 *   If such a path exists, return the path as a linked list of vertices (s,...,t).   
	 *   If no path from s to t in the residual graph exists, then return null.  
	 */
	
	public LinkedList<String>  findAugmentingPath(String s, String t){

		//  ADD YOUR CODE HERE.
		
		LinkedList<String> path = new LinkedList<String>();
		String curNode, parentNode;
		
		//perform bfs and "get" the parent of the sink to 
		//check to see if bfs could find a path to t
		residualCapacities.bfs( s );
		curNode = residualCapacities.getParent ( t );
		
		//t will not have a parent if it was not reached during bfs
		if (curNode != null) {
			parentNode = residualCapacities.getParent( curNode );
			path.addFirst( t );
			//while we have not reached the source, we keep pushing 
			//on to the list, building the path backwards
			while (!curNode.equals(parentNode)) {
				path.addFirst(curNode);
				curNode = parentNode;
				parentNode = residualCapacities.getParent( curNode );
			}
			//finish with the source and return
			path.addFirst( s );
			return path;
		}
		else return null;	//there is no path from s to t
	}
	
	/*
	 *   Given an augmenting path that was computed by findAugmentingPath(), 
	 *   find the bottleneck value (beta) of that path, and return it.
	 */
	
	public double computeBottleneck(LinkedList<String>  path){

		double beta = Double.MAX_VALUE;

		//  Check all edges in the path and find the one with the smallest weight in the
		//  residual graph.   This will be the new value of beta.

		//   ADD YOUR CODE HERE.
		
		//make a copy of the path to work on
		LinkedList<String> pathCopy = new LinkedList<String>(path);
		
		//declare some variables that we will need
		String curNode, nextNode;
		double edgeCap;
		int i = 1, pathsize = path.size();
		
		nextNode = pathCopy.removeFirst();
		
		//loop through the entire path, checking each edge to see if it has the smallest capacity
		do {
			curNode = nextNode;
			nextNode = pathCopy.removeFirst();
			edgeCap = residualCapacities.getEdgesFrom(curNode).get(nextNode).doubleValue();
			//if the current edge's capacity is smaller than the smallest found so far, 
			//update the bottleneck.
			if ( edgeCap < beta) {
				beta = edgeCap;
			}
			i++;
		} while (i < pathsize);
		
		return beta;
	}
	
	//  Once we know beta for a path, we recompute the flow and update the residual capacity graph.

	public void augment(LinkedList<String>  path,  double beta){

		//   ADD YOUR CODE HERE.
		
		//make a copy of the path to work on
		LinkedList<String> pathCopy = new LinkedList<String>(path);
		
		//declare some vars
		String curNode, nextNode;
		Double curFlow, newFlow, edgeCap;
		int i = 1, pathsize = path.size();
		
		//begin with the first edge in the path and loop until we get to the end of the path 
		nextNode = pathCopy.removeFirst();
		
		do {
			//update some vars
			curNode = nextNode;
			nextNode = pathCopy.removeFirst();
			
			//test/check the edge capacity between these two vertices
			edgeCap = capacities.getEdgesFrom(curNode).get(nextNode);
			
			//check if a forward edge exists, then this edge is a forwards edge
			if (edgeCap != null ) {
				//get the forward pointing edge and compute new flow
				curFlow = flow.getEdgesFrom(curNode).get(nextNode);
				newFlow = curFlow + beta;
				
				//update flow and residual caps graph
				flow.addEdge( curNode, nextNode, newFlow );
				residualCapacities.addEdge( nextNode, curNode, newFlow );
				
				//check to see if we have any residual capacity left in this edge and
				//if so, update the residual edge, if not remove the edge so bfs doesn't
				//pick it up.
				if ( (edgeCap - newFlow) > 0) {
					residualCapacities.addEdge( curNode, nextNode, (edgeCap - newFlow ) );
				}
				else {
					residualCapacities.getEdgesFrom(curNode).remove(nextNode);
				}
			}
			//is a backwards edge
			else {
				//get the forward pointing edge, and since we're looking at a backwards 
				//edge, in the flow graph the edge in question has the vertices switched
				curFlow = flow.getEdgesFrom(nextNode).get(curNode);
				newFlow = curFlow - beta;
				
				//update flow and residual caps graph
				flow.addEdge( nextNode, curNode, newFlow );
				residualCapacities.addEdge( curNode, nextNode, newFlow );
				
				//update edgeCap with the capacity for the forward running edge, then check 
				//to see if we have any residual capacity left in this edge and if so, 
				//update the residual edge, if not remove the edge so bfs doesn't pick it up.
				edgeCap = capacities.getEdgesFrom(nextNode).get(curNode);
				if ( (edgeCap - newFlow ) > 0) {
					residualCapacities.addEdge( nextNode, curNode, (edgeCap - newFlow ) );
				}
				else {
					residualCapacities.getEdgesFrom(nextNode).remove(curNode);
				}
			}
			i++;
		} while (i < pathsize);

	}

	//  This just dumps out the adjacency lists of the three graphs (original with capacities,  flow,  residual graph).
	
	public String toString(){
		return "capacities\n" + capacities + "\n\n" + "flow\n" + flow + "\n\n" + "residualCapacities\n" + residualCapacities;
	}
	
}
