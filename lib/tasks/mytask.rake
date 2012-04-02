
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
  
  
  # continuously launch, kill and relaunch
  # an external process. 
  # This is a temporary work around as event machine
  # port service seems to need resatring every few minutes.
  # It is not clear if this could be due to some MS windows
  # issue or not. 
  #
  # This is called as the last function in
  # the task as it will not
  # return since it has a infinite loop. 
  
  def continuous_launch(*args)    
    first_time = true
    exec_str = args[0]
    description = args[1]
    
    loop do
      pid = Process.fork do
        puts 'launching ' + description + ' .. ' if description
        print 're' if !first_time
        puts 'launch: ' + exec_str
        system exec_str
      end
      first_time = false
      
      sleep 280

      if description
        puts 'kill ' + description + ' for restart'
      else
        puts 'kill ' + exec_str + ' for restart'
      end
      
      begin
        Process.kill(9, pid)
        rescue Process::Error => err
          if err.to_s == "The handle is invalid"
            puts 'call kill remote'
            Process.kill_remote_thread(1, pid)
          end
      end
            
      Process.wait(pid)
      
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
      if ['win','windows'].include?(@machine)
        continuous_launch ev_cmd, ev_desc
      else
        launch ev_cmd, ev_desc
      end
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