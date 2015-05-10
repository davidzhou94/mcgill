package a3posted;

import java.util.LinkedList;

public class Tester{
	public static void main(String[] args) {

		Graph graph;
		FlowNetwork  flowNetwork  ;
		
		GraphReader  reader	=	new GraphReader("src/a3posted/test_networkflow_1.sdot");
		String start = "s",  terminal = "t";
		graph = reader.getParsedGraph();
		flowNetwork = new FlowNetwork(graph);
		flowNetwork.maxFlow(start, terminal);
		System.out.println(flowNetwork);
	}
}