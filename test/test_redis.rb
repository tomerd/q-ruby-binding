require 'abstract.rb'

module Q
  
  class TestRedis < AbstractTestCase
    
    def initialize(test_method_name)
      super(test_method_name)
      @connection_string = { :driver => :redis, :host => 'localhost' }
    end
    
    def test1
      run1
    end
    
    def test2
      run2
    end
    
    def test3
      run3
    end
    
    def test4
      run4
    end
    
  end
  
end