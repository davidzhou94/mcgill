package a2posted;

import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.util.HashSet;
import java.util.HashMap;

/*
 * Reads a dot file from the file system and loads the graph into memory.
 * Use the getParsedGraph method to retrieve the parsed Graph. 
 * 
 * ML:  I've called this a "dot" format but, in fact, its not.    
 *      If you want to learn about real dots formats, have a look here:
 *       http://en.wikipedia.org/wiki/DOT_(graph_description_language)
 */

public class GraphReader 
{
	private Graph parsedGraph;

	private HashSet<String>  vertices;

	/**
	 * @param filename name of the file to be read.  If it does not reside in the same folder, specify the full path.
	 */

	public GraphReader(String filename)
	{
		parsedGraph = new Graph();
		vertices    = parsedGraph.getVertices();

		System.out.println(filename);
		BufferedReader inputStream;
		String currentLine;
		try
		{
			inputStream = 
					new BufferedReader(new FileReader(filename));
			while ((currentLine = inputStream.readLine()) != null) 
			{
				parse(currentLine);				 
			}
		}
		catch(DotParsingException e)
		{
			System.out.println("Dot Parsing Exception");
			System.out.println(e.getMessage());
			System.exit(1);
		}
		catch(IOException e)
		{
			System.out.println("Error Reading FIle");
			e.printStackTrace();
			System.exit(1);
		}
		catch(Exception e)
		{
			e.printStackTrace();
			System.exit(1);
		}

	}
	/*
	 * Get the parsed Graph. Before calling this function, DotReader constructor must have be invoked with filename.
	 */

	public Graph getParsedGraph()
	{
		return(this.parsedGraph);
	}

	/*
	 * Implements a parser for simplified dot files. This method parses only the current line and 
	 * stores the Vertex and edge information in its private Graph object. 
	 *  
	 */

	private void parse(String currentLine) throws DotParsingException
	{
		String u, v, weight;
		double d;

		// First check if the currentLine contains edge or vertex info

		if(currentLine.contains("->")) // edge info
		{
			String [] tokens=currentLine.trim().split("->|,");
			u=tokens[0];
			v=tokens[1];
			weight=tokens[2];
			u = u.trim();
			v = v.trim();
			weight = weight.trim();
			/* 
			 * check if the edge has undefined start or end Vertex.
			 */
			if (!vertices.contains(u) || !vertices.contains(v))
			{
				//System.out.println("Does not contain"+ u +" or "+v);
				throw(new DotParsingException("No definition for "+u+" or "+v));
			}

			parsedGraph.addEdge(u, v, Double.parseDouble(weight)); 
		}

		else{
			u = currentLine.trim(); 
			if(u.equals("") || vertices.contains(u))
			{
				return;// if vertex u is already defined, do not re define it. 
			}
			parsedGraph.addVertex(u);
		}
	}
	
	/*
	 * An Exception class thrown by DotReader parse method. 
	 * Use the getMessage to know the exact cause for the Exception.  
	 */
	private class DotParsingException extends Exception {

		
		private static final long serialVersionUID = 1L;
		/*
		 * message will hold detailed info about the cause for the exception.
		 */
		DotParsingException(String message)
		{
			super(message);
		}
		
		/*
		 * (non-Javadoc)
		 * @see java.lang.Throwable#getMessage()
		 */
		public String getMessage()
		{
			return(super.getMessage());
		}
	}

}
