require_relative '../spec_helper'

describe Wpxf::Net::UserAgent do
  let(:subject) { (Class.new { include Wpxf::Net::UserAgent }).new }

  describe '#clients_by_frequency' do
    it 'returns a Hash' do
      expect(subject.clients_by_frequency).to be_a Hash
    end

    it 'returns a hash with numeric keys that have total 100 at each level' do
      frequencies = subject.clients_by_frequency
      sum = 0

      frequencies.each do |frequency, combo|
        sum += frequency.to_i

        inner_sum = 0
        combo.each do |inner_frequency, _combo|
          inner_sum += inner_frequency.to_i
        end

        expect(inner_sum).to eq 100
      end

      expect(sum).to eq 100
    end
  end

  describe '#random_browser_and_os' do
    it 'returns a Hash' do
      expect(subject.random_browser_and_os).to be_a Hash
    end

    it 'has a :browser key' do
      expect(subject.random_browser_and_os).to have_key :browser
    end

    it 'has an :os key' do
      expect(subject.random_browser_and_os).to have_key :os
    end

    it 'always has an :os value' do
      expect(subject.random_browser_and_os[:os]).not_to be_nil
      expect(subject.random_browser_and_os[:os]).not_to be_empty
    end

    it 'always has a :browser value' do
      expect(subject.random_browser_and_os[:browser]).not_to be_nil
      expect(subject.random_browser_and_os[:browser]).not_to be_empty
    end
  end

  describe '#random_time_string' do
    it 'returns a String' do
      expect(subject.random_time_string('2015-01-01')).to be_a String
    end

    it 'returns a string that matches the date format specified' do
      value = subject.random_time_string('2015-01-01', '2015-01-01', '%Y%m%d')
      expect(value).to eq '20150101'
    end

    it 'uses %Y%m%d as the default format string' do
      value = subject.random_time_string('2015-01-01', '2015-01-01')
      expect(value).to eq '20150101'
    end

    it 'uses Time.now as the default maximum date' do
      value = subject.random_time_string(Time.now.to_s)
      expect(value).to eq Time.now.strftime('%Y%m%d')
    end
  end

  describe '#random_processor_string' do
    it 'returns a String' do
      expect(subject.random_processor_string(:linux)).to be_a String
    end

    it 'returns i686 or x86_64 for :linux' do
      possible_values = %w(i686 x86_64)
      value = subject.random_processor_string(:linux)
      expect(possible_values).to include(value)
    end

    it 'returns Intel, PPC, U; Intel or U; PPC for :osx' do
      possible_values = ['Intel', 'PPC', 'U; Intel', 'U; PPC']
      value = subject.random_processor_string(:osx)
      expect(possible_values).to include(value)
    end
  end

  describe '#random_firefox_version_string' do
    it 'returns a String' do
      expect(subject.random_firefox_version_string).to be_a String
    end

    it 'returns a string that matches the version pattern' do
      pattern = %r(Gecko\/[0-9]{8}\sFirefox\/[0-9]{1,2}.[0-9](\.[0-9])?)
      expect(subject.random_firefox_version_string).to match pattern
    end
  end

  describe '#random_firefox_platform_string' do
    context 'when :osx is specified as the OS' do
      it 'returns a String' do
        expect(subject.random_firefox_platform_string(:osx)).to be_a String
      end

      it 'returns a string that matches the platform pattern' do
        pattern = %r{\(Macintosh;\s(.+)\sMac\sOS\sX\s(.+)\srv\:(.+)\.0\)\s
                    Gecko\/[0-9]{8}\sFirefox\/[0-9]{1,2}.[0-9](\.[0-9])?}x

        expect(subject.random_firefox_platform_string(:osx)).to match pattern
      end
    end

    context 'when :linux is specified as the OS' do
      it 'returns a String' do
        expect(subject.random_firefox_platform_string(:linux)).to be_a String
      end

      it 'returns a string that matches the platform pattern' do
        pattern = %r{\(X11;\sLinux\s(.+);\srv\:(.+)\.0\)\s
                    Gecko\/[0-9]{8}\sFirefox\/[0-9]{1,2}.[0-9](\.[0-9])?}x

        expect(subject.random_firefox_platform_string(:linux)).to match pattern
      end
    end

    context 'when :windows is specified as the OS' do
      it 'returns a String' do
        expect(subject.random_firefox_platform_string(:windows)).to be_a String
      end

      it 'returns a string that matches the platform pattern' do
        value = subject.random_firefox_platform_string(:windows)
        pattern = %r{\(Windows\sNT\s(.+);\sen\-US;\srv\:1\.9\.(.+)\.20\)\s
                    Gecko\/[0-9]{8}\sFirefox\/[0-9]{1,2}.[0-9](\.[0-9])?}x

        expect(value).to match pattern
      end
    end
  end

  describe '#random_safari_platform_string' do
    context 'when :osx is specified as the OS' do
      it 'returns a String' do
        expect(subject.random_safari_platform_string(:osx)).to be_a String
      end

      it 'returns a string that matches the platform pattern' do
        pattern = %r{\(Macintosh;\sU;\s(.+)\sMac\sOS\sX\s(.+)\srv\:(.+)\.0;
                     \sen\-US\)\sAppleWebKit\/(.+)\s\(KHTML\,\slike\sGecko\)
                     \sVersion\/(.+)\sSafari\/(.+)}x

        expect(subject.random_safari_platform_string(:osx)).to match pattern
      end
    end

    context 'when :osx isn\'t specified as the OS' do
      it 'returns a String' do
        expect(subject.random_safari_platform_string(:windows)).to be_a String
      end

      it 'returns a string that matches the platform pattern' do
        value = subject.random_safari_platform_string(:windows)
        pattern = %r{\(Windows;\sU;\sWindows\sNT\s(.+)
                     \sAppleWebKit\/(.+)\s\(KHTML\,\slike\sGecko\)
                     \sVersion\/(.+)\sSafari\/(.+)}x

        expect(value).to match pattern
      end
    end
  end

  describe '#random_iexplorer_platform_string' do
    it 'returns a String' do
      expect(subject.random_iexplorer_platform_string).to be_a String
    end

    it 'returns a string that matches the platform pattern' do
      value = subject.random_iexplorer_platform_string
      pattern = %r{\(compatible;\sMSIE\s(.+);\sWindows\sNT
                   \s(.+);\sTrident\/(.+)\)}x

      expect(value).to match pattern
    end
  end

  describe '#random_opera_platform_string' do
    context 'when :linux is specified as the OS' do
      it 'returns a String' do
        expect(subject.random_opera_platform_string(:linux)).to be_a String
      end

      it 'returns a string that matches the platform pattern' do
        value = subject.random_opera_platform_string(:linux)
        pattern = %r{\(X11;\sLinux\s(.+);\sU;\sen\-US\)\s
                     Presto\/(.+)\sVersion\/(.+)}x

        expect(value).to match pattern
      end
    end

    context 'when :linux is not specified as the OS' do
      it 'returns a String' do
        expect(subject.random_opera_platform_string(:windows)).to be_a String
      end

      it 'returns a string that matches the platform pattern' do
        value = subject.random_opera_platform_string(:windows)
        pattern = %r{\(Windows\sNT\s(.+);\sU;\sen\-US\)\s
                     Presto\/(.+)\sVersion\/(.+)}x

        expect(value).to match pattern
      end
    end
  end

  describe '#random_chrome_platform_string' do
    context 'when :linux is specified as the OS' do
      it 'returns a String' do
        expect(subject.random_chrome_platform_string(:linux)).to be_a String
      end

      it 'returns a string that matches the platform pattern' do
        value = subject.random_chrome_platform_string(:linux)
        pattern = %r{\(X11;\sLinux\s(.+)\)\sAppleWebKit\/(.+)\s
                     \(KHTML\,\slike\sGecko\)\sChrome\/(.+)\sSafari\/(.+)}x

        expect(value).to match pattern
      end
    end

    context 'when :osx is specified as the OS' do
      it 'returns a String' do
        expect(subject.random_chrome_platform_string(:osx)).to be_a String
      end

      it 'returns a string that matches the platform pattern' do
        value = subject.random_chrome_platform_string(:osx)
        pattern = %r{\(Macintosh;\sU;\s(.+)\sMac\sOS\sX\s(.+)\)
                     \sAppleWebKit\/(.+)\s\(KHTML\,\slike
                     \sGecko\)\sChrome\/(.+)\sSafari\/(.+)}x

        expect(value).to match pattern
      end
    end

    context 'when :windows is specified as the OS' do
      it 'returns a String' do
        expect(subject.random_chrome_platform_string(:windows)).to be_a String
      end

      it 'returns a string that matches the platform pattern' do
        value = subject.random_chrome_platform_string(:windows)
        pattern = %r{\(Windows\sNT\s(.+)\)
                     \sAppleWebKit\/(.+)\s\(KHTML\,\slike
                     \sGecko\)\sChrome\/(.+)\sSafari\/(.+)}x

        expect(value).to match pattern
      end
    end
  end

  describe '#random_user_agent' do
    it 'returns a String' do
      expect(subject.random_user_agent).to be_a String
    end

    it 'returns a string that matches the platform pattern' do
      pattern = %r{(Mozilla\/5\.0|Opera\/(.+))\s(.+)}x
      expect(subject.random_user_agent).to match pattern
    end
  end
end
