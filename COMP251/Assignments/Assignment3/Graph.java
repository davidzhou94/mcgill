package a3posted;

import java.util.HashSet;
import java.util.HashMap;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.Set;

public class Graph {

	//   The vertices are labelled/named by a String. 
	 
	private HashSet<String>  			vertices;
	
	private HashMap<String,Boolean> 	visited;

	//   When you traverse the graph (e.g. BFS), you can define a tree which 
	//   allows you to follow parent links back to the root (starting vertex).
	
	private HashMap<String,String>  	parent;

	/*
	 *   For any vertex v,  we usually think of the adjacency list as a 
	 *   list of vertices w that represents the edges (v,w) in the Graph.  
	 *   In a weighted Graph, we also need to store the weight of each edge.
	 *   We will represent the edges by using a map of maps.  For each vertex u,
	 *   we have a map from the end vertex w to the edges weights.  Each entry
	 *   in the map is an edge (u, w, weight).    
	 */
	
	private HashMap<String, HashMap<String,Double>> edgesFrom;
	
	 // constructor
	
	public Graph(){	
		vertices   = new HashSet<String>();			
		edgesFrom  = new HashMap<String, HashMap<String,Double>>();		
		visited    = new HashMap<String,Boolean>();
	 	parent     = new HashMap<String,String>();
	 	
		//   When you traverse the graph (e.g. BFS), you can define a tree which 
		//   allows you to follow parent links back to the root (starting vertex).
		
	}
	
	//  another constructor, in case you know the vertices but not the edges   
	
	public Graph( HashSet<String> vertices ){	
		
		//  Copy the vertices, rather than reusing them.
		//  This is not space efficient, but its conceptually a bit simpler, I think.
		
		this.vertices = new HashSet<String>();
		this.edgesFrom  = new HashMap<String, HashMap<String,Double>>();
		for (String v : vertices){
			this.addVertex(v);			
		}
		visited    = new HashMap<String,Boolean>();
	 	parent     = new HashMap<String,String>();
	}
	
	// adds a vertex to the Graph.
	
	public void addVertex(String v)   	
	{	
		//  If there's already a vertex there, then throw an exception.
		if (vertices.contains(v))
			throw new IllegalArgumentException("Trying to add vertex " + String.valueOf(v) + ", but its already there.");

		vertices.add(v);
		edgesFrom.put(v, new HashMap<String,Double>());
	}	
	
	/**
	 * Adds an edge to the adjacency list.  
	 * Edge is (starting vertex, ending vertex, weight), so it adds ending vertex
	 * to adjacency list of starting vertex.
	 */
	
	public void addEdge(String start, String end, double weight)	
	{	
		HashMap<String,Double> map =  edgesFrom.get(start);
		map.put(end, new Double(weight));		
	}
	
	//  gets the set of vertices, which is a HashSet of Strings.
	
	public HashSet<String>  getVertices()
	{
		return vertices;
	}
	
	// get the adjacency list map (which is a map of maps)  
	
	public HashMap<String, Double> getEdgesFrom(String u)
	{
		return edgesFrom.get(u);
	}

	public String getParent(String u){
		return this.parent.get(u);
	};

	
	public void bfs(String u){

		//   Set visited field to false for all vertices.

		for( String v: this.getVertices() ){
			visited.put(v, new Boolean(false)); 
			parent.put(v, null);
		}

		//  Visit the input Vertex.

		visited.put(u, new Boolean(true));

		//  Initialise the queue of vertices. 

		LinkedList<String> queue = new LinkedList<String>();

		//  mark the root by pointing to itself.

		parent.put(u, u);
		queue.addLast(u);

		while (!queue.isEmpty()){
			u = queue.removeFirst();

			//  Check the vertices adjacent to current vertex, and add to queue if they haven't
			//	been visited yet.

			for (String v: edgesFrom.get(u).keySet()){
				if (!visited.get(v)){
					queue.addLast(v);
					parent.put(v, u);
					visited.put(v,  new Boolean(true));
				}
			}
		}
	}

	//  make a string that can be used for printing the Graph
	
	public String toString()
	{
		return "edgesFrom is " + edgesFrom;		
	}
}