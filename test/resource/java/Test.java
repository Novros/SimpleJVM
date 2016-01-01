public class Test {

    public static int stat = 0;

    int a = 5;
    int b = 120;

    public Test() {
        this.a = 5;
        this.b = 120;
    }

    public static native void Print(String str);

    public static void main() {
        Print("Hello");
        testEntry("lol");
        Test.testEntry("neco");

        Factorial factorial = new Factorial();
        factorial.entry();
    }

    public static void testEntry(String text) {
        Print("Neco " + text);
    }

    public void entry() {
        // Test.stat = 5;
        // Print("" + Test.stat);

        int[] array = new int[10];
        array[1] = 5;
        array[0] = 546;

        Print("" + array[1] + ", " + array[0]);

        // Test[] tarray = new Test[10];
        // trray[0] = new Test();

        /*Print("Factorial numbers.");
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