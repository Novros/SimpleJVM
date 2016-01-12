
import java.nio.file.Paths;
import java.util.List;
import java.nio.file.Files;
import java.util.ArrayList;
import java.nio.charset.Charset;
import java.io.IOException;

public class Main {
    public static void main(String[] args) throws IOException {
        String fileName = "/home/tux/Git/Bitbucket/mi-run-javavm/test/resource/file/file.txt";
        System.out.println("Original file contents: " + getFileContent(fileName));
        // setFileContent(testFile, "The content of this file has been overwritten...");
        // System.out.println("New file contents: " + getFileContent(testFile));
    }

    public static String getFileContent(String file) throws IOException {
        List<String> lines = Files.readAllLines(Paths.get(file), Charset.defaultCharset());
        String output = "";
        for(int i = 0; i < lines.size(); i++) {
            output = output + lines.get(i);
        }
        return output;
    }


    /* public static String getFileContent(String file) {
        File aFile = new File(file);
        StringBuilder contents = new StringBuilder();

        try {
            BufferedReader input = new BufferedReader(new FileReader(file));
            try {
                String line = null;
                while ((line = input.readLine()) != null ) {
                    contents.append(line);
                    contents.append("\n");
                }
            } finally {
                input.close();
            }
        } catch (IOException ex) {
            ex.printStackTrace();
        }

        return contents.toString();
    } */

    /* public static void setFileContent(String fileName, String text) throws FileNotFoundException, IOException {
        File aFile = new File(fileName);
        if (aFile == null) {
          throw new IllegalArgumentException("File should not be null.");
        }
        if (!aFile.exists()) {
          throw new FileNotFoundException ("File does not exist: " + aFile);
        }
        if (!aFile.isFile()) {
          throw new IllegalArgumentException("Should not be a directory: " + aFile);
        }
        if (!aFile.canWrite()) {
          throw new IllegalArgumentException("File cannot be written: " + aFile);
        }

        //use buffering
        Writer output = new BufferedWriter(new FileWriter(aFile));
        try {
          output.write( text );
        }
        finally {
          output.close();
        }
    } */
}
