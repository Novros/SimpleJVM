import java.nio.file.Paths;
import java.util.List;
import java.nio.file.Files;
import java.util.ArrayList;
import java.nio.charset.Charset;
import java.io.IOException;
import java.io.FileNotFoundException;

public class SATSolverRUN {
	private static Formula readFile(String filePath) throws IOException {
            List<String> lines = Files.readAllLines(Paths.get(filePath), Charset.defaultCharset());
            int[] weights = new int[0];
            Formula formula = null;

            for (int k=0; k<lines.size(); k++) {
                String line = lines.get(k);
                String[] tokens = line.split(" ");
                
                if (line.charAt(0) == 'w') {
                    weights = new int[tokens.length-1];
                    for (int i=1; i<tokens.length; i++) {
                        weights[i-1] = Integer.parseInt(tokens[i]);
                    }
                } else if (line.charAt(0) == 'p') {
                    formula = new Formula(Integer.parseInt(tokens[2]));
                } else {
                    Clause clause = new Clause();

                    for (int i=0; i<tokens.length-1; i++) {
                        int index = Integer.parseInt(tokens[i]);
                        int weight = weights[Math.abs(index)-1];

                        clause.addVariable(index, weight);
                        formula.addVariable(index, weight);
                    }

                    if (formula != null) {
                        formula.addClause(clause);
                    }
                }
            }

            return formula;
	}

	public static void main(String[] args) throws IOException {
            if (args.length < 2 ) {
                System.err.println("No file as arguments.");
                return;
            }
            
            String inputFile = args[0];
            String outputFile = args[1];

            Formula formula = readFile(inputFile);
            System.out.println("file parsed");
            BruteForce bf = new BruteForce();
            bf.setFormula(formula);
            float bfWeight = bf.solve();
            
            String result = "BF; Max weight: " + bfWeight + "\nBF; Best combination: " + bf.getBestRating();
            System.out.println(result);
            setFileContent(outputFile, result);
            System.out.println("Result was also saved to " + outputFile);
	}
	
	public static void setFileContent(String fileName, String text) throws FileNotFoundException, IOException {
            ArrayList<String> lines = new ArrayList<String>();
            lines.add(text);
            Files.write(Paths.get(fileName), lines, Charset.defaultCharset());
        }
}
