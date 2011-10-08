module Exceptions
  class UnauthorizedAccess < StandardError
    def message
      "Unauthorized Access"
    end
  end
end