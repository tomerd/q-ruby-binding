require 'ffi'
require 'json'

module Qlib
  extend FFI::Library
  
  ffi_lib 'libq'
  #ffi_convention :stdcall
  
  #callback :worker_delegate, [ :pointer ], :void
  callback :observer_delegate, [ :pointer ], :void
    
  attach_function :q_version, :q_version, [ ], :string
  attach_function :q_connect, :q_connect, [ :pointer, :string ], :void
  attach_function :q_disconnect, :q_disconnect, [ :pointer ], :void
  attach_function :q_post, :q_post, [ :pointer, :string, :string, :string, :long, :pointer ], :void
  attach_function :q_reschedule, :q_reschedule, [ :pointer, :string, :long ], :bool
  attach_function :q_cancel, :q_cancel, [ :pointer, :string ], :bool
  #attach_function :q_worker, :q_worker, [ :pointer, :string, :worker_delegate ], :void
  attach_function :q_worker, :q_worker, [ :pointer, :string, :pointer ], :void
  attach_function :q_observer, :q_observer, [ :pointer, :string, :observer_delegate ], :void
  attach_function :q_flush, :q_flush, [ :pointer ], :void
  
end

module Q
  
  class Job
    
    def initialize *args
      case args.size
        when 1
          init1 *args
        when 2
          init2 *args
        when 3
          init3 *args
        else
          error
      end
    end
    
    def init1(data)
      @uid = nil
      @data = data
      @run_at = 0
    end
    
    def init2(data, run_at)
      @uid = nil
      @data = data
      @run_at = run_at
    end
    
    def init3(uid, data, run_at)
      @uid = uid
      @data = data
      @run_at = run_at
    end
    
    def uid 
      @uid
    end
    
    def data 
      @data
    end
    
    def run_at 
      @run_at
    end
    
    def valid?
      !@data.nil?
    end
      
  end
  
  class Q
    
    def initialize
      @pq = nil
      @workers = []
      @observers = []
    end
        
    def version
      Qlib::q_version
    end
    
    def connect(config=nil)
      throw "already connected" if @pq
      pq = FFI::MemoryPointer.new(:pointer)
      config = config.to_json if config && config.is_a?(Hash)
      Qlib::q_connect(pq, config)
      @pq = FFI::MemoryPointer.new(:pointer)
      @pq = pq.read_pointer
    end
    
    def disconnect
      return if !@pq
      Qlib::q_disconnect(@pq)
      @pq = nil
      @workers = []
      @observers = []
    end
    
    def post(channel, job)
      throw "q disconnected" if !@pq
      throw "invalid arguments" if !channel
      throw "invalid arguments" if !job || !job.valid?
      puid = FFI::MemoryPointer.new(:pointer)
      run_at = job.run_at ? job.run_at.to_i : 0
      Qlib::q_post(@pq, channel, job.uid, job.data, run_at, puid)
      puid.read_pointer.read_string
    end
    
    def reschedule(uid, run_at)
      throw "q disconnected" if !@pq
      throw "invalid arguments" if !uid
      run_at = run_at ? run_at.to_i : 0
      Qlib::q_reschedule(@pq, uid, run_at)
    end
    
    def cancel(uid)
      throw "q disconnected" if !@pq
      throw "invalid arguments" if !uid
      Qlib::q_cancel(@pq, uid)
    end
    
    def worker(channel, &delegate)
      throw "q disconnected" if !@pq
      throw "invalid arguments" if !channel
      throw "invalid arguments" if !delegate
      #Qlib::q_worker(@pq, channel) { |pdata| delegate.call(pdata.read_pointer.read_string) }
      worker =  FFI::Function.new(:void, [:pointer]) do |pdata|
        delegate.call(pdata.read_pointer.read_string)
      end
      @workers << worker
      Qlib::q_worker(@pq, channel, worker)
    end
    
    def observer(channel, &delegate)
      throw "q disconnected" if !@pq
      throw "invalid arguments" if !channel
      throw "invalid arguments" if !delegate      
      #Qlib::q_observer(@pq, channel) { |pdata| delegate.call(pdata.read_pointer.read_string) }
      observer =  FFI::Function.new(:void, [:pointer]) do |pdata|
        delegate.call(pdata.read_pointer.read_string)
      end
      @observers << observer
      Qlib::q_observer(@pq, channel, observer)
    end
    
    # careful, flushes the queue!
    def flush
      throw "q disconnected" if !@pq
      Qlib::q_flush(@pq)
    end
    
  end
end