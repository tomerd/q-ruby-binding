require 'ffi'

module Qlib
  extend FFI::Library
  
  ffi_lib 'libq'
  #ffi_convention :stdcall
  
  callback :worker_delegate, [ :pointer ], :void
  callback :observer_delegate, [ :pointer ], :void
    
  attach_function :q_version, :q_version, [ ], :string
  attach_function :q_connect, :q_connect, [ :pointer, :string ], :void
  attach_function :q_disconnect, :q_disconnect, [ :pointer ], :void
  attach_function :q_post, :q_post, [ :pointer, :string, :string, :long, :pointer ], :void
  attach_function :q_worker, :q_worker, [ :pointer, :string, :worker_delegate ], :void
  attach_function :q_observer, :q_observer, [ :pointer, :string, :observer_delegate ], :void
  
end

module Q
  class Q::Q
    
    @pq = nil
    
    def version
      Qlib::q_version
    end
    
    def connect(config=nil)
      throw "already connected" if @pq
      pq = FFI::MemoryPointer.new(:pointer)
      Qlib::q_connect(pq, config)
      @pq = FFI::MemoryPointer.new(:pointer)
      @pq = pq.read_pointer
    end
    
    def disconnect
      return if !@pq
      Qlib::q_disconnect(@pq)
      @pq = nil
    end
    
    def post(channel, data)
      post_at(channel, data, 0)
    end
    
    def post_at(channel, data, at)
      throw "q disconnected" if !@pq
      throw "invalid arguments" if !channel
      throw "invalid arguments" if !data
      at = (at || 0) / 1000  
      puid = FFI::MemoryPointer.new(:pointer)
      Qlib::q_post(@pq, channel, data, at, puid)
      return puid.read_pointer.read_string
    end
    
    def worker(channel, &delegate)
      throw "q disconnected" if !@pq
      throw "invalid arguments" if !channel
      throw "invalid arguments" if !delegate
      Qlib::q_worker(@pq, channel) { |pdata| delegate.call(pdata.read_pointer.read_string) }
    end
    
    def observer(channel, &delegate)
      throw "q disconnected" if !@pq
      throw "invalid arguments" if !channel
      throw "invalid arguments" if !delegate      
      Qlib::q_observer(@pq, channel) { |pdata| delegate.call(pdata.read_pointer.read_string) }      
    end
    
  end
end