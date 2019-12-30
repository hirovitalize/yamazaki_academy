# delete! を paranoia_delete! に

module Paranoia
  alias_method :destroy!, :paranoia_destroy!
end
