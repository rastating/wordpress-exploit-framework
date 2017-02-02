# Provides helper methods for generating commonly used WordPress URLs.
module Wpxf::WordPress::Urls
  # @return [String] the WordPress login URL.
  def wordpress_url_login
    normalize_uri(full_uri, 'wp-login.php')
  end

  # @param post_id [Integer] a valid WordPress post ID.
  # @return [String] the URL of the specified WordPress post.
  def wordpress_url_post(post_id)
    normalize_uri(full_uri, "?p=#{post_id}")
  end

  # @param author_id [Integer] a valid WordPress author ID.
  # @return [String] the WordPress author URL.
  def wordpress_url_author(author_id)
    normalize_uri(full_uri, "?author=#{author_id}")
  end

  # @return [String] the WordPress RSS URL.
  def wordpress_url_rss
    normalize_uri(full_uri, '?feed=rss2')
  end

  # @return [String] the WordPress RDF URL.
  def wordpress_url_rdf
    normalize_uri(full_uri, 'feed/rdf/')
  end

  # @return [String] the WordPress ATOM URL.
  def wordpress_url_atom
    normalize_uri(full_uri, 'feed/atom/')
  end

  # @return [String] the WordPress readme file URL.
  def wordpress_url_readme
    normalize_uri(full_uri, 'readme.html')
  end

  # @return [String] the WordPress sitemap URL.
  def wordpress_url_sitemap
    normalize_uri(full_uri, 'sitemap.xml')
  end

  # @return [String] the WordPress OPML URL.
  def wordpress_url_opml
    normalize_uri(full_uri, 'wp-links-opml.php')
  end

  # @return [String] the WordPress admin URL.
  def wordpress_url_admin
    normalize_uri(full_uri, 'wp-admin/')
  end

  # @return [String] the WordPress admin AJAX URL.
  def wordpress_url_admin_ajax
    normalize_uri(wordpress_url_admin, 'admin-ajax.php')
  end

  # @return [String] the WordPress admin post URL.
  def wordpress_url_admin_post
    normalize_uri(wordpress_url_admin, 'admin-post.php')
  end

  # @return [String] the WordPress admin update URL.
  def wordpress_url_admin_update
    normalize_uri(wordpress_url_admin, 'update.php')
  end

  # @return [String] the WordPress wp-content URL.
  def wordpress_url_wp_content
    normalize_uri(full_uri, wp_content_dir)
  end

  # @return [String] the WordPress plugins URL.
  def wordpress_url_plugins
    normalize_uri(wordpress_url_wp_content, 'plugins')
  end

  # @return [String] the WordPress themes URL.
  def wordpress_url_themes
    normalize_uri(wordpress_url_wp_content, 'themes')
  end

  # @return [String] the WordPress XMLRPC URL.
  def wordpress_url_xmlrpc
    normalize_uri(full_uri, 'xmlrpc.php')
  end

  # @return [String] the WordPress plugin install URL.
  def wordpress_url_plugin_install
    normalize_uri(wordpress_url_admin, 'plugin-install.php')
  end

  # @return [String] the WordPress plugin uploader URL.
  def wordpress_url_plugin_upload
    normalize_uri(wordpress_url_admin, 'plugin-install.php?tab=upload')
  end

  # @return [String] the WordPress new user URL.
  def wordpress_url_new_user
    normalize_uri(wordpress_url_admin, 'user-new.php')
  end

  # @return [String] the WordPress uploads directory.
  def wordpress_url_uploads
    normalize_uri(wordpress_url_wp_content, 'uploads')
  end

  # @return [String] the edit profile page URL.
  def wordpress_url_admin_profile
    normalize_uri(wordpress_url_admin, 'profile.php')
  end

  # @return [String] the base path of the REST API introduced in WordPress 4.7.0.
  def wordpress_url_rest_api
    normalize_uri(full_uri, 'wp-json')
  end
end
