# frozen_string_literal: true

module Yandex360
  class Error < StandardError
  end

  class AuthenticationError < Error
  end

  class AuthorizationError < Error
  end

  class NotFoundError < Error
  end

  class ValidationError < Error
  end

  class RateLimitError < Error
  end

  class ServerError < Error
  end
end
