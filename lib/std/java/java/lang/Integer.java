package java.lang;
 
public class Integer {
    private int value = 0;
    
    public Integer(int value) {
        this.value = value;
    }
    
    public static int parseInt(String stringNumber) {
        int resultNumber = 0;
        boolean negative = false;
        int startPos = 0;
        
        if (stringNumber.charAt(0) == '-') {
            negative = true;
            startPos = 1;
        }
        
        for(int i=startPos; i<stringNumber.length(); i++) {
            if (( (int)stringNumber.charAt(i) >= 48) && ( (int)stringNumber.charAt(i) <= 57)) {
                resultNumber = resultNumber * 10 + ((int)stringNumber.charAt(i) - 48); 
            } else {
                //throw new NumberFormatException();
            }
        }

        return negative?-1*resultNumber:resultNumber; 
    }
    
    @Override
    public String toString() {
        return "" + this.value;
    }
    
}