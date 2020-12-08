require 'omniauth-oauth2'

module OmniAuth
  module Strategies
    class Recurse < OmniAuth::Strategies::OAuth2
      # Give your strategy a name.
      option :recurse, "https://api.recurse.com/v1"

      # This is where you pass the options you would pass when
      # initializing your consumer from the OAuth gem.
      option :client_options, {
        :site => 'https://www.recurse.com/api/v1/',
        :authorize_url => 'https://www.recurse.com/oauth/authorize',
        :token_url => 'https://www.recurse.com/oauth/token'
      }
      
      # You may specify that your strategy should use PKCE by setting
      # the pkce option to true: https://tools.ietf.org/html/rfc7636
      option :pkce, true

      # These are called after authentication has succeeded. If
      # possible, you should try to set the UID without making
      # additional calls (if the user id is returned with the token
      # or as a URI parameter). This may not be possible with all
      # providers.
      uid{ raw_info['id'].to_s }

      info do
        {
          :first_name => raw_info['first_name'],
          :email => raw_info['email']
        }
      end

      extra do
        {
          'raw_info' => raw_info
        }
      end

      def raw_info
        @raw_info ||= access_token.get('people/me').parsed
      end
    end
  end
end
OmniAuth.config.add_camelization 'recurse', 'Recurse'
