require_relative './crash_puma'

class App
  def call(env)
    CrashPuma.do_crash
    [200, { 'Content-Type' => 'text/html' }, ["PUMA DID NOT CRASH"]]
  end
end


