package test;

public class Factorial {

    int a = 5;
    int b;

    public Factorial() {
        this.b = 120;
    }

    public void entry() {
        System.out.println("Factorial numbers.");
        int c = factorial(a);
        if( c == b)
            System.out.println("Result is 120");
        else
            System.out.println("Result is something another: " + c);
    }

    private int factorial(int n) {
        if (n <= 1)
            return 1;
        else
            return n*factorial(n-1);
    }
}