require 'eventmachine'


EM.run{
  EM.defer do 
    100.times do |i|
      sleep 1
      puts i
    end
  end
  100.times do |j|
    sleep 1
    puts 100+j
  end
}
