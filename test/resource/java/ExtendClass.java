public class ExtendClass extends EmptyMethod {
    public void notEmptyMethod(int a, int b) {
        int c = a + b;
        c = c - a;
        if (c == b) {
            c = a;
        } else if (c == a) {
            c = b;
        } else {
            c = 0;
        }
    }
}