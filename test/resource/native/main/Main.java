public class Main {

    public native int intMethod(int i);

    public native char[] some_char();

    public static void main(String[] args) {
        System.loadLibrary("Main");
        Main main = new Main();
        System.out.println("" + main.intMethod(2));
        System.out.println("" + main.intMethod(2));
        String text = new String(main.some_char());
        System.out.println(text);
    }
}