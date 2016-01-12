public class BruteForce {
        
        protected Formula formula;
	protected int bestRating = 0;

	public void setFormula(Formula formula) {
		this.formula = formula;
		
		this.bestRating = 0;
	}

	public int getBestRating() {
		return bestRating;
	}
	
	public int solve() {
                System.out.println("solve started");
		int combinationsCount = (int)Math.pow(2, this.formula.getVariablesCount());
		int maxWeight = 0;

		for (int x=0; x<combinationsCount; x++) {
                        System.out.println("iteration start " + x);
			boolean evaluation = formula.evaluate(x);
			if (evaluation) {
                                System.out.println("true");
				int combinationWeight = getCombinationWeight(x, formula);
				if (combinationWeight > maxWeight) {
					maxWeight = combinationWeight;
					bestRating = x;
				}
			}
			System.out.println("iteration ended " + x);
		}
                System.out.println("solve ended.");
		return maxWeight;
	}

	/**
	 * @param combination - int combination for binary shift and &
	 * @param formula Formula
	 * @return total weight or -1 if formula is not true for this combination
	 */
	public int getCombinationWeight(int combination, Formula formula) {
		int totalWeight = 0;
                System.out.println("get combination weight for " + combination);
		for (int i=0; i<formula.getVariablesCount(); i++) {
			if ((combination >> i & 1) == 1) {
				Variable variable = formula.getVariable(i+1);
				totalWeight += variable.getWeight();
			}
		}
                System.out.println("weight for combination is " + totalWeight);
		return totalWeight;
	}
}
