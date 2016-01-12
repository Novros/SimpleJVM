
import java.nio.file.Paths;
import java.util.List;
import java.nio.file.Files;
import java.util.ArrayList;
import java.nio.charset.Charset;
import java.io.IOException;
import java.io.FileNotFoundException;

public class Main {
    public static void main(String[] args) throws IOException {
        if (args.length < 2 ) {
            System.err.println("No file as arguments.");
            return;
        }
        String inputFile = args[0];
        String outputFile = args[1];
        String fileText = getFileContent(inputFile);
        System.out.println("Original file contents: " + fileText);
        setFileContent(outputFile, fileText + "\nThe content of this file has been overwritten...");
        System.out.println("New file contents: " + getFileContent(outputFile));
    }

    public static String getFileContent(String file) throws IOException {
        List<String> lines = Files.readAllLines(Paths.get(file), Charset.defaultCharset());
        String output = "";
        for(int i = 0; i < lines.size(); i++) {
            output = output + lines.get(i) + "\n";
        }
        return output;
    }

    public static void setFileContent(String fileName, String text) throws FileNotFoundException, IOException {
        ArrayList<String> lines = new ArrayList<String>();
        lines.add(text);
        Files.write(Paths.get(fileName), lines, Charset.defaultCharset());
    }
}
