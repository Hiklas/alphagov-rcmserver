require 'util/lumber'
require 'yaml'
require 'yamlEnvironmentParser'


module RCM

  module Constants
    CONFIG_EMAIL = 'email'
    CONFIG_SERVER = 'server'

    CONFIG_DELIVERY = 'delivery_method'
    CONFIG_SMTP_PORT = 'smtp_port'
    CONFIG_SMTP_SERVER = 'smtp_server'
    CONFIG_SMTP_USERNAME = 'smtp_username'
    CONFIG_SMTP_PASSWORD = 'smtp_password'
    CONFIG_EMAIL_DOMAIN = 'domain'

    CONFIG_ADDRESSING = 'address'
    CONFIG_RECIPIENT = 'recipient'
    CONFIG_FROM = 'from'
    CONFIG_SUBJECT = 'subject'
    CONFIG_PGP_KEY = 'pgp'
    CONFIG_DISABLED = 'disabled'

    CONFIG_FORMAT = 'format'
    CONFIG_TEMPLATE = 'template'

    CONFIG_EVIDENCE = 'evidence'
    CONFIG_MINIMUM_LENGTH = 'minimum'
    CONFIG_MAXIMUM_LENGTH = 'maximum'
    CONFIG_LINE_LENGTH = 'line'

    ENV_EMAIL_DISABLED = 'EMAIL_DISABLED'
  end


  ##
  #
  # Holds all of the configuration details for the RCMServer
  #
  class RCMConfig

    include Util::Lumber::LumberJack

    @@log = lumber("RCMConfig")

    include RCM::Constants

    RCM_CONFIG_ENV = 'RCM_CONFIG_FILENAME'
    DEFAULT_CONFIG_FILENAME = 'conf/rcm-server-development.yaml'

    CONFIG_FILE_PATH_BASE = 'conf/rcm-server-'
    CONFIG_FILE_PATH_EXTENSION = '.yaml'

    RACK_ENVIRONMENT = 'RACK_ENV'

    DEFAULT_MINIMUM_LENGTH = 10
    DEFAULT_MAXIMUM_LENGTH = 8000
    DEFAULT_LINE_LENGTH = 80


    def initialize
      load_configuration
    end


    def minimum_length
      evidence_config(CONFIG_MINIMUM_LENGTH) || DEFAULT_MINIMUM_LENGTH
    end

    def maximum_length
      evidence_config(CONFIG_MAXIMUM_LENGTH) || DEFAULT_MAXIMUM_LENGTH
    end

    def line_length
      evidence_config(CONFIG_LINE_LENGTH) || DEFAULT_LINE_LENGTH
    end


    def email_from
      email_send_config(CONFIG_FROM)
    end

    def email_recipient
      email_send_config(CONFIG_RECIPIENT)
    end

    def email_subject
      email_send_config(CONFIG_SUBJECT)
    end


    def email_disabled
      # TODO: Bit of a hack here.  Under normal circumstances the status of the email_disabled setting
      # TODO: would just be read from the yaml file.  For testing however, the same Ruby VM is used for all
      # TODO: tests so that once the rcmServer has been created (and the yaml config read) things don't change.
      # TODO: This means that the tests for disabling email won't work as they need to set the environment for
      # TODO: just this run.  For now, we're using this hack (force the environment to be re-read).  Ideally
      # TODO: this test should be run in a new VM, OR we have another mechnanism for configuring the application
      # TODO: that allows runtime changes.
      environment_config(ENV_EMAIL_DISABLED) || email_send_config(CONFIG_DISABLED)
    end


    def email_template
      email_format_config(CONFIG_TEMPLATE)
    end


    def email_delivery_method
      email_server_config(CONFIG_DELIVERY)
    end


    def email_server_address
      email_server_config(CONFIG_SMTP_SERVER)
    end

    def email_server_port
      email_server_config(CONFIG_SMTP_PORT)
    end

    def email_username
      email_server_config(CONFIG_SMTP_USERNAME)
    end

    def email_password
      email_server_config(CONFIG_SMTP_PASSWORD)
    end

    def email_domain
      email_server_config(CONFIG_EMAIL_DOMAIN)
    end


    private

      def load_configuration
        # This must be passed in using rackup -e "\$configFilename='<filename>'"
        configFilename = config_filename

        @@log.debug('Loading yaml config from "%s" ...', configFilename)

        @config = YamlEnvironmentParser.parse(File.read(configFilename))

        @@log.debug('... loaded')
      end


      def calculate_config_filename
        rack_environment = ENV[RACK_ENVIRONMENT]
        if rack_environment.nil?
          @@log.debug('No rack environment set, defaulting filename')
          DEFAULT_CONFIG_FILENAME
        else
          @@log.debug('Using rack environment setting: %s', rack_environment)
          "#{CONFIG_FILE_PATH_BASE}#{rack_environment}#{CONFIG_FILE_PATH_EXTENSION}"
        end
      end


      ##
      #
      # We need a bootstrap for this filename to load our config
      #
      def config_filename
        ENV[RCM_CONFIG_ENV] || calculate_config_filename
      end


      def email_server_config(key)
        value = @config[CONFIG_EMAIL][CONFIG_SERVER][key]
        @@log.debug('Email server config, key=%s, value=%s', key, value)
        value
      end

      def email_send_config(key)
        value = @config[CONFIG_EMAIL][CONFIG_ADDRESSING][key]
        @@log.debug('Email send config, key=%s, value=%s', key, value)
        value
      end

      def email_format_config(key)
        value = @config[CONFIG_EMAIL][CONFIG_FORMAT][key]
        @@log.debug('Email format config, key=%s, value=%s', key, value)
        value
      end

      def evidence_config(key)
        value = @config[CONFIG_EMAIL][key]
        @@log.debug('Email config, key=%s, value=%s', key, value)
        value
      end

      def environment_config(key)
        ENV[key]
      end

      def print_environment
        ENV.each_key do |key|
          @@log.debug('Environment, key=%s, value=%s', key, ENV[key])
        end
      end

  end

end