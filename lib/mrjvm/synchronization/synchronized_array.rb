require_relative '../../mrjvm'

# Synchronized access to shared resources for GC thread and main thread
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