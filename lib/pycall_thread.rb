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

    at_exit do
      stop_pycall_thread
    end

    nil
  end

  # Runs &block on the PyCall thread, and returns the result
  def self.run(&block)
    init unless @initialized

    result_queue = Queue.new
    @queue << -> do
      begin
        result_queue << { retval: block.call }
      rescue => e
        result_queue << { exception: e }
      end
    end

    result = result_queue.pop

    if result[:exception]
      raise result[:exception]
    elsif python_object?(result[:retval])
      msg = "Trying to return a python object from a PyCallThread.run block is potentially not thread-safe. Please convert #{result.inspect} to a basic Ruby type (like string, array, number, boolean etc) before returning."
      case @unsafe_return
      when :error
        raise msg
      when :warn
        warn "Warning: #{msg}"
      end
    end

    result[:retval]
  end

  def self.stop_pycall_thread
    @queue << :stop
    @py_thread.join
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
      puts e.backtrace.join("\n")
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