require 'util/lumber'
require 'psych/handler'
require 'psych/json/tree_builder'

class YamlEnvironmentParser < Psych::TreeBuilder

  include Util::Lumber::LumberJack

  @@log = lumber("RCMServer")

  REPLACE_REGEXP = /\${[\w]+}/
  ENVIRONMENT_VARIABLE_REGEXP = /\${([\w]+)}/


  def initialize
    @@log.debug("Create parser")
  end


  def scalar(value, anchor, tag, plain, quoted, style)

  end

  def replace_env_value(value)
    result = value.gsub(REPLACE_REGEXP) do |envMatch|
      @@log.debug('Found a match: %s', envMatch)
      env_variable_name_match = ENVIRONMENT_VARIABLE_REGEXP.match(envMatch)
      env_variable_name = env_variable_name_match[1]
      (env_variable_name==nil) ? 'No variable name found' : get_environment_value(env_variable_name)
    end
    result
  end

  def get_environment_value(env_variable)
    @@log.debug('Getting value of: %s',env_variable)
    value_from_environment = ENV[env_variable]
    (value_from_environment == nil) ? "(No value found for #{env_variable})" : value_from_environment
  end

  def parse(yamlString, filename)
    parser = Psych::Parser.new(YamlEnvironmentParser.new)
  end

end


