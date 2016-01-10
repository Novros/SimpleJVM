public class MathTest {

    public static void main() {
        System.out.println("abs(-1)=" + Math.abs(-1));
        System.out.println("abs(-128)=" + Math.abs(-128));
        System.out.println("abs(127)=" + Math.abs(127));
        System.out.println("abs(-127)=" + Math.abs(-127));
        System.out.println("abs(-0)=" + Math.abs(-0));
        System.out.println("abs(0)=" + Math.abs(0));
        System.out.println("abs(-256)=" + Math.abs(-256));
        System.out.println("abs(-5)=" + Math.abs(-5));
        System.out.println("abs(-5.0)=" + Math.abs(-5.0f));
        System.out.println("abs(6.5)=" + Math.abs(6.5f));
        System.out.println("max(5,10)=" + Math.max(5, 10));
        System.out.println("max(11, -8)=" + Math.max(11, -8));
        System.out.println("min(5,10)=" + Math.min(5, 10));
        System.out.println("min(11, -8)=" + Math.min(11, -8));
        System.out.println("pow(5, 2)=" + Math.pow(5, 2));
        System.out.println("pow(2, 10)=" + Math.pow(2, 10));
        
        System.out.println("max(5.5,5.6)=" + Math.max(5.5f, 5.6f));
        System.out.println("min(11.2, 13)=" + Math.min(11.2f, 13f));
        
        System.out.println("abs(25026)=" + Math.abs(25026));
        System.out.println("abs(-60000)=" + Math.abs(-60000));
    }
}
