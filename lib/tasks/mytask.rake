def Kernel.is_windows?
  processor, platform, *rest = RUBY_PLATFORM.split("-")
  ['mswin32','mingw32'].include?(platform)
end

if Kernel.is_windows?
  require 'win32/process'
end

require 'faye'

task :start_processes do
    
    puts "Start Rails Server .. "
    Process.fork do
      system('rails server')    
    end
=begin    
    puts 'Start Faye service'
    Process.fork do
      system 'rackup faye.ru -E production -s thin'
      exit
    end
=end    
    sleep 15
    puts 'Start event machine port service'
    Process.fork do
      system 'ruby lib/update_map_svc.rb'
    end
    sleep 5
    puts 'Start vehicle engine'
    system 'rails runner lib/vehicle-eng.rb'
end