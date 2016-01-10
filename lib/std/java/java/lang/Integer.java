package java.lang;
 
public class Integer {
    private int value = 0;
    
    public Integer(int value) {
        this.value = value;
    }
    
    @Override
    public String toString() {
        return "" + this.value;
    }
    
}