# Simple loop with its own custom run method
#
# Does nothing aside from printing loop's name, pid and current time every second
#
class SimpleLoop < Lipsiadmin::Loops::Base
  def run
    debug(Time.now)
  end
end