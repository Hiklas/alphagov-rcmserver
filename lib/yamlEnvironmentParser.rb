require 'util/lumber'
require 'psych/handler'
require 'psych/json/tree_builder'

class YamlEnvironmentParser < Psych::TreeBuilder

  include Util::Lumber::LumberJack

  @@log = lumber("YamlEnvironmentParser")

  REPLACE_REGEXP = /\${[\w]+}/
  ENVIRONMENT_VARIABLE_REGEXP = /\${([\w]+)}/


  def initialize
    @@log.debug("Create parser")
    super
  end


  def scalar(value, anchor, tag, plain, quoted, style)
    @@log.debug('Scalar method called(%s, %s, %s, %s, %s, %s)', value, anchor, tag, plain, quoted, style)
    newValue = replace_env_value(value)
    super(newValue, anchor, tag, plain, quoted, style)
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

  def self.parse(yamlString)
    parser = Psych::Parser.new(YamlEnvironmentParser.new)
    parser.parse(yamlString)
    result = parser.handler.root

    # I believe the returned object is an Array because there can be multiple YAML documents
    # that are parsed.  In this case we only care about the first of these since it's just
    # simple configuration and we want to return a hash that is easy to index
    result ? result.to_ruby[0] : result
  end

end


