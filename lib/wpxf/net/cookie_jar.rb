module Wpxf
  module Net
    # A Hash derivitive that provides cookie parsing functionality.
    class CookieJar < Hash
      # @return [String] a cookie string.
      def to_s
        map { |key, value| "#{key}=#{value}" }.join('; ')
      end

      # Parse a cookie into the {CookieJar}.
      # @param cookie [String] the cookie to parse.
      # @return [CookieJar] the {CookieJar}.
      def parse_cookie(cookie)
        key, value = cookie.split('; ').first.split('=', 2)
        self[key] = value
        self
      end

      # Parse one or more cookies into the {CookieJar}.
      # @param cookies [Array, String] the cookies to parse.
      # @return [CookieJar] the {CookieJar}.
      def parse(cookies)
        return self if cookies.nil?

        if cookies.is_a? String
          parse_cookie(cookies)
        else
          cookies.each { |s| parse_cookie(s) }
        end

        self
      end
    end
  end
end
