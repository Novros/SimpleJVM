package java.nio.file;

public class OutputFile {

    private String fileName;

    OutputFile(String filename) {
        this.fileName = filename;
        open(filename);
    }

    public native void open(String filename);
    public native void close();
    public native String write();
}