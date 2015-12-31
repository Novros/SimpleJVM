public class Test {

    int a = 5;
    int b = 120;

    public Test() {
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

        int work = 1;
        int not_work = 0;
        String str =  "Is it working?";

        /*long long_1 = 2;
        long long_2 = 1;

        if (long_1 < long_2) {
            Print(str + " " + not_work);
        } else {
            Print(str + " " + work);
        }

        float double_1 = 1.2f;
        float double_2 = 2.3f;

        if (double_1 == double_2 ) {
            Print("Equals");
        } else {
            Print(str);
        }*/
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