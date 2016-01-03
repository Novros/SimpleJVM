public class BigExample {

    public int simpleField = 100;
    public final int finalSimpleField = 100;


    public static void main() {
        int i = 5;
        BigExample example = new BigExample();
        example.simple(i);
    }

    public void simple(int arg) {
        double d = 0.25;
        System.out.println("Simple:arg=" + arg);
        System.out.println("Simple:d=" + d);

        int a = 10;
        int b = 150;
        System.out.println("greaterThan(a,b)=" + greaterThan(a,b));
        System.out.println("greaterThan(b,a)=" + greaterThan(b,a));

        float fa = 1.25f;
        float fb = 2.56f;
        System.out.println("greaterThan(fa,fb)=" + greaterThan(fa,fb));
        System.out.println("greaterThan(fb,fa)=" + greaterThan(fb,fa));

        int result = simpleSwitch(1);
        System.out.println("simpleSwitch(1)=" + result);
        result = simpleLookupSwitch(1);
        System.out.println("simpleLookupSwitch(1)=" + result);

        //result = simpleSwitch("a");
        //System.out.println("simpleSwitch(\"a\")" + result);

        whileLoop();
        forLoop();
        doWhileLoop();
    }

    public int greaterThan(int intOne, int intTwo) {
        if (intOne > intTwo) {
            return 0;
        } else {
            return 1;
        }
    }

    public int greaterThan(float floatOne, float floatTwo) {
       int result;
       if (floatOne > floatTwo) {
           result = 1;
       } else {
           result = 2;
       }
       return result;
    }

    public int simpleSwitch(int intOne) {
        switch (intOne) {
            case 0:
                return 3;
            case 1:
                return 2;
            case 4:
                return 1;
            default:
                return -1;
        }
    }

    public int simpleLookupSwitch(int intOne) {
        switch (intOne) {
            case 10:
                return 1;
            case 20:
                return 2;
            case 30:
                return 3;
            default:
                return -1;
        }
    }

    public int simpleSwitch(String stringOne) {
        switch (stringOne) {
            case "a":
                return 0;
            case "b":
                return 2;
            case "c":
                return 3;
            default:
                return 4;
        }
    }

    public void whileLoop() {
        int i = 0;
        while (i < 2) {
            i++;
        }
        System.out.println("whileLoop=" + i);
    }

    public void forLoop() {
        int next = 0;
        for(int i = 0; i < 2; i++) {
            next += 2;
        }
        System.out.println("forLoop=" + next);
    }

    public void doWhileLoop() {
        int i = 0;
        do {
            i++;
        } while (i < 2);
        System.out.println("doWhileLoop=" + i);
    }

}