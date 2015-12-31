package main;

import main.Test;

public class Main {

    public static void main() {
        Test test = new Test();
        test.hello("Program");
        int value = test.test();
        System.out.println("Test method returns: " + value + "!");
    }
}