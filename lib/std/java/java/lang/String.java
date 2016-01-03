package java.lang;

public class String {

	private final char value[];
	private int hash = 0;
	private int count = 0;

	public String() {
        this.count = 0;
        this.value = new char[0];
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