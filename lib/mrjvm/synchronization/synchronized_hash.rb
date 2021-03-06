require_relative '../../mrjvm'

# Synchronized access to shared resources for GC thread and main thread
class SynchronizedHash < Hash
  def []=(key, value)
    MRjvm::MRjvm.mutex.synchronize do
      super(key, value)
    end
  end

  def delete(key, synchronize)
    if synchronize
      MRjvm::MRjvm.mutex.synchronize do
        super(key)
      end
    else
      super(key)
    end
  end
end