package java.nio.file;

public class Charset {
    private String charset;

    public static Charset defaultCharset() {
        Charset chr = new Charset();
        return chr;
    }

    /*private Charset() {
        String charset = new String("UTF-8");
        this.charset = charset;
    }*/
}