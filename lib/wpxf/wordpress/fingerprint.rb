# Provides functionality for fingerprinting WordPress and its components.
module Wpxf::WordPress::Fingerprint
  # Check if the host is online and running WordPress.
  # @return [Boolean] true if the host is online and running WordPress.
  def wordpress_and_online?
    res = execute_get_request(url: full_uri)
    return false unless res && res.code == 200
    return true if wordpress_fingerprint_regexes.any? { |r| res.body =~ r }
    false
  end

  # Extract the WordPress version information from various sources.
  # @return [Version, nil] the version if found, nil otherwise.
  def wordpress_version
    wordpress_version_fingerprint_sources.each do |url, pattern|
      res = execute_get_request(url: url)
      match = res.body.match(pattern) if res && res.code == 200
      return Gem::Version.new(match[1]) if match
    end
    nil
  end

  # Checks the style.css file for a vulnerable version.
  # @param name [String] the name of the theme.
  # @param fixed [String] the version the vulnerability was fixed in.
  # @param introduced [String] the version the vulnerability was introduced in.
  # @return [Symbol] :unknown, :vulnerable or :safe.
  def check_theme_version_from_style(name, fixed = nil, introduced = nil)
    style_uri = normalize_uri(wordpress_url_themes, name, 'style.css')
    res = execute_get_request(url: style_uri)

    # No style.css file present
    return :unknown if res.nil? || res.code != 200

    pattern = extension_version_pattern(:style)
    extract_and_check_version(res.body, pattern, fixed, introduced)
  end

  # Checks a theme's readme for a vulnerable version.
  # @param name [String] the name of the theme.
  # @param fixed [String] the version the vulnerability was fixed in.
  # @param introduced [String] the version the vulnerability was introduced in.
  # @return [Symbol] :unknown, :vulnerable or :safe.
  def check_theme_version_from_readme(name, fixed = nil, introduced = nil)
    check_version_from_readme(:theme, name, fixed, introduced)
  end

  # Checks a plugin's readme for a vulnerable version.
  # @param name [String] the name of the plugin.
  # @param fixed [String] the version the vulnerability was fixed in.
  # @param introduced [String] the version the vulnerability was introduced in.
  # @return [Symbol] :unknown, :vulnerable or :safe.
  def check_plugin_version_from_readme(name, fixed = nil, introduced = nil)
    check_version_from_readme(:plugin, name, fixed, introduced)
  end

  # Checks a plugin's changelog for a vulnerable version.
  # @param plugin_name [String] the name of the plugin.
  # @param file_name [String] the name of the file that contains the changelog.
  # @param fixed [String] the version the vulnerability was fixed in.
  # @param introduced [String] the version the vulnerability was introduced in.
  # @return [Symbol] :unknown, :vulnerable or :safe.
  def check_plugin_version_from_changelog(plugin_name, file_name, fixed = nil, introduced = nil)
    changelog = normalize_uri(wordpress_url_plugins, plugin_name, file_name)
    check_version_from_custom_file(changelog, /=\s([\d\.]+)\s=/, fixed, introduced)
  end

  # Checks a custom file for a vulnerable version.
  # @param url [String] the relative path of the file.
  # @param regex [Regexp] the regular expression to extract the version.
  # @param fixed [String] the version the vulnerability was fixed in.
  # @param introduced [String] the version the vulnerability was introduced.
  # @return [Symbol] :unknown, :vulnerable or :safe.
  def check_version_from_custom_file(url, regex, fixed = nil, introduced = nil)
    res = execute_get_request(url: url)
    return :unknown unless res && res.code == 200
    extract_and_check_version(res.body, regex, fixed, introduced)
  end

  private

  WORDPRESS_VERSION_PATTERN = '(\d+\.\d+(?:\.\d+)*)'

  WORDPRESS_GENERATOR_VERSION_PATTERN = %r{<meta\sname="generator"\s
    content="WordPress\s#{WORDPRESS_VERSION_PATTERN}"\s\/>}xi

  WORDPRESS_README_VERSION_PATTERN = %r{<br\s\/>\sversion\s
    #{WORDPRESS_VERSION_PATTERN}}xi

  WORDPRESS_RSS_VERSION_PATTERN = %r{<generator>http:\/\/wordpress\.org\/\?v=
    #{WORDPRESS_VERSION_PATTERN}<\/generator>}xi

  WORDPRESS_RDF_VERSION_PATTERN = %r{<admin:generatorAgent\srdf:resource="http:
    \/\/wordpress\.org\/\?v=#{WORDPRESS_VERSION_PATTERN}"\s\/>}xi

  WORDPRESS_ATOM_VERSION_PATTERN = %r{<generator\suri="http:\/\/wordpress\.org
    \/"\sversion="#{WORDPRESS_VERSION_PATTERN}">WordPress<\/generator>}xi

  WORDPRESS_SITEMAP_VERSION_PATTERN = %r{generator="wordpress\/
    #{WORDPRESS_VERSION_PATTERN}"}xi

  WORDPRESS_OPML_VERSION_PATTERN = %r{generator="wordpress\/
    #{WORDPRESS_VERSION_PATTERN}"}xi

  def wordpress_version_fingerprint_sources
    {
      "#{full_uri}" => WORDPRESS_GENERATOR_VERSION_PATTERN,
      "#{wordpress_url_readme}" => WORDPRESS_README_VERSION_PATTERN,
      "#{wordpress_url_rss}" => WORDPRESS_RSS_VERSION_PATTERN,
      "#{wordpress_url_rdf}" => WORDPRESS_RDF_VERSION_PATTERN,
      "#{wordpress_url_atom}" => WORDPRESS_ATOM_VERSION_PATTERN,
      "#{wordpress_url_sitemap}" => WORDPRESS_SITEMAP_VERSION_PATTERN,
      "#{wordpress_url_opml}" => WORDPRESS_OPML_VERSION_PATTERN
    }
  end

  def wordpress_fingerprint_regexes
    [
      %r{["'][^"']*\/#{Regexp.escape(wp_content_dir)}\/[^"']*["']}i,
      %r{<link rel=["']wlwmanifest["'].*href=["'].*\/wp-includes\/
        wlwmanifest\.xml["'] \/>}i,
      %r{<link rel=["']pingback["'].*href=["'].*\/xmlrpc\.php["'](?: \/)*>}i
    ]
  end

  def check_version_from_readme(type, name, fixed = nil, introduced = nil)
    readme = get_first_readme(name, type)
    if readme.nil?
      # No readme present for plugin
      return :unknown if type == :plugin

      # Try again using the style.css file, if it is a theme.
      if type == :theme
        return check_theme_version_from_style(name, fixed, introduced)
      end
    end

    # If all versions are vulnerable and we found a file, end the process here
    # and return a vulnerable state, as some readmes will not have a version.
    return :vulnerable if fixed.nil? && introduced.nil?

    state = extension_is_vulnerable(type, readme, fixed, introduced)
    if state == :no_version_found
      # If no version could be found in readme.txt for a theme, try style.css
      return check_theme_version_from_style(name, fixed, introduced)
    end

    state
  end

  def extension_is_vulnerable(type, readme, fixed, introduced)
    pattern = extension_version_pattern(:readme)
    vuln = extract_and_check_version(readme, pattern, fixed, introduced)
    if vuln == :unknown && type == :theme
      return :no_version_found
    else
      return vuln
    end
  end

  def get_first_readme(name, type)
    res = nil
    folder = content_directory_name(type)
    readmes = ['readme.txt', 'Readme.txt', 'README.txt']
    readmes.each do |readme|
      readme_url = normalize_uri(wordpress_url_wp_content, folder, name, readme)
      res = execute_get_request(url: readme_url)
      break if res && res.code == 200
    end

    return res.body if res && res.code == 200
    nil
  end

  def version_vulnerable?(version, fixed, introduced)
    return :vulnerable if fixed.nil? && introduced.nil?

    if fixed && !introduced
      return :vulnerable if version < fixed
    end

    if !fixed && introduced
      return :vulnerable if version >= introduced
    end

    if fixed && introduced
      return :vulnerable if version >= introduced && version < fixed
    end

    :safe
  end

  def content_directory_name(type)
    case type
    when :plugin
      return 'plugins'
    when :theme
      return 'themes'
    else
      raise("Unknown readme type #{type}")
    end
  end

  def extract_highest_version(body, pattern)
    version = nil

    body.scan(pattern) do |match|
      match_version = Gem::Version.new(match[0])
      version = match_version if version.nil? || match_version > version
    end

    version
  end

  def extract_and_check_version(body, pattern, fixed = nil, introduced = nil)
    version = extract_highest_version(body, pattern)
    return :unknown if version.nil?

    version = Gem::Version.new(version)
    fixed = Gem::Version.new(fixed) unless fixed.nil?
    introduced = Gem::Version.new(introduced) unless introduced.nil?

    emit_info "Found version #{version}", true
    version_vulnerable?(version, fixed, introduced)
  end

  def extension_version_pattern(type)
    case type
    when :readme
      # Example line:
      # Stable tag: 2.6.6
      return /(?:stable tag):\s*(?!trunk)([0-9a-z.-]+)/i
    when :style
      # Example line:
      # Version: 1.5.2
      return /(?:Version):\s*([0-9a-z.-]+)/i
    else
      raise("Unknown file type #{type}")
    end
  end
end
