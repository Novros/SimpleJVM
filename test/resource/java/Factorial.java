public class Factorial {

    int a = 5;
    int b;

    public static native void Print(String str);

    public Factorial() {
        this.b = 120;
    }

    public void entry() {
        Print("Factorial numbers.");
        int c = factorial(a);
        if( c == b)
            Print("Result is 120");
        else
            Print("Result is something another: " + c);
    }

    private int factorial(int n) {
        if (n <= 1)
            return 1;
        else
            return n*factorial(n-1);
    }
}