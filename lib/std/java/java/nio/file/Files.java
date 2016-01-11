package java.nio.file;

import java.utils.List;
import java.utils.ArrayList;

public class Files {

    // Native method to read one line from file.
    private static native char[] readLineNative();
    // Native method to read all lines from file.
    private static native String[] readAllLinesNative(String file);
    // Read line from file by native readLine
    private static String readLine();


    public static List<String> readAllLines(Path path, Charset cs) throws IOException {
        List<String> result = new ArrayList<>();

        for(;;;) {
            String line =
        }
    }
}