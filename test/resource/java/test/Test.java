package test;

import test.Factorial;

public class Test {

    public static int stat = 0;

    int a = 5;
    int b = 120;

    public Test() {
        this.a = 5;
        this.b = 120;
    }

    public static void main() {
        System.out.println("Hello");
        testEntry("lol");
        Test.testEntry("neco");

        Factorial factorial = new Factorial();
        factorial.entry();

        int de = 0;
        for(int i = 0; i < 150; i++) {
            de++;
        }
        System.out.println("" + de);
    }

    public static void testEntry(String text) {
        System.out.println("Neco " + text);
    }
}