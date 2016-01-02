package java.lang;

import java.io.PrintStream;

public class System {

    public final static PrintStream out = new PrintStream();
    public final static PrintStream err = new PrintStream();

    public static native void loadLibrary(String libName);
}