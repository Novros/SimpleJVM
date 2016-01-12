
public class Variable {
	private int index;
	private int weight;


	public Variable(int index, int weight){
		this.index = index;
		this.weight = weight;
	}

	public int getIndex() {
		return Math.abs(index);
	}

	public int isNegation() {
		if (index < 0) {
			return 1;
		} else {
			return 0;
		}
	}

	public int getWeight() {
		return weight;
	}

	public boolean evaluate(int combination) {
                System.out.println("variable evaluation start");
		return !((combination >> this.getIndex() - 1 & 1) == this.isNegation());
	}

	@Override
	public String toString() {
		return "{" + index +
				", " + weight +
				'}';
	}
}
