# require "pycall_thread"
require_relative "../../lib/pycall_thread"

PyCallThread.init do
  # Setup our local venv (using pdm, in .venv)
  ENV["PYTHON"] = `pdm run which python`.strip
  site_dir = `pdm run python -c 'import site; print(site.getsitepackages()[0])'`.strip

  require "pycall"

  # This is to setup our local venv
  site = PyCall.import_module("site")
  site.addsitedir(site_dir)
end

# Simple Puma App that demonstrates PyCallThread
class App
  def call(_)
    winequality = PyCallThread.run do
      pandas = PyCall.import_module("pandas")
      data = pandas.read_csv("https://archive.ics.uci.edu/ml/machine-learning-databases/wine-quality/winequality-red.csv", sep: ";")
      data.to_html
    end

    [200, { "Content-Type" => "text/html" }, [winequality]]
  end
end
