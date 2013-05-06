require 'test/unit'
require 'ruby-q'

class QTest < Test::Unit::TestCase
  
  def test_1
    
    q = Q::Q.new
        
    puts "using q version #{q.version }"  
    
    q.connect
    
    puts "how many?"
    total = gets.to_i-1
    for index in 0..total
      q.post("channel1", "ruby test #{index}")
    end
    
    received = 0
    q.worker("channel1") do |data| 
      #sleep 0.02
      received = received+1
      puts "ruby worker received #{data}"
    end
    
    while (received < total)
      puts "received #{received}/#{total}"
      sleep 1
    end
    
    q.disconnect  
  
  end
  
  
end
