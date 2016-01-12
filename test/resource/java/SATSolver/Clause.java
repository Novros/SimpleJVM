
import java.util.ArrayList;

public class Clause {

	private ArrayList<Variable> variables = new ArrayList<Variable>();

	public void addVariable(int index, int weight) {
		this.variables.add(new Variable(index, weight));
	}

	public ArrayList<Variable> getVariables() {
		return variables;
	}

	public int getVariablesCount() {
		return this.variables.size();
	}

	public boolean evaluate(int combination) {
		for (Variable variable: this.variables) {
			if (variable.evaluate(combination)) {
				return true;
			}
		}

		return false;
	}

	@Override
	public String toString() {
		return "{" + variables +
				'}' + "\n";
	}
}