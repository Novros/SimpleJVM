package java.nio.file;

public class Path {
    private String filename;

    public Path(String filename) {
        this.filename = filename;
    }

    public String get() {
        return filename;
    }
}