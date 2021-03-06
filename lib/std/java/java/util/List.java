package java.util;

public interface List<E> {

    int size();

    boolean add(E e);

    E get(int index);

    void add(int index, E e);
}