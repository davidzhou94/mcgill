import java.lang.Math.*;

class expressionTreeNodeSolution {
	private String value;
	private expressionTreeNodeSolution leftChild, rightChild, parent;

	expressionTreeNodeSolution() {
		value = null; 
		leftChild = rightChild = parent = null;
	}

	// Constructor
	/* Arguments: String s: Value to be stored in the node
                  expressionTreeNodeSolution l, r, p: the left child, right child, and parent of the node to created      
       Returns: the newly created expressionTreeNodeSolution               
	 */
	expressionTreeNodeSolution(String s, expressionTreeNodeSolution l, expressionTreeNodeSolution r, expressionTreeNodeSolution p) {
		value = s; 
		leftChild = l; 
		rightChild = r;
		parent = p;
	}

	/* Basic access methods */
	String getValue() { return value; }

	expressionTreeNodeSolution getLeftChild() { return leftChild; }

	expressionTreeNodeSolution getRightChild() { return rightChild; }

	expressionTreeNodeSolution getParent() { return parent; }


	/* Basic setting methods */ 
	void setValue(String o) { value = o; }

	// sets the left child of this node to n
	void setLeftChild(expressionTreeNodeSolution n) { 
		leftChild = n; 
		n.parent = this; 
	}

	// sets the right child of this node to n
	void setRightChild(expressionTreeNodeSolution n) { 
		rightChild = n; 
		n.parent=this; 
	}


	// Returns the root of the tree describing the expression s
	// Watch out: it makes no validity checks whatsoever!
	expressionTreeNodeSolution(String s) {
		// check if s contains parentheses. If it doesn't, then it's a leaf
		if (s.indexOf("(")==-1) setValue(s);
		else {  // it's not a leaf

			/* break the string into three parts: the operator, the left operand,
               and the right operand. ***/
			setValue( s.substring( 0 , s.indexOf( "(" ) ) );
			// delimit the left operand 2008
			int left = s.indexOf("(")+1;
			int i = left;
			int parCount = 0;
			// find the comma separating the two operands
			while (parCount>=0 && !(s.charAt(i)==',' && parCount==0)) {
				if ( s.charAt(i) == '(' ) parCount++;
				if ( s.charAt(i) == ')' ) parCount--;
				i++;
			}
			int mid=i;
			if (parCount<0) mid--;

			// recursively build the left subtree
			setLeftChild(new expressionTreeNodeSolution(s.substring(left,mid)));

			if (parCount==0) {
				// it is a binary operator
				// find the end of the second operand.F13
				while ( ! (s.charAt(i) == ')' && parCount == 0 ) )  {
					if ( s.charAt(i) == '(' ) parCount++;
					if ( s.charAt(i) == ')' ) parCount--;
					i++;
				}
				int right=i;
				setRightChild( new expressionTreeNodeSolution( s.substring( mid + 1, right)));
			}
		}
	}


	// Returns a copy of the subtree rooted at this node... 2013
	expressionTreeNodeSolution deepCopy() {
		expressionTreeNodeSolution n = new expressionTreeNodeSolution();
		n.setValue( getValue() );
		if ( getLeftChild()!=null ) n.setLeftChild( getLeftChild().deepCopy() );
		if ( getRightChild()!=null ) n.setRightChild( getRightChild().deepCopy() );
		return n;
	}

	// Returns a String describing the subtree rooted at a certain node.
	public String toString() {
		String ret = value;
		if ( getLeftChild() == null ) return ret;
		else ret = ret + "(" + getLeftChild().toString();
		if ( getRightChild() == null ) return ret + ")";
		else ret = ret + "," + getRightChild().toString();
		ret = ret + ")";
		return ret;
	} 


	// Returns the value of the expression rooted at a given node
	// when x has a certain value
	double evaluate(double x) {
		// WRITE YOUR CODE HERE
		double ret=0;
		if (getRightChild()==null&&getLeftChild()==null) {
			if (this.value.equals("x")) return x;
			else return Double.parseDouble(this.value);
		}
		else if (getLeftChild()!=null&&getRightChild()!=null) {
			if (this.value.equals("add")) return getRightChild().evaluate(x) + getLeftChild().evaluate(x);
			else if (this.value.equals("mult")) return getRightChild().evaluate(x) * getLeftChild().evaluate(x);
			else if (this.value.equals("minus")) return getLeftChild().evaluate(x) - getRightChild().evaluate(x);
			else System.out.println("a1The following command / symbol is not recognized: "+this.value);
		}
		else if (getLeftChild()!=null&&getRightChild()==null){
			if (this.value.equals("exp")) return Math.exp(getLeftChild().evaluate(x));
			else if (this.value.equals("sin")) return Math.sin(getLeftChild().evaluate(x));
			else if (this.value.equals("cos")) return Math.cos(getLeftChild().evaluate(x));
			else System.out.println("a2The following command / symbol is not recognized: "+this.value);
		}
		else if (getLeftChild()==null&&getRightChild()!=null){
			System.out.println("I didn't think this would actually gets used");
			if (this.value.equals("exp")) return Math.exp(getRightChild().evaluate(x));
			else if (this.value.equals("sin")) return Math.sin(getRightChild().evaluate(x));
			else if (this.value.equals("cos")) return Math.cos(getRightChild().evaluate(x));
			else System.out.println("a3The following command / symbol is not recognized: "+this.value);
		}
		else System.out.println("An unexpected error occured parsing this command: "+this.value);
		// AND CHANGE THIS RETURN STATEMENT
		return ret;
	}                                                 

	/* returns the root of a new expression tree representing the derivative of the
       original expression */
	expressionTreeNodeSolution differentiate() {
		// WRITE YOUR CODE HERE
		expressionTreeNodeSolution d = this.deepCopy();
		if (d.getRightChild()==null&&d.getLeftChild()==null) {
			if (d.value.equals("x")) d.setValue("1");
			else d.setValue("0");
			return d;
		}
		else if (d.getLeftChild()!=null&&d.getRightChild()!=null) {
			if (d.value.equals("add")) {
				d.setRightChild(d.getRightChild().differentiate());
				d.setLeftChild(d.getLeftChild().differentiate());
			}
			else if (d.value.equals("minus")) {
				d.setLeftChild(d.getLeftChild().differentiate());
				d.setRightChild(d.getRightChild().differentiate());
			}
			else if (d.value.equals("mult")) {
				expressionTreeNodeSolution tmpL = d.getLeftChild().deepCopy();
				expressionTreeNodeSolution tmpR = d.getRightChild().deepCopy();
				d.setLeftChild(new expressionTreeNodeSolution("mult"));
				d.getLeftChild().setLeftChild(tmpL.differentiate());
				d.getLeftChild().setRightChild(tmpR);
				d.setRightChild(new expressionTreeNodeSolution("mult"));
				d.getRightChild().setLeftChild(tmpL);
				d.getRightChild().setRightChild(tmpR.differentiate());
				d.setValue("add");
			}
			else System.out.println("b1The following command / symbol is not recognized: "+d.value);
			return d;
		}
		else if (d.getLeftChild()!=null&&d.getRightChild()==null) {
			if (d.value.equals("exp")) {
				expressionTreeNodeSolution tmp = d.getLeftChild().deepCopy();
				d.setValue("mult");
				d.setLeftChild(new expressionTreeNodeSolution("exp"));
				d.getLeftChild().setLeftChild(tmp);
				d.setRightChild(tmp.differentiate());
			}
			else if (d.value.equals("sin")) {
				expressionTreeNodeSolution tmp = d.getLeftChild().deepCopy();
				d.setValue("mult");
				d.setLeftChild(new expressionTreeNodeSolution("cos"));
				d.getLeftChild().setLeftChild(tmp);
				d.setRightChild(tmp.differentiate());
			}
			else if (d.value.equals("cos")) {
				expressionTreeNodeSolution tmp = d.getLeftChild().deepCopy();
				d.setValue("mult");
				d.setLeftChild(new expressionTreeNodeSolution("minus"));
				d.getLeftChild().setLeftChild(new expressionTreeNodeSolution("0"));
				d.getLeftChild().setRightChild(new expressionTreeNodeSolution("sin"));
				d.getLeftChild().getRightChild().setLeftChild(tmp);
				d.setRightChild(tmp.differentiate());
			}
			else System.out.println("The following command / symbol is not recognized: "+d.value);
			return d;
		}
		else if (d.getLeftChild()==null&&d.getRightChild()!=null) {
			System.out.println("I'm beyond shocked this case was actually necessary");
			if (d.value.equals("exp")) {
				expressionTreeNodeSolution tmp = d.getRightChild().deepCopy();
				d.setValue("mult");
				d.setRightChild(new expressionTreeNodeSolution("exp"));
				d.getRightChild().setRightChild(tmp);
				d.setLeftChild(tmp.differentiate());
			}
			else if (d.value.equals("sin")) {
				expressionTreeNodeSolution tmp = d.getLeftChild().deepCopy();
				d.setValue("mult");
				d.setRightChild(new expressionTreeNodeSolution("cos"));
				d.getRightChild().setLeftChild(tmp);
				d.setLeftChild(tmp.differentiate());
			}
			else if (d.value.equals("cos")) {
				expressionTreeNodeSolution tmp = d.getLeftChild().deepCopy();
				d.setValue("mult");
				d.setRightChild(new expressionTreeNodeSolution("minus"));
				d.getRightChild().setLeftChild(new expressionTreeNodeSolution("0"));
				d.getRightChild().setRightChild(new expressionTreeNodeSolution("sin"));
				d.getRightChild().getRightChild().setLeftChild(tmp);
				d.setLeftChild(tmp.differentiate());
			}
			else System.out.println("The following command / symbol is not recognized: "+d.value);
			return d;
		}
		// AND CHANGE THIS RETURN STATEMENT                        
		return d;
	}


	public static void main(String args[]) {
		expressionTreeNodeSolution e = new expressionTreeNodeSolution("mult(x,x)");
		System.out.println(e);
		System.out.println(e.evaluate(5));
		System.out.println(e.differentiate());
		System.out.println(e.differentiate().evaluate(50));
	}
}