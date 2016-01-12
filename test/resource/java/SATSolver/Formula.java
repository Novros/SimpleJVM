
import java.util.ArrayList;

public class Formula {
	private ArrayList<Clause> clauses = new ArrayList<Clause>();
	private ArrayList<Variable> variables = new ArrayList<Variable>();

	private int variablesCount = 0;

	public Formula(int variablesCount) {
		this.variablesCount = variablesCount;
	}

	public void addClause(Clause clause) {
		this.clauses.add(clause);
	}

	public ArrayList<Clause> getClauses() {
		return clauses;
	}

	public int getVariablesCount() {
		return variablesCount;
	}

	public int getClausesCount() {
		return clauses.size();
	}

	public void addVariable(int index, int weight) {
		this.variables.add(new Variable(index, weight));
	}

	public Variable getVariable(int index) {
		for (Variable variable: variables) {
			if (variable.getIndex() == index) {
				return variable;
			}
		}

		return null;
	}

	public boolean evaluate(int combination) {
		for (Clause clause: this.clauses) {
			if (!clause.evaluate(combination)) {
				return false;
			}
		}

		return true;
	}

	public boolean evaluate(boolean[] valuesOfVariables) {
		int ok = 0;
		for (Clause clause: this.clauses) {
			if (!clause.evaluate(valuesOfVariables)) {
				return false;
			}
		}

		return true;
	}

	@Override
	public String toString() {
		return "Formula{" + clauses +
				'}';
	}
}
