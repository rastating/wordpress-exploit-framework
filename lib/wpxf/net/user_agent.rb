module Wpxf
  module Net
    # Provides functionality for generating user agent strings.
    module UserAgent
      include Wpxf::Versioning::BrowserVersions
      include Wpxf::Versioning::OSVersions

      # A random browser and OS combination.
      # @return [Hash] a hash containing a :browser and :os
      def random_browser_and_os
        frequencies = clients_by_frequency
        target_frequency = rand(1..100)
        sum = 0

        frequencies.each do |browser_frequency, combinations|
          sum += browser_frequency.to_i
          next if target_frequency > sum

          # This browser encompasses our target frequency, so reset the
          # frequency sum and generate a new target frequency for the
          # operating system selection.
          target_frequency = rand(1..100)
          sum = 0

          # Once we find an OS that covers the target frequency, return
          # the browser/OS combination.
          combinations.each do |os_frequency, combo|
            sum += os_frequency.to_i
            return combo if target_frequency <= sum
          end
        end

        # This point should never be reached, as the frequencies should
        # always total 100 and thus we should always retrieve a combo.
        fail 'Browser and OS frequencies exceeded 100'
      end

      # @return [Hash] a hash of browser and OS combinations grouped by
      #   frequencies drawn from real-world statistics.
      def clients_by_frequency
        {
          34 => {
            89 => {
              browser: :chrome,
              os: :windows
            },
            9 => {
              browser: :chrome,
              os: :osx
            },
            2 => {
              browser: :chrome,
              os: :linux
            }
          },
          32 => {
            100 => {
              browser: :iexplorer,
              os: :windows
            }
          },
          25 => {
            83 => {
              browser: :firefox,
              os: :windows
            },
            16 => {
              browser: :firefox,
              os: :osx
            },
            1 => {
              browser: :firefox,
              os: :linux
            }
          },
          7 => {
            95 => {
              browser: :safari,
              os: :osx
            },
            4 => {
              browser: :safari,
              os: :windows
            },
            1 => {
              browser: :safari,
              os: :linux
            }
          },
          2 => {
            91 => {
              browser: :opera,
              os: :windows
            },
            6 => {
              browser: :opera,
              os: :linux
            },
            3 => {
              browser: :opera,
              os: :osx
            }
          }
        }
      end

      # A random date between two dates in a specific format.
      # @param min the minimum date to return.
      # @param max the maximum date to return.
      # @param format the format string to use when formatting the date.
      # @return [String] a formatted random date.
      def random_time_string(min, max = Time.now.to_s, format = '%Y%m%d')
        rand(Time.parse(min)..Time.parse(max)).strftime(format)
      end

      # A random CPU type.
      # @param os the operating system that the CPU would be used with.
      # @return [String] a random CPU type.
      def random_processor_string(os)
        return ['i686', 'x86_64'].sample if os == :linux
        return ['Intel', 'PPC', 'U; Intel', 'U; PPC'].sample if os == :osx
      end

      # @return [String] a random Firefox version string.
      def random_firefox_version_string
        [
          "Gecko/#{random_time_string('2011-01-01')} "\
          "Firefox/#{rand(5..7)}.0",
          "Gecko/#{random_time_string('2011-01-01')} "\
          "Firefox/#{rand(5..7)}.0.1",
          "Gecko/#{random_time_string('2010-01-01')} "\
          "Firefox/3.6.#{rand(1..20)}",
          "Gecko/#{random_time_string('2010-01-01')} "\
          'Firefox/3.8'
        ].sample
      end

      # A random Firefox platform string.
      # @param os the operating system that Firefox would be running on.
      # @return [String] a random Firefox platform string.
      def random_firefox_platform_string(os)
        version = random_firefox_version_string
        cpu = random_processor_string(os)

        if os == :linux
          return "(X11; Linux #{cpu}; rv:#{rand(5..7)}.0) #{version}"
        end

        if os == :osx
          return "(Macintosh; #{cpu} Mac OS X #{random_osx_version} "\
                 "rv:#{rand(2..6)}.0) #{version}"
        end

        if os == :windows
          return "(Windows NT #{random_nt_version}; en-US; rv:1.9."\
                 "#{rand(0..2)}.20) #{version}"
        end
      end

      # A random Safari platform string.
      # @param os the operating system that Safari would be running on.
      # @return [String] a random Safari platform string.
      def random_safari_platform_string(os)
        build = random_safari_build_number
        cpu = random_processor_string(os)
        version = random_safari_version

        if os == :osx
          return "(Macintosh; U; #{cpu} Mac OS X #{random_osx_version} rv:"\
                 "#{rand(2..6)}.0; en-US) AppleWebKit/#{build} "\
                 "(KHTML, like Gecko) Version/#{version} Safari/#{build}"
        else
          return "(Windows; U; Windows NT #{random_nt_version}) AppleWebKit/"\
                 "#{build} (KHTML, like Gecko) Version/#{version} "\
                 "Safari/#{build}"
        end
      end

      # A random Internet Explorer platform string.
      # @return [String] a random Internet Explorer platform string.
      def random_iexplorer_platform_string
        "(compatible; MSIE #{random_ie_version}; Windows NT "\
        "#{random_nt_version}; Trident/#{random_trident_version})"
      end

      # A random Opera platform string.
      # @param os the operating system that Opera would be running on.
      # @return [String] a random Opera platform string.
      def random_opera_platform_string(os)
        cpu = random_processor_string(os)
        presto = random_presto_version
        version = random_presto_version2

        if os == :linux
          return "(X11; Linux #{cpu}; U; en-US) Presto/#{presto} "\
                 "Version/#{version}"
        else
          return "(Windows NT #{random_nt_version}; U; en-US) "\
                 "Presto/#{presto} Version/#{version}"
        end
      end

      # A random Chrome platform string.
      # @param os the operating system that Chrome would be running on.
      # @return [String] a random Chrome platform string.
      def random_chrome_platform_string(os)
        cpu = random_processor_string(os)
        build = random_chrome_build_number
        version = random_chrome_version

        if os == :linux
          return "(X11; Linux #{cpu}) AppleWebKit/#{build} (KHTML, like Gecko)"\
                 " Chrome/#{version} Safari/#{build}"
        end

        if os == :osx
          return "(Macintosh; U; #{cpu} Mac OS X #{random_osx_version}) "\
                 "AppleWebKit/#{build} (KHTML, like Gecko) Chrome/"\
                 "#{version} Safari/#{build}"
        end

        if os == :windows
          return "(Windows NT #{random_nt_version}) AppleWebKit/#{build} "\
                 "(KHTML, like Gecko) Chrome/#{version} Safari/#{build}"
        end
      end

      # @return [String] a random browser user agent.
      def random_user_agent
        platform = random_browser_and_os
        os = platform[:os]

        if platform[:browser] == :firefox
          return "Mozilla/5.0 #{random_firefox_platform_string(os)}"
        elsif platform[:browser] == :safari
          return "Mozilla/5.0 #{random_safari_platform_string(os)}"
        elsif platform[:browser] == :iexplorer
          return "Mozilla/5.0 #{random_iexplorer_platform_string}"
        elsif platform[:browser] == :opera
          return "Opera/#{random_opera_version} "\
                 "#{random_opera_platform_string(os)}"
        else
          return "Mozilla/5.0 #{random_chrome_platform_string(os)}"
        end
      end
    end
  end
end
