public class Test {

    public native void Print(String text);

    public void hello() {
        Print("Hello from program.");
        int a = 3;
        Print("a is " + a);
        /*int b = 2;
        Print("b is " + b);
        int c = a + b;
        Print("a + b = " + c );

        /*if(a > b) {
            Print("a is greater than b");
        } else {
            Print("b is greater then a");
        }*/
    }


}
