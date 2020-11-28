ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'
require "minitest/rails"
require "minitest/reporters"  # for Colorized output
#  For colorful output!
Minitest::Reporters.use!(
  Minitest::Reporters::SpecReporter.new,
  ENV,
  Minitest.backtrace_filter
)

class ActiveSupport::TestCase
  # Run tests in parallel with specified workers
  # parallelize(workers: :number_of_processors) # causes out of order output.

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  def setup
    OmniAuth.config.test_mode = true
  end

  def mock_auth_hash(user)
    return {
      provider: user.provider,
      uid: user.uid,
      info: {
        email: user.email,
        nickname: user.username
      }
    }
  end

  def perform_login(user = nil)
    user ||= User.first

    # Tell OmniAuth to use this user's info when it sees
    # an auth callback from github
    OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(mock_auth_hash(user))
    # Send a login request for that user
    # Note that we're using the named path for the callback, as defined
    # in the `as:` clause in `config/routes.rb`
    get omniauth_callback_path(:github)

    return user
  end

  # Add more helper methods to be used by all tests here...
end
