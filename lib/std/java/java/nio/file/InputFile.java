package java.nio.file;

public class InputFile {

    private String fileName;

    InputFile(String filename) {
        this.fileName = filename;
        open(filename.toCharArray());
    }

    public native void open(char[] filename);
    public native void close();

    private native char[] readLineNative();
    private native char[] readFileNative();

    public String readLine() {
        char[] charLine = readLineNative();
        return new String(charLine);
    }
    public String readFile() {
        char[] charFile = readFileNative();
        return new String(charFile);
    }
}