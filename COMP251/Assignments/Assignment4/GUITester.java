package a4posted;

import java.awt.geom.Point2D;
import java.util.ArrayList;
import java.util.Random;
import java.util.concurrent.TimeUnit;

import javax.swing.*;
import javax.swing.event.*;

import java.awt.*;
import java.awt.event.*;
import java.awt.image.BufferedImage;

public class GUITester extends JFrame{
	
	//  constants
	
	static int  N = 50;
	static int  WIDTH  = 650;
	static int  HEIGHT = 600;
	static int  SLIDERMINVALUE = 1;
	static int  PIXELS_PER_XYUNIT = (int) (WIDTH / N);
	static int  SHIFT_X = 10;
	static int  SHIFT_Y = 10;   //  shift plot away from left border
	
	//  GUI (Graphical user interface) variables
	
	static JSlider slider;
	static JLabel labelMaxCost,labelCost,view;
	static ButtonGroup buttonGroup;
	static JRadioButton iterativeRadio = new JRadioButton("iterative");
	static JRadioButton recursiveRadio = new JRadioButton("recursive");
	static JTextField  maxCostOfSegmentTextField;
	static JPanel panel1, panel2, panel3;
	static SegmentedLeastSquares sls;
	static BufferedImage surface;	
	static int  sliderMaxValue = 100;
	
	double costOfSegment = 1.0;
	int 	maxCostOfSegment= 10;
	int 	slidervalue;
	public enum DynamicProgStyle {ITERATIVE, RECURSIVE};
	static DynamicProgStyle iterativeOrRecursive;
	static Graphics g;

	static Point2D[] 				coords;       //  (x,y) values  
	static ArrayList<LineSegment> lineSegments;   // The LineSegment class defined in SegmentedLeastSquares class.

	//  constructor
	
	public  GUITester(){
				
		//  radio buttons for switching between iterative and recursive methods for computing opt[ ]

		iterativeRadio = new JRadioButton("iterative",false);
		recursiveRadio = new JRadioButton("recursive",true);
		iterativeOrRecursive = DynamicProgStyle.RECURSIVE;
				
		buttonGroup = new ButtonGroup();
		buttonGroup.add(iterativeRadio);
		buttonGroup.add(recursiveRadio);
		
		iterativeRadio.addActionListener(new ActionListener(){
			public void actionPerformed(ActionEvent e){
				iterativeOrRecursive = DynamicProgStyle.ITERATIVE;
				sls = new SegmentedLeastSquares(coords, costOfSegment);
				lineSegments = sls.solveIterative();
				redraw();
			}
		});
		
		recursiveRadio.addActionListener(new ActionListener(){
			public void actionPerformed(ActionEvent e){
				iterativeOrRecursive = DynamicProgStyle.RECURSIVE;
				sls = new SegmentedLeastSquares(coords, costOfSegment );
				lineSegments = sls.solveRecursive();
				redraw();
			}
		});

		//  Here we allow the user to specify the range of the costs of a segment

		JLabel costMaxLabel = new JLabel("       Max is (enter): )");
		maxCostOfSegmentTextField  = new JTextField(new Integer(maxCostOfSegment).toString(),5); //  assume the cost entered has 5 digits (incl. decimal point)
		sliderMaxValue = Integer.parseInt(maxCostOfSegmentTextField.getText());		
		maxCostOfSegmentTextField.addActionListener(new ActionListener(){
			public void actionPerformed(ActionEvent e) {
				maxCostOfSegment = Integer.parseInt(maxCostOfSegmentTextField.getText());
			}});
		
		slider = new JSlider(SLIDERMINVALUE,sliderMaxValue, sliderMaxValue);     
		slider.addChangeListener(new SliderAction());  // listens/waits for slider to be moved
		
		labelMaxCost  = new JLabel((new Double(maxCostOfSegment)).toString());
		labelCost = new JLabel("Cost of each segment = ");

		//   Now add the above components to the panels.  There are three panels.  The first holds the radio buttons.
		
		panel1 = new JPanel();
		panel1.add(iterativeRadio);
		panel1.add(recursiveRadio);
		add(panel1, BorderLayout.NORTH); 
		
		//   The second panel holds the slider and info about cost of a segment.
		
		panel2 = new JPanel();
		panel2.add(slider);
		panel2.add(labelCost); 
		panel2.add(labelMaxCost);          
		panel2.add(costMaxLabel);
		panel2.add(maxCostOfSegmentTextField);
		add(panel2, BorderLayout.CENTER); 

		//   The third panel shows the points and line fits.
		
		surface = new BufferedImage(WIDTH,HEIGHT,BufferedImage.TYPE_INT_RGB);
		g = surface.getGraphics();
		g.setColor(Color.BLACK);
		g.fillRect(0,0,WIDTH,HEIGHT);
		view = new JLabel(new ImageIcon(surface));

		panel3 = new JPanel();
		panel3.add(view);
		add(panel3, BorderLayout.SOUTH); 

		setSize(WIDTH + 100,HEIGHT + 100);    //  make the window bigger than the two panels so there's a border
		
		setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
		setLocationRelativeTo(null);
		setVisible(true);
		setResizable(false);
		
		redraw();
	}

	// when the slider is moved, the cost of a segment changes, so it solves the problem again.

	public class SliderAction implements ChangeListener{
		
		public void stateChanged(ChangeEvent ce){
			
			//  the slider value can go from SLIDERMINVALUE to SLIDERMAXVALUE.   
			//  Divide by 100 so cost goes from 0 to 1.
			
			slidervalue = slider.getValue();
			costOfSegment = slidervalue*1.0 / sliderMaxValue * maxCostOfSegment;
			String str = Double.toString(costOfSegment);
			labelMaxCost.setText(str);
			
			sls = new SegmentedLeastSquares(coords, costOfSegment);
			solve(iterativeOrRecursive);
			redraw();
			}
	}
	
	//  You have to implement two solutions (iterative and recursive).  This method 
	//  chooses which one to run at any time (as determined by the radio buttons).

	public static void solve(DynamicProgStyle whichStyle){
		if (whichStyle == DynamicProgStyle.RECURSIVE)
			lineSegments = sls.solveRecursive();
		else
			lineSegments = sls.solveIterative();
		
		for (LineSegment l : lineSegments)
			System.out.println(l);
	}
	
	//  When something changes,  you need to redraw
	
	public static void redraw(){ 
		
		int ovalwidth = 8;
		int ovalradius = ovalwidth/2;
		g.setColor(new Color(220, 220, 220));   //  background color
		g.fillRect(0,0,WIDTH,HEIGHT);
		view.repaint();
		g.setColor(Color.BLACK);
		
		//  draw points (xi, yi)
		
		for(int i = 0;i<N;i++)		{
			g.fillOval( SHIFT_X + (int)( coords[i].getX()*PIXELS_PER_XYUNIT ) - ovalradius, 
					    (int)(HEIGHT - (coords[i].getY() *PIXELS_PER_XYUNIT)) - ovalradius  - SHIFT_Y, 
					    ovalwidth, ovalwidth ); 
		}

		//  draw coordinate axes and ticks
		
		g.drawLine(SHIFT_X, HEIGHT - SHIFT_Y, WIDTH,   HEIGHT - SHIFT_Y);
		for (int i=0; i < WIDTH; i += PIXELS_PER_XYUNIT)
			g.drawLine(SHIFT_X + i, HEIGHT - SHIFT_Y, SHIFT_X + i,   HEIGHT);
		
		g.drawLine(SHIFT_X, HEIGHT - SHIFT_Y, SHIFT_X,   SHIFT_Y);
		for (int j=0; j < HEIGHT; j += PIXELS_PER_XYUNIT)
			g.drawLine(0, HEIGHT - SHIFT_Y - j , SHIFT_X, HEIGHT - SHIFT_Y - j);
		
	
		double x1,y1,x2,y2;
		LineSegment segment;

		//  draw line segments
		
		g.setColor(Color.RED);
		for (int i = 0; i< lineSegments.size(); i++){
			segment = lineSegments.get(i);
			x1 = segment.i ;
			x2 = segment.j ;
			y1 = (segment.a  *x1  + segment.b );
			y2 = (segment.a  *x2  + segment.b );

			x1 = x1*PIXELS_PER_XYUNIT; 
			y1 = y1*PIXELS_PER_XYUNIT;
			x2 = x2*PIXELS_PER_XYUNIT;
			y2 = y2*PIXELS_PER_XYUNIT;

			g.drawLine(SHIFT_X + (int) x1, 
					   (int) (HEIGHT- y1)  - SHIFT_Y, 
					   SHIFT_X + (int) x2, 
					   (int) (HEIGHT-y2)   - SHIFT_Y);
		}
		
		
	}

	public static void main(String s[]){ 

		int  costSegment = 10; //  Implement a slider to allow user to adjust this interactively.
		
		Point2D[] points = new Point2D[N];    
		double error, a, b;
		int scaleError = 2;

		Random rand = new Random(); 
		
		//  segment 1

		for (int i = 0;  i < N/2; i++){
			a = 1;
			b = 10;
			points[i] = new Point2D.Float();
			error = rand.nextDouble()*2 - 1;   //  random number in [-1,1]
			points[i].setLocation(i * 1.0, a*i + b + scaleError*error);   //  y = x^2  
		}
		
		//  segment 2
		
		for (int i = N/2-3;  i < 3*N/4; i++){
			a = 0;
			b = N/2;
			points[i] = new Point2D.Float();
			error = rand.nextDouble()*2 - 1;   //  random number in [-1,1]
			points[i].setLocation(i * 1.0, a*i + b + scaleError*error);   //  y = x^2  
		}
		
		//  segment 3
		
		for (int i = 3*N/4;  i < N; i++){
			a = -1.2;
			b = 1.6*N;
			points[i] = new Point2D.Float();
			error = rand.nextDouble()*2 - 1;   //  random number in [-1,1]
			points[i].setLocation(i * 1.0, a*i + b + scaleError*error);   //  y = x^2  
		}
		
		
		sls = new SegmentedLeastSquares(points, costSegment );
		solve( iterativeOrRecursive );
		coords = points;
		
		new GUITester();
	}

}