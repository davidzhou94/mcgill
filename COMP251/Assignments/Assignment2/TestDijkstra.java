package a2posted;

public class TestDijkstra{
	public static void main(String[] args) {
		
		Graph graph;
		Dijkstra dijkstra;

		
		/*
		GraphReader  reader	=	new GraphReader("src/a2solution/test_graph_1.sdot");
		String startingVertex = "4";
		*/

		GraphReader  reader	=	new GraphReader("src/a2solution/test_graph_2.sdot");
		String startingVertex = "a";
		graph = reader.getParsedGraph();
		
		/*  
		 *  I changed this slightly from the original starter code because there was 
		 *  some awkwardness with the initialization.   
		 */
		
		dijkstra = new Dijkstra();
		dijkstra.dijkstraVertices( graph, startingVertex );
		System.out.println("dijkstraVertices: \n" + dijkstra );
		
		dijkstra = new Dijkstra();
		dijkstra.dijkstraEdges(    graph, startingVertex );
		System.out.println("dijkstraEdges: \n" + dijkstra );
	}
}