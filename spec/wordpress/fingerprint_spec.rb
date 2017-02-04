require_relative '../spec_helper'

describe Wpxf::WordPress::Fingerprint do
  let(:body) { '' }
  let(:code) { 200 }
  let(:subject) do
    subject = Class.new(Wpxf::Module) do
      include Wpxf::Net::HttpClient
      include Wpxf::WordPress::Options
      include Wpxf::WordPress::Urls
      include Wpxf::WordPress::Fingerprint
    end.new

    subject.set_option_value('host', '127.0.0.1')
    subject.set_option_value('target_uri', '/wp/')
    subject
  end

  before :each do
    res = Wpxf::Net::HttpResponse.new(nil)
    res.body = body
    res.code = code
    allow(subject).to receive(:execute_get_request).and_return(res)
  end

  describe '#wordpress_and_online?' do
    let(:body) do
      '<head><link rel="pingback" href="http://192.168.1.15/wordpress/'\
      'xmlrpc.php"></head>'
    end

    it 'returns true if a valid WordPress fingerprint can be found' do
      expect(subject.wordpress_and_online?).to be true
    end
  end

  describe '#wordpress_version' do
    let(:body) do
      '<meta name="generator" content="WordPress 4.7.1" />'
    end

    it 'returns the WordPress version number' do
      expect(subject.wordpress_version).to eq Gem::Version.new('4.7.1')
    end
  end

  describe '#check_theme_version_from_style' do
    let(:body) do
      'Theme Name: Twenty Fourteen
      Theme URI: http://wordpress.org/themes/twentyfourteen
      Version: 1.2'
    end

    context 'when all versions of the theme are vulnerable' do
      it 'returns :vulnerable' do
        expect(subject.check_theme_version_from_style('a')).to eq :vulnerable
      end
    end

    context 'when all versions after a specific version are vulnerable' do
      it 'returns :vulnerable if the version is later than introduced' do
        introduced = '1.0'
        state = subject.check_theme_version_from_style('a', nil, introduced)
        expect(state).to eq :vulnerable
      end

      it 'returns :safe if the version is earlier than introduced' do
        introduced = '1.3'
        state = subject.check_theme_version_from_style('a', nil, introduced)
        expect(state).to eq :safe
      end

      it 'returns :vulnerable if the version is the same as introduced' do
        introduced = '1.2'
        state = subject.check_theme_version_from_style('a', nil, introduced)
        expect(state).to eq :vulnerable
      end
    end

    context 'when a specifc range of versions are vulnerable' do
      it 'returns :vulnerable if the version is in the vulnerable range' do
        state = subject.check_theme_version_from_style('a', '2.0', '1.0')
        expect(state).to eq :vulnerable

        state = subject.check_theme_version_from_style('a', '2.0', '1.2')
        expect(state).to eq :vulnerable
      end

      it 'returns :safe if the version is outside the vulnerable range' do
        state = subject.check_theme_version_from_style('a', nil, '1.3')
        expect(state).to eq :safe

        state = subject.check_theme_version_from_style('a', '1.2', '1.0')
        expect(state).to eq :safe
      end
    end
  end

  describe '#check_plugin_version_from_changelog' do
    let(:body) do
      '== Change Log ==

      = 1.2 =
      * 1.2 notes

      = 1.1 =
      * 1.1 notes

      = 1.0 =
      * First release.'
    end

    context 'when all versions of the plugin are vulnerable' do
      it 'returns :vulnerable' do
        expect(subject.check_plugin_version_from_changelog('a', 'a')).to eq :vulnerable
      end
    end

    context 'when all versions after a specific version are vulnerable' do
      it 'returns :vulnerable if the version is later than introduced' do
        introduced = '1.0'
        state = subject.check_plugin_version_from_changelog('a', 'a', nil, introduced)
        expect(state).to eq :vulnerable
      end

      it 'returns :safe if the version is earlier than introduced' do
        introduced = '1.3'
        state = subject.check_plugin_version_from_changelog('a', 'a', nil, introduced)
        expect(state).to eq :safe
      end

      it 'returns :vulnerable if the version is the same as introduced' do
        introduced = '1.2'
        state = subject.check_plugin_version_from_changelog('a', 'a', nil, introduced)
        expect(state).to eq :vulnerable
      end
    end

    context 'when a specifc range of versions are vulnerable' do
      it 'returns :vulnerable if the version is in the vulnerable range' do
        state = subject.check_plugin_version_from_changelog('a', 'a', '2.0', '1.0')
        expect(state).to eq :vulnerable

        state = subject.check_plugin_version_from_changelog('a', 'a', '2.0', '1.2')
        expect(state).to eq :vulnerable
      end

      it 'returns :safe if the version is outside the vulnerable range' do
        state = subject.check_plugin_version_from_changelog('a', 'a', nil, '1.3')
        expect(state).to eq :safe

        state = subject.check_plugin_version_from_changelog('a', 'a', '1.2', '1.0')
        expect(state).to eq :safe
      end
    end
  end

  describe '#check_theme_version_from_readme' do
    let(:body) do
      'Requires at least: 3.1
      Tested up to: 4.0
      Stable tag: 1.2'
    end

    context 'when all versions of the theme are vulnerable' do
      it 'returns :vulnerable' do
        expect(subject.check_theme_version_from_readme('a')).to eq :vulnerable
      end
    end

    context 'when all versions after a specific version are vulnerable' do
      it 'returns :vulnerable if the version is later than introduced' do
        introduced = '1.0'
        state = subject.check_theme_version_from_readme('a', nil, introduced)
        expect(state).to eq :vulnerable
      end

      it 'returns :safe if the version is earlier than introduced' do
        introduced = '1.3'
        state = subject.check_theme_version_from_readme('a', nil, introduced)
        expect(state).to eq :safe
      end

      it 'returns :vulnerable if the version is the same as introduced' do
        introduced = '1.2'
        state = subject.check_theme_version_from_readme('a', nil, introduced)
        expect(state).to eq :vulnerable
      end
    end

    context 'when a specifc range of versions are vulnerable' do
      it 'returns :vulnerable if the version is in the vulnerable range' do
        state = subject.check_theme_version_from_readme('a', '2.0', '1.0')
        expect(state).to eq :vulnerable

        state = subject.check_theme_version_from_readme('a', '2.0', '1.2')
        expect(state).to eq :vulnerable
      end

      it 'returns :safe if the version is outside the vulnerable range' do
        state = subject.check_theme_version_from_readme('a', nil, '1.3')
        expect(state).to eq :safe

        state = subject.check_theme_version_from_readme('a', '1.2', '1.0')
        expect(state).to eq :safe
      end
    end
  end

  describe '#check_version_from_custom_file' do
    let(:pattern) { /This contains version (.+)/i }
    let(:body) { 'This contains version 1.2' }

    context 'when all versions are vulnerable' do
      it 'returns :vulnerable' do
        res = subject.check_version_from_custom_file('http://127.0.0.1', pattern)
        expect(res).to eq :vulnerable
      end
    end

    context 'when all versions after a specific version are vulnerable' do
      it 'returns :vulnerable if the version is later than introduced' do
        introduced = '1.0'
        state = subject.check_version_from_custom_file('http://127.0.0.1', pattern, nil, introduced)
        expect(state).to eq :vulnerable
      end

      it 'returns :safe if the version is earlier than introduced' do
        introduced = '1.3'
        state = subject.check_version_from_custom_file('http://127.0.0.1', pattern, nil, introduced)
        expect(state).to eq :safe
      end

      it 'returns :vulnerable if the version is the same as introduced' do
        introduced = '1.2'
        state = subject.check_version_from_custom_file('http://127.0.0.1', pattern, nil, introduced)
        expect(state).to eq :vulnerable
      end
    end

    context 'when a specifc range of versions are vulnerable' do
      it 'returns :vulnerable if the version is in the vulnerable range' do
        state = subject.check_version_from_custom_file('http://127.0.0.1', pattern, '2.0', '1.0')
        expect(state).to eq :vulnerable

        state = subject.check_version_from_custom_file('http://127.0.0.1', pattern, '2.0', '1.2')
        expect(state).to eq :vulnerable
      end

      it 'returns :safe if the version is outside the vulnerable range' do
        state = subject.check_version_from_custom_file('http://127.0.0.1', pattern, nil, '1.3')
        expect(state).to eq :safe

        state = subject.check_version_from_custom_file('http://127.0.0.1', pattern, '1.2', '1.0')
        expect(state).to eq :safe
      end
    end
  end

  describe '#check_plugin_version_from_readme' do
    let(:body) do
      'Requires at least: 3.1
      Tested up to: 4.0
      Stable tag: 1.2'
    end

    context 'when all versions of the plugin are vulnerable' do
      it 'returns :vulnerable' do
        expect(subject.check_plugin_version_from_readme('a')).to eq :vulnerable
      end
    end

    context 'when all versions after a specific version are vulnerable' do
      it 'returns :vulnerable if the version is later than introduced' do
        introduced = '1.0'
        state = subject.check_plugin_version_from_readme('a', nil, introduced)
        expect(state).to eq :vulnerable
      end

      it 'returns :safe if the version is earlier than introduced' do
        introduced = '1.3'
        state = subject.check_plugin_version_from_readme('a', nil, introduced)
        expect(state).to eq :safe
      end

      it 'returns :vulnerable if the version is the same as introduced' do
        introduced = '1.2'
        state = subject.check_plugin_version_from_readme('a', nil, introduced)
        expect(state).to eq :vulnerable
      end
    end

    context 'when a specifc range of versions are vulnerable' do
      it 'returns :vulnerable if the version is in the vulnerable range' do
        state = subject.check_plugin_version_from_readme('a', '2.0', '1.0')
        expect(state).to eq :vulnerable

        state = subject.check_plugin_version_from_readme('a', '2.0', '1.2')
        expect(state).to eq :vulnerable
      end

      it 'returns :safe if the version is outside the vulnerable range' do
        state = subject.check_plugin_version_from_readme('a', nil, '1.3')
        expect(state).to eq :safe

        state = subject.check_plugin_version_from_readme('a', '1.2', '1.0')
        expect(state).to eq :safe
      end
    end
  end
end
