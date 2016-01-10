package file;

import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.List;
import java.util.ArrayList;
import java.nio.charset.Charset;
import java.io.IOException;

public class Main {
    public static void main(String[] args) throws IOException {
        String testFile = "/home/tux/Git/Bitbucket/mi-run-javavm/test/resource/file/file.txt";
        System.out.println("Original file contents: " + getFileContent(testFile));
        // setFileContent(testFile, "The content of this file has been overwritten...");
        System.out.println("New file contents: " + getFileContent(testFile));
    }

    public static String getFileContent(String file) throws IOException {
        List<String> lines = Files.readAllLines(Paths.get(file), Charset.defaultCharset());
        String output = "";
        for(String line : lines) {
            output = output + line + "\n";
        }
        return output;
    }
}