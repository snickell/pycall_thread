module PyCallThread
  @queue = Queue.new

  VALID_UNSAFE_RETURN_VALUES = [:allow, :error, :warn]

  def self.init(unsafe_return: :error, &require_pycall_block)
    # Only safe to use PyCallThread if PyCall hasn't already been loaded
    raise "PyCall::LibPython already exists: PyCall can't have been initialized already" if defined?(PyCall::LibPython)

    @initialized = true

    if VALID_UNSAFE_RETURN_VALUES.include?(unsafe_return)
      @unsafe_return = unsafe_return
    else
      raise ArgumentError, "Invalid value for unsafe_return: #{unsafe_return}. Must be one of: #{VALID_UNSAFE_RETURN_VALUES.join(', ')}"
    end
    
    # Start the thread we will use to run code invoked with PyCallThread.run
    # If we've been passed a require_pycall_block, use that to require 'pycall'
    # instead of doing it directly.
    @py_thread = Thread.new { pycall_thread_loop(&require_pycall_block) }

    at_exit { stop_pycall_thread }

    nil
  end

  # Runs &block on the PyCall thread, and returns the result
  def self.run(&block)
    init unless @initialized

    result_queue = Queue.new
    @queue << -> { result_queue << block.call }
    retval = result_queue.pop

    puts "pycall_thread.done, retval = #{retval.inspect}"

    if python_object?(retval)
      case @unsafe_return
      when :error
        raise "Trying to return a python object from PyCDO.lock_python_gil block is potentially not thread-safe. Please convert it to a basic Ruby type (like string, array, number, boolean etc) before returning."
      when :warn
        warn "Warning: Returning a Python object from PyCDO.lock_python_gil block is potentially not thread-safe. Please convert it to a basic Ruby type (like string, array, number, boolean etc) before returning."
      end
    end

    puts "returning from pycall.run"
    retval
  end

  def self.stop_pycall_thread
    @queue << :stop
  end

  def self.pycall_thread_loop(&require_pycall_block)
    Thread.current.name = "pycall"

    # require 'pycall' or run a user-defined block that should do the same
    if require_pycall_block
      require_pycall_block.call
    else
      require 'pycall'
    end

    loop do
      block = @queue.pop
      break if block == :stop
      block.call
    rescue => e
      puts "pycall_thread_loop(): exception in pycall_thread_loop #{e}"
    end

    # If PyCall.finalize is not present, the main proces will hang at exit
    # See: https://github.com/mrkn/pycall.rb/pull/187
    PyCall.finalize if PyCall.respond_to?(:finalize)
  end

  def self.python_object?(obj)
    [
      PyCall::IterableWrapper,
      PyCall::PyObjectWrapper,
      PyCall::PyModuleWrapper,
      PyCall::PyObjectWrapper,
      PyCall::PyTypeObjectWrapper,
      PyCall::PyPtr,
    ].any? { |kind| obj.is_a?(kind) }
  end
end