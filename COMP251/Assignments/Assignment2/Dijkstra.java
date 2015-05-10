// David (Yang) Zhou 260517397

package a2posted;

import java.util.HashMap;
import java.util.HashSet;

public class Dijkstra {

	private IndexedHeap  pq;	
	private static int edgeCount = 0;               //  Use this to give names to the edges.										
	private HashMap<String,Edge>  edges = new HashMap<String,Edge>();

	private HashMap<String,String>   parent;
	private HashMap<String,Double>   dist;  //  This is variable "d" in lecture notes
	private String 					 startingVertex;	
	
	HashSet<String>  setS      ;
	HashSet<String>  setVminusS;

	public Dijkstra(){
		pq    		= new IndexedHeap()  ;		
		setS        = new HashSet<String>();
		setVminusS  = new HashSet<String>();		
		parent  = new HashMap<String,String>();
		dist 	= new HashMap<String,Double>();
	}
	
	/*
	 * Run Dijkstra's algorithm from a vertex whose name is given by the string s.
	 */
	
	public void dijkstraVertices(Graph graph, String s){
		
		//  temporary variables
		
		String u;	
		double  distToU,
				costUV;		
		
		HashMap<String,Double>    uAdjList;		
		initialize(graph,s);
		
		parent.put( s, null );
		pq.add(s, 0.0);   // shortest path from s to s is 0.
		this.startingVertex = s;

		//  --------- BEGIN: ADD YOUR CODE HERE  -----------------------
		
		/* populate IndexedHeap pq with vertices in V/S and path distance=infinity, 
		 * eventually pq will be used to determine shortest path to a vertex in V/S
		 */
		for (String v : setVminusS) pq.add(v);

		//main loop, continues until no edges are left in V/S
		while (!pq.isEmpty()) {
			costUV = pq.getMinPriority();		//identify shortest crossing edge
			u = pq.removeMin();					//remove min path distance vertex u
			dist.put(u, costUV);				//add newly reached u and its distance
			setS.add(u);						//add u to S
			setVminusS.remove(u);				//remove u from V/S
			uAdjList = graph.getAdjList().get(u);		//get u's neighbours via outbound edges
			
			/* iterate through u's neighbours, checking to see if a path to one of them 
			 * is shorter than the best known path
			 */
			for (java.util.Map.Entry<String, Double> entry : uAdjList.entrySet()) {
				String v = entry.getKey();			//pick an arbitrary neighbour v
				if (setVminusS.contains(v)) {		//determine if (u,v) is a crossing edge
					double val = entry.getValue();		//store distance from u to v
					distToU = dist.get(u) + val;		//store distance from s to v
					//determine if this path is better than best known path
					final int test = Double.compare(distToU, pq.getPriority(v));
					if (test<0) {					
						pq.changePriority(v, distToU);		//update best known path
						parent.put(v, u);					//update parent relation
					}
				}
			}
		}
		
		//  --------- END:  ADD YOUR CODE HERE  -----------------------
	}
	
	
	public void dijkstraEdges(Graph graph, String startingVertex){

		//  Makes sets of the names of vertices,  rather than vertices themselves.
		//  (Could have done it either way.)
		
		//  temporary variables
		
		Edge e;
		String u,v;
		double tmpDistToV;
		
		initialize(graph, startingVertex);

		//  --------- BEGIN: ADD YOUR CODE HERE  -----------------------
		
		
		setS.add(startingVertex);				//add the start vertex to S
		setVminusS.remove(startingVertex);		//remove the start vertex from V\S
		pqAddEdgesFrom(graph, startingVertex);	//add all edges from the start vertex to pq
		
		//main loop, continues until no edges are left going to V\S
		while (!pq.isEmpty()) {
			tmpDistToV = pq.getMinPriority();	//store distance of shortest edge in pq
			String curEdge = pq.removeMin();	//remove from pq and keep name in curEdge
			e = edges.get(curEdge);				//retrieve the edge object
			u = e.getEndVertex();				//store vertex on edge in end in u
			v = e.getStartVertex();				//store vertex of edge out end in v 
			if (setVminusS.contains(u) && setS.contains(v)) {		//determine if edge is a crossing edge
				dist.put(u, tmpDistToV);		//update distance for shortest known path
				parent.put(u, v);				//update parent relation
				setS.add(u);					//move vertex u to S ...
				setVminusS.remove(u);			//... from u
				pqAddEdgesFrom(graph, u);		//add all edges leading out from u to pq
			}
		}
		
		//  --------- END:  ADD YOUR CODE HERE  -----------------------

	}
	
	/*
	 *   This initialization code is common to both of the methods that you need to implement so
	 *   I just factored it out.
	 */

	private void initialize(Graph graph, String startingVertex){
		//  initialization of sets V and VminusS,  dist, parent variables
		//

		for (String v : graph.getVertices()){
			setVminusS.add( v );
			dist.put(v, Double.POSITIVE_INFINITY);
			parent.put(v, null);
		}
		this.startingVertex = startingVertex;

		//   Transfer the starting vertex from VminusS to S and  

		setVminusS.remove(startingVertex);
		setS.add(startingVertex);
		dist.put(startingVertex, 0.0);
		parent.put(startingVertex, null);
	}

    /*  
	 *  helper method for dijkstraEdges:   Whenever we move a vertex u from V\S to S,  
	 *  add all edges (u,v) in E to the priority queue of edges.
	 *  
	 *  For each edge (u,v), if this edge gave a shorter total distance to v than any
	 *  previous paths that terminate at v,  then this edge will be removed from the priority
	 *  queue before these other vertices. 
	 *  
	 */
	
	public void pqAddEdgesFrom(Graph g, String u){
		double distToU = dist.get(u); 
		for (String v : g.getAdjList().get(u).keySet()  ){  //  all edges of form (u, v) 
			
			edgeCount++;
			Edge e = new Edge( edgeCount, u, v );
			edges.put( e.getName(), e );
			pq.add( e.getName() ,  distToU + g.getAdjList().get(u).get(v) );
		}
	}

	// -------------------------------------------------------------------------------------------
	
	public String toString(){
		String s = "";
		s += "\nRan Dijkstra from vertex " + startingVertex + "\n";
		for (String v : parent.keySet()){
			s += v + "'s parent is " +   parent.get(v) ;
			s += "   and pathlength is "  + dist.get(v) + "\n" ;
		}
		return s;
	}

	//  This class is used only to keep track of edges in the priority queue. 
	
	private class Edge{
		
		private String edgeName;
		private String u, v;
		
		Edge(int i, String u, String v){
			this.edgeName = "e_" + Integer.toString(i);
			this.u = u;
			this.v = v;
		}
		
		public String getName(){
			return edgeName;
		}
		
		String getStartVertex(){
			return u;
		}

		String getEndVertex(){
			return v;
		}
		
		public String toString(){
			return 	edgeName + " : " + u + " " + v;
		}
	}
	

}
