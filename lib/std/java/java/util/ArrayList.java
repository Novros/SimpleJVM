package java.util;

import java.util.List;

public class ArrayList<E> implements List<E> {
	private Object[] elementData;
	private int size = 0;

	public ArrayList() {
		this.elementData = new Object[10];
	}

	private void rangeCheck(int index) {
		if(index >= this.size) {
			throw new IndexOutOfBoundsException(this.outOfBoundsMsg(index));
		}
	}

	private String outOfBoundsMsg(int index) {
		return "Index: " + index + ", Size: " + this.size;
	}

	public void add(int index, E element) {
		this.rangeCheck(index);
		this.checkCapacity(this.size + 1);
		this.elementData[index] = element;
		this.size += 1;
	}

	private void checkCapacity(int index) {
		if (this.elementData.length < index) {
			this.grow();
		}
	}

	private void grow() {
		int newCapacity = this.size + 500;
		Object[] newArray = new Object[newCapacity];

		for (int i=0; i<this.size; i++) {
			newArray[i] = this.elementData[i];
		}

		this.elementData = newArray;
	}

	public boolean add(E e) {
		//this.checkCapacity(this.size + 1);
		this.elementData[this.size] = e;
		this.size += 1;

		return true;
	}

	public E get(int index) {
		this.rangeCheck(index);
		return (E) this.elementData[index];
	}
	
	public int size() {
            return this.size;
	}
}

