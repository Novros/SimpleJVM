package java.nio.file;

import java.util.List;
import java.util.ArrayList;
import java.io.IOException;
import java.io.FileNotFoundException;
import java.nio.charset.Charset;
import java.nio.file.Path;
import java.nio.file.InputFile;
import java.nio.file.OutputFile;

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

        file.close();
        return result;
    }

    public static Path write(Path path, List<String> lines, Charset cs) throws FileNotFoundException, IOException {
        String path_str = path.get();
        OutputFile file = new OutputFile(path_str);

        for(int i = 0; i < lines.size(); i++ ) {
            file.writeLine(lines.get(i));
        }

        file.close();
        return path;
    }
}