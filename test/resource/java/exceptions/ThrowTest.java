public class ThrowTest {
    
    public static void main(String[] args) throws Exception {
        try {
            System.out.println("throwed");
            throw new TestException();
        } catch (Exception e) {
            System.out.println("catched");
        }
        
        System.out.println("end");
        
        int[] test = new int[2];
        test[0] = 5;
        System.out.println(""+test[0]);
    } 
}
