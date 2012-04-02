
def Kernel.is_windows?
  processor, platform, *rest = RUBY_PLATFORM.split("-")
  ['mswin32','mingw32'].include?(platform)
end

