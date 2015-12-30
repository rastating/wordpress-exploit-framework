
module Wpxf
  # A boolean option.
  class BooleanOption < Option
    # Check if the specified value is valid in the context of this option.
    # @param value the value to validate.
    # @return [Boolean] true if valid.
    def valid?(value)
      return false if empty_required_value?(value)
      return true if !required? && empty?(value)

      pattern = /^(y|yes|n|no|t|f|0|1|true|false)$/i
      value?(value) && !value.to_s.match(pattern).nil?
    end

    # @param value the value to normalize.
    # @return [Boolean] a normalized value to conform with the type that.
    #   the option is conveying.
    def normalize(value)
      valid?(value) && !value.to_s.match(/^(y|yes|t|1|true)$/i).nil?
    end

    # @param value the value to check.
    # @return [Boolean] true if the value is a true boolean value.
    def true?(value)
      normalize(value)
    end

    # @param value the value to check.
    # @return [Boolean] true if the value is a false boolean value.
    def false?(value)
      !true?(value)
    end
  end
end
