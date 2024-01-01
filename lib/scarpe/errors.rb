# frozen_string_literal: true

module Scarpe
  class MultipleAppObjectsError < Scarpe::Error; end

  class MultipleDrawablesFoundError < Scarpe::Error; end

  class NoDrawablesFoundError < Scarpe::Error; end

  class UnknownShoesEventAPIError < Scarpe::Error; end

  class UnknownBuiltinCommandError < Scarpe::Error; end

  class UnknownEventTypeError < Scarpe::Error; end

  class InternalError < Scarpe::Error; end

  class IllegalSubscribeEventError < Scarpe::Error; end

  class IllegalDispatchEventError < Scarpe::Error; end

  class MissingBlockError < Scarpe::Error; end

  class DuplicateCallbackError < Scarpe::Error; end

  class InvalidOperationError < Scarpe::Error; end

  class MissingAttributeError < Scarpe::Error; end

  # An error occurred which would normally be handled by shutting down the app
  class AppShutdownError < Scarpe::Error; end

  class InvalidClassError < Scarpe::Error; end

  class MissingClassError < Scarpe::Error; end

  class BadDisplayClassType < Scarpe::Error; end
end
