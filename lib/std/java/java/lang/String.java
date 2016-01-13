package java.lang;

public class String {

	private final char[] value;
	private int hash = 0;
	private int count = 0;

	public String() {
            this.count = 0;
            this.value = new char[0];
        }

        public String(char[] array) {
            this.count = array.length;
            this.value = array;
        }
        
        public String(char character) {
            this.count = 1;
            this.value = new char[1];
            this.value[0] = character;
        }
        
        public int length() {
            return this.value.length;
        }
        
        public char charAt(int index) {
            return this.value[index];
        }
        
        public String[] split(String delimiter) {
            String[] result = new String[1];
            int wordCount = 0;
            String word = "";
            
            for (int i=0; i<this.count; i++) {
                word += new String(this.value[i]);
                if (this.value[i] == delimiter.charAt(0)) {
                    result[wordCount] = word;
                    word = "";
                    wordCount++;
                }
            }
            result[wordCount] = word;
            return result;
        }

	public static native String valueOf(boolean b);
	public static native String valueOf(char c);
	public static native String valueOf(int i);
	public static native String valueOf(float f);
	public static native String valueOf(long l);
	public static native String valueOf(double d);
	public static native String valueOf(Object obj);

        public int hashCode() {
            int h = hash;
            if (h == 0 && count > 0) {
                char val[] = value;
                int len = count;

                for (int i = 0; i < len; i++) {
                    h = 31*h + val[i];
                }
                hash = h;
            }
            return h;
        }

        public boolean equals(String anObject) {
            if (this == anObject) {
                return true;
            }
            if (anObject instanceof String) {
                String anotherString = anObject;
                int n = count;
                if (n == anotherString.count) {
                    char v1[] = value;
                    char v2[] = anotherString.value;
                    int i = 0;
                    int j = 0;
                    while (n-- != 0) {
                        if (v1[i++] != v2[j++])
                            return false;
                    }
                    return true;
                }
            }
            return false;
        }


	public String toString() {
		return this;
	}
}