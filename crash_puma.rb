#!/usr/bin/env ruby

# Setup our local venv (using pdm, in .venv)
ENV['PYTHON'] = `pdm run which python`.strip
SITEDIR = `pdm run python -c 'import site; print(site.getsitepackages()[0])'`.strip

require 'pycall'

# This is to setup our local venv
site = PyCall.import_module('site')
site.addsitedir(SITEDIR)

module CrashPuma

  def self.do_crash
    input_scanners = PyCall.import_module('llm_guard.input_scanners')

    puts "About to crash (if running in puma)"

    
    ### THIS RUNS PYTHON CODE THAT CRASHES IF RUN IN PUMA
    ### BUT WORKS IF RUN OUTSIDE PUMA.
    input_scanners.Toxicity() # SEGV if run in puma, works if run directly
    ### END CRASH CODE


    puts "IT DID NOT CRASH"
  end
end

if __FILE__ == $0
  CrashPuma.do_crash
end
