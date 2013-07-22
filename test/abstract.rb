require 'test/unit'
require 'ruby-q'

module Q
  
  class AbstractTestCase < Test::Unit::TestCase
    
    def initialize(test_method_name)
      super(test_method_name)
      @connection_string = nil
    end
    
    def run1
      
      q = Q.new
      puts "using q version #{q.version}"
      puts "using #{@connection_string}"
      
      q.connect(@connection_string)
      q.drop
      
      #puts "how many?"
      total = 1000 #gets.to_i
      for index in 0..total-1
        q.post("channel1", Job.new("ruby test #{index}"))
      end
      
      received = 0
      q.worker("channel1") do |data| 
        received = received+1
        puts "ruby worker 1 received #{data}"
      end
      
      while (received < total)
        puts "received #{received}/#{total}"
        sleep 1
      end
      
      assert_equal(total, received)
        
      q.disconnect  
    
    end
    
    def run2
      
      q = Q.new
      puts "using q version #{q.version}"
      puts "using #{@connection_string}"
      
      q.connect(@connection_string)
      q.drop
      
      received = 0
      q.worker("channel1") do |data| 
        received = received+1
        puts "ruby worker 2 received #{data}"
      end
      
      q.post("channel1", Job.new("ruby test 1", Time.now+2))
      q.post("channel1", Job.new("ruby test 2", Time.now+4))
      
      sleep 3
      assert_equal(1, received)
      
      sleep 2
      assert_equal(2, received)      
        
      q.disconnect
      
    end
    
    def run3
      
      q = Q.new
      puts "using q version #{q.version}"
      puts "using #{@connection_string}"
      
      q.connect(@connection_string)
      q.drop
      
      received = 0
      q.worker("channel1") do |data| 
        received = received+1
        puts "ruby worker 3 received #{data}"
      end
      
      q.post("channel1", Job.new("test1", "ruby test 1", Time.now+2))
      q.post("channel1", Job.new("test2", "ruby test 2", Time.now+4))
      
      sleep 3
      assert_equal(1, received)
      
      q.reschedule("test2", Time.now+4)
      
      sleep 3
      assert_equal(1, received)
      
      sleep 2
      assert_equal(2, received)      
        
      q.disconnect
      
    end
    
    def run4
      
      q = Q.new
      puts "using q version #{q.version}"
      puts "using #{@connection_string}"
      
      q.connect(@connection_string)
      q.drop
      
      received = 0
      q.worker("channel1") do |data| 
        received = received+1
        puts "ruby worker 4 received #{data}"
      end
      
      q.post("channel1", Job.new("test1", "ruby test 1", Time.now+2))
      q.post("channel1", Job.new("test2", "ruby test 2", Time.now+4))
      
      sleep 3
      assert_equal(1, received)
      
      q.cancel("test2")
      
      sleep 3
      assert_equal(1, received)
      
      q.disconnect
      
    end
    
  end
  
end
