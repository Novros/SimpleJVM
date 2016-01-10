import java.util.ArrayList;

public class ArrayListTest {
	public static void main(String[] args) {
		ArrayList<Integer> testList = new ArrayList<Integer>();
		for (int i=0; i<5; i++) {
                    Integer number = new Integer(i);
                    testList.add(number);
                    System.out.println("added " + number.toString());
		}
                
                for (int i=0; i<5; i++) {
                    System.out.println(testList.get(i).toString());
		}
		
                System.out.println("total size or list is: " + testList.size());
	}
}
