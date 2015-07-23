require 'mail'
require 'mail-gpg'
require 'mustache'

require 'util/lumber'
require 'rcm/rcmConfig'
require 'rcm/responseGenerator'


module RCM

  class EmailHandler

    include Util::Lumber::LumberJack

    @@log = lumber("EmailHandler")

    include RCM::ResponseGenerator


    def initialize(rcmConfig)
      @rcmConfig = rcmConfig
      configure_format
      configure_email
    end


    def generate_form(json_hash)
      # Response object
      response = ProcessDataReturnObject.new

      begin
        mustache = Mustache.new
        mustache.template = @template

        json_hash.each_key do |key|
          mustache[key.to_sym] = json_hash[key]
        end

        response.data = mustache.render
        response.status = true

      rescue Exception => ee
        @@log.error('Couldn\'t process template, exception: ', ee)
      end

      # Remember to have response on it's own as the last statement so this is the return object
      response
    end


    def create_email(parsed_data)
      @@log.debug('Creating email')

      # Response object
      response = ProcessDataReturnObject.new

      from_value = @rcmConfig.email_from
      recipient_value = @rcmConfig.email_recipient
      subject_value = @rcmConfig.email_subject
      pgp_disabled_value = @rcmConfig.email_encryption_disabled
      pgp_key_value = @rcmConfig.email_encryption_key

      mail = Mail.new do
        from     from_value
        to       recipient_value
        subject  subject_value
        body     parsed_data
        gpg encrypt: (pgp_disabled_value != 'true'), keys: { from_value => pgp_key_value }
      end

      response.data = mail
      response.status = true

      # Remember to have response on it's own as the last statement so this is the return object
      response
    end


    def send_email(email_data)
      @@log.debug('Sending email')

      # Response object
      response = ProcessDataReturnObject.new

      disabled = @rcmConfig.email_disabled

      @@log.debug('Email disabled: %s', disabled)

      if disabled == 'true'
        @@log.info('*** Skipping sending of email ***')
        response.data = generate_success_response('Email skipped')
      else
        @@log.debug('About to send the email')
        email_data.deliver!
        response.data = generate_success_response('Email sent')
        @@log.debug('Email sent')
      end

      response.status = true

      # Remember to have response on it's own as the last statement so this is the return object
      response
    end


    private

      def configure_format
        template_filename = @rcmConfig.email_template
        @@log.debug('Reading template file: %s', template_filename)
        @template = File.read(template_filename)
      end


      def configure_email
        mail_method_text = @rcmConfig.email_delivery_method
        mail_method_sym = (mail_method_text) ? mail_method_text.to_sym : nil

        options = {
           address: @rcmConfig.email_server_address,
           port: @rcmConfig.email_server_port,
           user_name: @rcmConfig.email_username,
           password: @rcmConfig.email_password,
           domain: @rcmConfig.email_domain
        }

        @@log.debug('Configuring email with method \'%s\' and options: %s', mail_method_sym, options)

        Mail.defaults do
          delivery_method mail_method_sym, options
        end
      end

  end

end