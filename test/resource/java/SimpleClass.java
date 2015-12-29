public class SimpleClass {
    private int numberOne = 0;
    private int numberTwo = 0;

    SimpleClass(int numberOne) {
        this.numberOne = numberOne;
    }

    public void setNumberTwo(int numberTwo) {
        this.numberTwo = numberTwo;
    }

    public int getNumberOne() {
        return numberOne;
    }

    public int getNumberTwo() {
        return numberTwo;
    }

    public String toString() {
        return ">>" + numberOne + " " + numberTwo;
    }
}