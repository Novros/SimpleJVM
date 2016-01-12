package java.nio.file;

public class InputFile {

    private String fileName;

    InputFile(String filename) {
        this.fileName = filename;
        open(filename);
    }

    public native void open(String filename);
    public native void close();
    public native String readLine();
    public native String readFile();
}