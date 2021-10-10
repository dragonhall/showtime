5.times do 
  Process.fork do
    puts "child, pid #{Process.pid} sleeping..."
    sleep 5
    puts "child exiting"
  end
end

puts "parent, pid #{Process.pid}, waiting on children"
Process.wait
2.times { puts "Hello"; sleep 5 }
puts "parent exiting"
