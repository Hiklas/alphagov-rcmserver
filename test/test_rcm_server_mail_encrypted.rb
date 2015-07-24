
require 'test/unit'
require 'rack/test'
require 'test_utils'

require 'util/lumber'
require 'rcm/processDataReturnObject'
require 'rcm/rcmEmailHandler'


class RCMServerAppMailEncryptedTest < Test::Unit::TestCase

  include Util::Lumber::LumberJack

  @@log = lumber("RCMServerAppMailEncryptedTest")

  SIMPLE_BODY = 'This is a simple form'
  SIMPLE_FROM = 'fiona@silly.com'
  SIMPLE_RECIPIENT =  'death@discworld.atuin'
  SIMPLE_SUBJECT = 'The Grim Squeaker Returns'



  def setup
    # Make sure the test mailer is clear and has no outstanding messages
    Mail::TestMailer.deliveries.clear

    @rcmConfig = create_config_object()
    @emailHandler = create_email_handler(@rcmConfig)
  end



  def test_send_email_encryption_disabled
    @@log.debug("Testing email creation with encryption enabled")

    result = @emailHandler.create_email(SIMPLE_BODY)

    resultData = result.data

    assert(resultData.instance_of?(Mail::Message), "We didn't get a Mail::Message object, got #{resultData.class}")

    @@log.debug("Delivery handler: %s", resultData.delivery_handler)

    @emailHandler.send_email(resultData)

    deliveries = Mail::TestMailer.deliveries
    assert(deliveries!=nil, "Got nil deliveries")

    numberDeliveries = deliveries.length
    assert(numberDeliveries == 1, "Didn't get 1 delivery, got #{numberDeliveries}")

    delivery = deliveries.first

    from = delivery.from[0]
    to = delivery.to[0]
    subject = delivery.subject
    body = delivery.body

    assert(from == SIMPLE_FROM, "From is not correct, is #{from}")
    assert(to == SIMPLE_RECIPIENT, "To is not correct, is #{to}")
    assert(subject == SIMPLE_SUBJECT, "Subject is not correct, is #{subject}")
    assert(body == SIMPLE_BODY, "Body is not correct, is '#{body}' expected '#{SIMPLE_BODY}'")
  end


  def test_encryption_enabled
    @@log.debug('Testing email creation with encryption enabled')

    # This should allow Mail PGP to encrypt the email
    @rcmConfig.email_encryption_disabled = 'false'

    result = @emailHandler.create_email(SIMPLE_BODY)

    resultData = result.data

    assert(resultData.instance_of?(Mail::Message), "We didn't get a Mail::Message object, got #{resultData.class}")

    @@log.debug('*** before ***')
    @@log.debug('Delivery handler: %s', resultData.delivery_handler)
    @@log.debug('Mail.gpg: %s', resultData.gpg)

    @emailHandler.send_email(resultData)

    @@log.debug('*** after ***')
    @@log.debug('Mail content type: %s', resultData.content_type)
    @@log.debug('Mail mime type: %s', resultData.mime_type)
    @@log.debug('Delivery handler: %s', resultData.delivery_handler)
    @@log.debug('Mail.gpg: %s', resultData.gpg)

    deliveries = Mail::TestMailer.deliveries
    assert(deliveries!=nil, "Got nil deliveries")

    numberDeliveries = deliveries.length
    assert(numberDeliveries == 1, "Didn't get 1 delivery, got #{numberDeliveries}")

    delivery = deliveries.first

    @@log.debug('Delivery.encrypted? %s', delivery.encrypted?)
    from = delivery.from[0]
    to = delivery.to[0]
    subject = delivery.subject
    body = delivery.body

    assert(from == SIMPLE_FROM, "From is not correct, is #{from}")
    assert(to == SIMPLE_RECIPIENT, "To is not correct, is #{to}")
    assert(subject == SIMPLE_SUBJECT, "Subject is not correct, is #{subject}")
    assert(body != SIMPLE_BODY, "Body is not correct, is '#{body}' expected '#{SIMPLE_BODY}'")
  end



  private

    def create_config_object

      config_object = RCM::RCMConfig.new

      class << config_object

        def email_encryption_disabled
          @@log.debug("Returning encryption disabled: %s", @email_encryption_disabled)
          @email_encryption_disabled
        end

        def email_encryption_disabled=(disabled_value)
          @@log.debug("Setting email_encryption_disabled = %s", disabled_value)
          @email_encryption_disabled = disabled_value
        end

        def email_from
          @@log.debug("Returning from value")
          RCMServerAppMailEncryptedTest::SIMPLE_FROM
        end

        def email_recipient
          @@log.debug("Returning recipient")
          RCMServerAppMailEncryptedTest::SIMPLE_RECIPIENT
        end

        def email_subject
          @@log.debug("Returning subject")
          RCMServerAppMailEncryptedTest::SIMPLE_SUBJECT
        end
      end

      config_object
    end


    def create_email_handler(rcmConfig)
      RCM::EmailHandler.new(rcmConfig)
    end
end

