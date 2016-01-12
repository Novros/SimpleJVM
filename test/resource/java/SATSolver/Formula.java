
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
		for (int i=0; i<variables.size(); i++) {
			Variable variable = variables.get(i);
			if (variable.getIndex() == index) {
				return variable;
			}
		}

		return null;
	}

	public boolean evaluate(int combination) {
                System.out.println("formula evaluation start");
		for (int i=0; i<clauses.size(); i++) {
                        System.out.println("formula evaluation iteration " + i);
			Clause clause = clauses.get(i);
			if (!clause.evaluate(combination)) {
                                System.out.println("formula false");
				return false;
			}
			System.out.println("formula evaluation iteration " + i + " ends");
		}

		return true;
	}

	@Override
	public String toString() {
		return "Formula{" + clauses +
				'}';
	}
}
