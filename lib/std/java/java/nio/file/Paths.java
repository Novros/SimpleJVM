package java.nio.file;

import java.nio.file.Path;

public class Paths {

    private Paths() {}

    public static Path get(String first) {
        return new Path(first);
    }

}