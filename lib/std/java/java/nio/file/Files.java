package java.nio.file;

import java.util.List;
import java.util.ArrayList;
import java.io.IOException;
import java.nio.charset.Charset;
import java.nio.file.Path;
import java.nio.file.InputFile;

public class Files {

    public static List<String> readAllLines(Path path, Charset cs) throws IOException {
        String path_str = path.get();
        InputFile file = new InputFile(path_str);
        ArrayList<String> result = new ArrayList<>();

        String line = file.readLine();
        while(line != null) {
            result.add(line);
            line = file.readLine();
        }
        return result;
    }
}