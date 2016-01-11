 package java.lang;

public class Throwable {
    
    String message;
    
    public Throwable() {
    }

    public Throwable(String message) {
        this.message = message;
    }
    
    public String getMessage() {
        return this.message;
    }
}
