package java.lang;

public final class Math {
    public static final double E = 2.718281828459045D;
    public static final double PI = 3.141592653589793D;

    public static int abs(int a) {
        return a < 0?-1*a:a;
    }

    public static long abs(long a) {
        return a < 0L?-1*a:a;
    }

    public static float abs(float a) {
        return a <= 0.0F?a*-1F:a;
    }

    public static double abs(double a) {
        return a <= 0.0D?a*-1D:a;
    }

    public static int max(int a, int b) {
        return a >= b?a:b;
    }
    
    public static float max(float a, float b) {
        return a >= b?a:b;
    }
    
    public static long max(long a, long b) {
        return a >= b?a:b;
    }

    public static int min(int a, int b) {
        return a <= b?a:b;
    }
    
    public static float min(float a, float b) {
        return a <= b?a:b;
    }

    public static long min(long a, long b) {
        return a <= b?a:b;
    }

    public static double pow(int a, int b) {
        int result = 1;
        for (int i=0; i<b; i++) {
            result *= a;
        }

        return (double)result;
    }
}
