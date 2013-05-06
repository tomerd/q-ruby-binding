***************************************************************************************

This project is work in progress. if you are interested in contributing or otherwise have input
please touch base via github

***************************************************************************************

### about

q is a queueing framework. the idea is to provide a universal application programming interface that can be used throughout the entire
application development lifecycle without the need to commit to a specific queueing technology or to set up complex queueing environments 
where such are not required. you can think of it as an ORM for queueing. q runs on multiple back-ends and has bindings to many 
programing languages. and so, while during development you will most likely run it in-memory and let it clear when the process dies, 
you may choose a redis back-end on your test environment and running dedicated servers backed by amazon SQS on production. q was designed to 
give you this freedom and to allow you to write the code once and run it anywhere.

https://github.com/tomerd/q

### q bindings for ruby

	q = Q::Q.new
        
    puts "using q version #{q.version }"  
    
    q.connect
    
    puts "how many?"
    total = gets.to_i
    for index in 0..total
      q.post("channel1", "ruby test #{index}")
    end
    
    received = 0
    q.worker("channel1") do |data| 
      received = received+1
      puts "ruby worker received #{data}"
    end
    
    while (received < total)
      puts "received #{received}/#{total}"
      sleep 1
    end
    
    q.disconnect