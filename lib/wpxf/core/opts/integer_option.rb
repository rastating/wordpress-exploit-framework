
module Wpxf
  # An integer option.
  class IntegerOption < Option
    # Initializes a named option.
    # @param attrs an object containing the following values
    #   * *name*: the name of the option (required)
    #   * *desc*: the description of the option (required)
    #   * *required*: whether or not the option is required
    #   * *default*: the default value of the option
    #   * *advanced*: whether or not this is an advanced option
    #   * *evasion*: whether or not this is an evasion option
    #   * *enums*: the list of potential valid values
    #   * *regex*: regex to validate the option value
    #   * *min*: the lowest valid value
    #   * *max*: the highest valid value
    def initialize(attrs)
      super

      self.min = attrs[:min].to_i unless attrs[:min].nil?
      self.max = attrs[:max].to_i unless attrs[:max].nil?
    end

    # @param value the value to normalize.
    # @return [Integer] a normalized value to conform with the type that
    #   the option is conveying.
    def normalize(value)
      if value.to_s.match(/^0x[a-fA-F\d]+$/)
        value.to_i(16)
      else
        value.to_i
      end
    end

    # @param value the value to validate.
    # @return [Boolean] true if the value is a valid integer.
    def valid_integer?(value)
      value && !value.to_s.match(/^0x[0-9a-fA-F]+$|^-?\d+$/).nil?
    end

    # @param value the value to validate.
    # @return [Boolean] true if the value meets the minimum valid value
    #   requirement.
    def meets_min_requirement?(value)
      min.nil? || (normalize(value) >= min)
    end

    # @param value the value to validate.
    # @return [Boolean] true if the value meets the maximum valid value
    #   requirement.
    def meets_max_requirement?(value)
      max.nil? || (normalize(value) <= max)
    end

    # Check if the specified value is valid in the context of this option.
    # @param value the value to validate.
    # @return [Boolean] true if valid.
    def valid?(value)
      return true if value.nil? && !required?
      return false unless valid_integer?(value)
      return false unless meets_min_requirement?(value)
      return false unless meets_max_requirement?(value)
      super
    end

    # @return [Integer, nil] the lowest valid value.
    attr_accessor :min

    # @return [Integer, nil] the highest valid value.
    attr_accessor :max
  end
end
