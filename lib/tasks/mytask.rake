
def Kernel.is_windows?
  processor, platform, *rest = RUBY_PLATFORM.split("-")
  ['mswin32','mingw32'].include?(platform)
end

if Kernel.is_windows?
  require 'win32/process'
end


class ProcessLauncher

  def initialize(attr={})
    @machine = attr[:machine] 
    @run_em = attr[:run_em]   
  end

  # launch an external process 
  def launch(exec_str, description=nil)
    Process.fork do
      puts description if description
      puts 'launch: ' + exec_str
      system exec_str      
    end
  end
  
  
  
  def run
    launch('rails server')
        
    sleep 5
    launch 'rails runner lib/vehicle-eng.rb', "Vehicle Engine"
    
    if @run_em
      sleep 15
      ev_cmd = 'ruby lib/update_map_svc.rb'
      ev_desc = 'Event Machine Port Service'     
      launch ev_cmd, ev_desc
    end    
    
    Process.wait
  end
  
end



task :start_processes do
  machine = ENV['machine']
  run_em = true
  if em_setting = ENV['em'] and em_setting == 'false'
    run_em = false
  end

  ProcessLauncher.new(:machine => machine, :run_em => run_em).run
end