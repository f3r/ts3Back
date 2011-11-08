module Exceptions
  class UnauthorizedAccess < StandardError
    def message
      "Unauthorized Access"
    end
  end

  class NotActivated < StandardError
    def message
      "Not activated"
    end
  end

end