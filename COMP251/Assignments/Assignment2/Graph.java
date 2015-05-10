package a2posted;

import java.util.HashSet;
import java.util.HashMap;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.Set;

public class Graph {

	/*
	 *   The vertices are labelled/named by a String. 
	 */
	
	private HashSet<String>  vertices;
	
	/*
	 *   For any vertex v,  we usually think of the adjacency list as a 
	 *   list of vertices w that represents the edges (v,w) in the graph.  
	 *   In a weighted graph, we also need to store the weight of each edge.
	 *   We can do so by using a  map for the adjacency list, namely it is
	 *   a map from vertices to weights.  That is, rather than representing the
	 *   adjacency list of v as a list,  we represent it as a map 
	 *   {(w, weight(v,w)) : (v,w) in E}.         
	 */
	
	private HashMap<String, HashMap<String,Double>>   adjList;
		
	  // constructor
	
	public Graph()              			
	{	
		vertices = new HashSet<String>();			
		adjList  = new HashMap<String, HashMap<String,Double>>();		
	}
	
	/**
	 * Adds a Vertex to the graph.
	 * @param Vertex: A Vertex object
	 */
	public void addVertex(String v)   	
	{	
		//  If there's already a vertex there, then throw an exception.
		if (vertices.contains(v))
			throw new IllegalArgumentException("Trying to add vertex " + String.valueOf(v) + ", but its already there.");

		vertices.add(v);
		adjList.put(v, new HashMap<String,Double>());
	}	
	
	/**
	 * Adds an edge to the adjacency list.  Edge is (start,end, weight), so it adds end to adjacency list of start Vertex.
	 * @param start Vertex of the edge
	 * @param end Vertex of the edge
	 * @param double weight of the edge
	 */
	
	public void addEdge(String start, String end, double weight)	
	{	
		HashMap<String,Double> map = adjList.get(start);
		map.put(end, new Double(weight));		
	}
	
	public HashSet<String>  getVertices()
	{
		return vertices;
	}
	
	/**
	 * @return get the adjacency list map (which is a map of maps)  
	 */
	
	public HashMap<String, HashMap<String, Double>> getAdjList()
	{
		return adjList;
	}	

	//  make a string that can be used for printing the graph
	
	public String toString()
	{
		String result="";

		for(String label: vertices)
		{
			result += label + '\n';

			Set<String> endVertices = adjList.get(label).keySet();
			for  (String  w_label:  endVertices){
				result += " edge to " + w_label + " with weight " + adjList.get(label).get(w_label) + "\n";
			}
		}
		return(result);
	}
	
}