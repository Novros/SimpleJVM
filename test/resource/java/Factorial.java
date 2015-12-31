public class Factorial {

    int a = 5;
    int b = 120;

    public Factorial() {
        // TODO No working
        this.a = 5;
        this.b = 120;
    }

    public native void Print(String str);

    public void entry() {
        Print("Factorial numbers.");
        int a = 10;
        int b = 120;
        int t = test(1,2);
        Print("" + t);
        int c = factorial(a);
        if( c == b)
            Print("Result is 120");
        else
            Print("Result is something another: " + c);
    }

    private int test(int a, int b) {
        if (a > b) {
            return 0;
        } else {
            return test(a+1,b);
        }
    }

    private int factorial(int n) {
        if (n <= 1)
            return 1;
        else
            return n*factorial(n-1);
    }
}