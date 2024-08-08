#!/usr/bin/env ruby

require_relative './pycall_thread'

module CrashPuma
  PyCallThread.init do
    # Setup our local venv (using pdm, in .venv)
    ENV['PYTHON'] = `pdm run which python`.strip
    site_dir = `pdm run python -c 'import site; print(site.getsitepackages()[0])'`.strip

    require 'pycall'

    # # This is to setup our local venv
    site = PyCall.import_module('site')
    site.addsitedir(site_dir)

    PyCall.import_module('sys')
  end

  def self.do_crash
    data = PyCallThread.run do
      pandas = PyCall.import_module('pandas')
      data = pandas.read_csv('https://archive.ics.uci.edu/ml/machine-learning-databases/wine-quality/winequality-red.csv', sep: ';')
      data.head().inspect
    end
    puts "Got result from thread: #{data}"
  end
end

if __FILE__ == $0
  CrashPuma.do_crash
end
