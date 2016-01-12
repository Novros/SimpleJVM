public class InputFile {

    private String fileName;
    private static boolean loaded = false;

    InputFile(String filename) {
        if (!InputFile.loaded) {
            System.loadLibrary("InputFile");
            InputFile.loaded = true;
        }
        this.fileName = filename;
        open(filename.toCharArray());
    }

    public native void open(char[] filename);
    public native void close();
    private native int getLineSize();
    private native char readCharLine(int i);

    public String readLine() {
        int size = getLineSize();

        if(size == -1) {
            return null;
        }

        char[] charLine = new char[size];
        for(int i = 0; i < size; i++) {
            charLine[i] = readCharLine(i);
        }
        String line = new String(charLine);
        return line;
    }

    // TODO NotWorking
    public String readFile() {
        String file = "";
        String line = readLine();
        System.out.println(line);
        while (line != null) {
            file += line + "\n";
            line = readLine();
        }
        return file;
    }
}