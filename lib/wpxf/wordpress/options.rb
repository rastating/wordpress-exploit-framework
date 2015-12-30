module Wpxf
  module WordPress
    # Provides access to various WordPress based options.
    module Options
      # Initialize a new instance of {Options}.
      def initialize
        super

        register_advanced_options([WP_OPTION_CONTENT_DIR])
      end

      # @return [String] the name of the wp-content directory.
      def wp_content_dir
        normalized_option_value('wp_content_dir')
      end

      private

      WP_OPTION_CONTENT_DIR = StringOption.new(
        name: 'wp_content_dir',
        desc: 'The name of the wp-content directory.',
        default: 'wp-content',
        required: true
      )
    end
  end
end
