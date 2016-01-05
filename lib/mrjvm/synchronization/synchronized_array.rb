require_relative '../../mrjvm'

class SynchronizedArray < Array


  def push(value)
    MRjvm::MRjvm.mutex.synchronize do
      super(value)
    end
  end

  def pop
    MRjvm::MRjvm.mutex.synchronize do
      super
    end
  end

  def delete(value)
    MRjvm::MRjvm.mutex.synchronize do
      super(value)
    end
  end
end