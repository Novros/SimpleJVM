package file;

import java.nio.file.Paths;
/* import java.util.List;
import java.nio.file.Files;
import java.util.ArrayList;
import java.nio.charset.Charset;
import java.io.IOException; */

/* import java.io.File;
import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.FileWriter;
import java.io.FileReader;
import java.io.Writer;
import java.io.IOException;
import java.io.FileNotFoundException;*/

public class Main {
    public static void main(String[] args) {
        String testFile = "/home/tux/Git/Bitbucket/mi-run-javavm/test/resource/file/file.txt";
        System.out.println("Original file contents: " + getFileContent(testFile));
        // setFileContent(testFile, "The content of this file has been overwritten...");
        // System.out.println("New file contents: " + getFileContent(testFile));
    }

    public static String getFileContent(String file) throws IOException {
        List<String> lines = Files.readAllLines(Paths.get(file), Charset.defaultCharset());
        String output = "";
        for(String line : lines) {
            output = output + line + "\n";
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