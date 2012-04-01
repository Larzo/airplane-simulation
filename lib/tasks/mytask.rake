
def Kernel.is_windows?
  processor, platform, *rest = RUBY_PLATFORM.split("-")
  ['mswin32','mingw32'].include?(platform)
end

if Kernel.is_windows?
  require 'win32/process'
end


class ProcessLauncher

  def launch(exec_str, description=nil)
    Process.fork do
      puts description if description
      puts 'launch: ' + exec_str
      system exec_str      
    end
  end
  
  def run
    launch('rails server')
    
    sleep 15
    launch 'ruby lib/update_map_svc.rb','Event Machine Port Service'

    sleep 5
    launch 'rails runner lib/vehicle-eng.rb', "Vehicle Engine"
    
    Process.wait
  end
  
end



task :start_processes do
  ProcessLauncher.new.run
end