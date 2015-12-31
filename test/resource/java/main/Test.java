package main;

public class Test {

    public native void Print(String text);

    int a;
    int b = 2;
    int c = 1000;

    public Test() {
        this.a = 5;
    }

    public void hello(String name) {
        System.out.println("Hello " + name + "!");
    }

    public int test() {
        if(a > b) {
            Print("a is greater than b");
        } else {
            Print("b is greater then a");
        }

        return c;
    }

}
