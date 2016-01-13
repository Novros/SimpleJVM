
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
                //System.out.println("clause evaluation start");
		for (int i=0; i<variables.size(); i++) {
			Variable variable = variables.get(i);
			if (variable.evaluate(combination)) {
                                //System.out.println("clause true");
				return true;
			}
		}
		
		return false;
	}

	@Override
	public String toString() {
		return "{" + variables.toString() +
				"}" + "\n";
	}
}