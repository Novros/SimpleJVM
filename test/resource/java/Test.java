public class Test {

    public native void Print(String text);

    public void hello() {
        Print("Hello from program.");
        int a = 3;
        int b = 2;
        int c = a + b;
        Print("a + b = " + c );
    }
}