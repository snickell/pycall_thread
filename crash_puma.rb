#!/usr/bin/env ruby

# Setup our local venv (using pdm, in .venv)
ENV['PYTHON'] = `pdm run which python`.strip
site_dir = `pdm run python -c 'import site; print(site.getsitepackages()[0])'`.strip

require 'pycall'

# This is to setup our local venv
site = PyCall.import_module('site')
site.addsitedir(site_dir)

module CrashPuma

  def self.do_crash
    puts "About to crash (if running in puma)"

    pandas = PyCall.import_module('pandas')
    data = pandas.read_csv('https://archive.ics.uci.edu/ml/machine-learning-databases/wine-quality/winequality-red.csv', sep: ';')
    puts data.head()

    puts "IT DID NOT CRASH"
  end
end

if __FILE__ == $0
  # Does not crash if run like `./crash_puma.rb`, try `./crash_puma.sh` instead to see a crash
  CrashPuma.do_crash
end
