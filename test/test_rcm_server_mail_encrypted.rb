
require 'test/unit'
require 'rack/test'
require 'test_utils'

require 'util/lumber'
require 'rcm/processDataReturnObject'
require 'rcm/rcmEmailHandler'


class RCMServerAppMailEncryptedTest < Test::Unit::TestCase

  include Util::Lumber::LumberJack

  @@log = lumber("RCMServerAppMailEncryptedTest")

  # This includes the changeEnv method for testing with different environment variable settings
  include TestUtils

  SIMPLE_BODY = 'This is a simple form'
  SIMPLE_FROM = 'wibble@wibble.wobble'
  SIMPLE_RECIPIENT =  'terrypratchett@discworld.atuin'
  SIMPLE_SUBJECT = 'The Grim Squeaker'



  def setup
    # Make sure the test mailer is clear and has no outstanding messages
    Mail::TestMailer.deliveries.clear

    @rcmConfig = create_config_object()
    @emailHandler = create_email_handler(@rcmConfig)
  end


  def test_encryption_disabled
    @@log.debug("Testing email creation with encryption disabled")

    result = @emailHandler.create_email(SIMPLE_BODY)

    resultData = result.data

    assert(resultData.instance_of?(Mail::Message), "We didn't get a Mail::Message object, got #{resultData.class}")

    emailBody = resultData.body

    assert(emailBody.instance_of?(Mail::Body), "We didn't get a Mail::Body object, got #{emailBody.class}")

    emailBodyString = emailBody.decoded

    assert(emailBodyString == SIMPLE_BODY, "Didn't get expected body '#{SIMPLE_BODY}', got #{emailBody}")
  end


  def test_encryption_enabled
    @@log.debug("Testing email creation with encryption enabled")

    # This should allow Mail PGP to encrypt the email
    @rcmConfig.email_encryption_disabled = 'false'

    result = @emailHandler.create_email(SIMPLE_BODY)

    resultData = result.data

    assert(resultData.instance_of?(Mail::Message), "We didn't get a Mail::Message object, got #{resultData.class}")

    emailBody = resultData.body

    assert(emailBody.instance_of?(Mail::Body), "We didn't get a Mail::Body object, got #{emailBody.class}")

    emailBodyString = emailBody.decoded

    assert(emailBodyString == SIMPLE_BODY, "Didn't get expected body '#{SIMPLE_BODY}', got #{emailBody}")
  end



  private

    def create_config_object

      config_object = RCM::RCMConfig.new

      class << config_object
        attr_accessor :email_encryption_disabled
      end

      config_object
    end


    def create_email_handler(rcmConfig)
      RCM::EmailHandler.new(rcmConfig)
    end
end

