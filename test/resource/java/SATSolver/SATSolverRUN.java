

import java.util.ArrayList;

public class SATSolverRUN {
	/*private static Formula readFile(String filePath) throws IOException {
		List<String> lines = Files.readAllLines(Paths.get(filePath), Charset.defaultCharset());

		Formula formula = null;

		for (String line : lines) {
			String[] tokens = line.split(" ");

			if (line.charAt(0) == 'c') {
				continue;
			} else if (line.charAt(0) == 'w') {
				weights = new int[tokens.length-1];
				for (int i=1; i<tokens.length; i++) {
					weights[i-1] = Integer.parseInt(tokens[i]);
				}
			} else if (line.charAt(0) == '%') {
				return formula;
			} else if (line.charAt(0) == 'p') {
				formula = new Formula(Integer.parseInt(tokens[2]));
			} else if (tokens[0].equals("")) {
				Clause clause = new Clause();

				for (int i=1; i<tokens.length-1; i++) {
					int index = Integer.parseInt(tokens[i]);
					int weight = weights[Math.abs(index)-1];
					//int weight = generateWeight();

					clause.addVariable(index, weight);
					formula.addVariable(index, weight);
				}

				if (formula != null) {
					formula.addClause(clause);
				}
			} else {
				Clause clause = new Clause();

				for (int i=0; i<tokens.length-1; i++) {
					int index = Integer.parseInt(tokens[i]);
					int weight = weights[Math.abs(index)-1];
					//int weight = generateWeight();

					clause.addVariable(index, weight);
					formula.addVariable(index, weight);
				}

				if (formula != null) {
					formula.addClause(clause);
				}
			}
		}

		return formula;
	}*/

	public static void main(String[] args) {
		int[] weights = {3, 4, 1, 6};
                System.out.println("start");
		
		Formula formula = new Formula(4);
		Clause clause = new Clause();
		clause.addVariable(1, weights[0]);
		clause.addVariable(-3, weights[2]);
		clause.addVariable(4, weights[3]);

		formula.addVariable(1, weights[0]);
		formula.addVariable(-3, weights[2]);
		formula.addVariable(4, weights[3]);
		formula.addClause(clause);
		System.out.println("added 1");

		clause = new Clause();
		clause.addVariable(-1, weights[0]);
		clause.addVariable(2, weights[1]);
		clause.addVariable(3, weights[2]);

		formula.addVariable(-1, weights[0]);
		formula.addVariable(2, weights[1]);
		formula.addVariable(3, weights[2]);

		formula.addClause(clause);
		System.out.println("added 2");

		clause = new Clause();
		clause.addVariable(3, weights[2]);
		clause.addVariable(4, weights[3]);

		formula.addVariable(3, weights[2]);
		formula.addVariable(4, weights[3]);

		formula.addClause(clause);
		System.out.println("added 3");

		clause = new Clause();
		clause.addVariable(1, weights[0]);
		clause.addVariable(2, weights[1]);
		clause.addVariable(-3, weights[2]);
		clause.addVariable(-4, weights[3]);

		formula.addVariable(1, weights[0]);
		formula.addVariable(2, weights[1]);
		formula.addVariable(-3, weights[2]);
		formula.addVariable(-4, weights[3]);

		formula.addClause(clause);
		System.out.println("added 4");

		clause = new Clause();
		clause.addVariable(-2, weights[1]);
		clause.addVariable(3, weights[2]);

		formula.addVariable(-2, weights[1]);
		formula.addVariable(3, weights[2]);

		formula.addClause(clause);
		System.out.println("added 5");

		clause = new Clause();
		clause.addVariable(-3, weights[2]);
		clause.addVariable(-4, weights[3]);

		formula.addVariable(-3, weights[2]);
		formula.addVariable(-4, weights[3]);

		formula.addClause(clause);
                System.out.println("added 6");

		//Formula formula = readFile("satExample.cnf");
		BruteForce bf = new BruteForce();
		bf.setFormula(formula);
		float bfWeight = bf.solve();
		System.out.println("BF; Max weight: " + bfWeight);
		System.out.println("BF; Best combination: " + bf.getBestRating());
	}
}
