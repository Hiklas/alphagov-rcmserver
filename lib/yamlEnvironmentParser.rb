require 'psych/handler'
require 'psych/json/tree_builder'

class YamlEnvironmentParser < Psych::TreeBuilder

  REPLACE_REGEXP = /\${[\w]+}/
  ENVIRONMENT_VARIABLE_REGEXP = /\${([\w]+)}/


  def initialize

  end


  def scalar(value, anchor, tag, plain, quoted, style)

  end

  def replace_env_value(value)
    value.gsub(REPLACE_REGEXP) do |envMatch|
      env_variable_match = ENVIRONMENT_VARIABLE_REGEXP.match(envMatch)
      env_variable = env_variable_match[0]
      (env_variable==nil) ? "No variable found" : get_environment_value(env_variable)
    end
    value
  end

  def get_environment_value(env_variable)
    value_from_environment = ENV[env_variable]
    (value_from_environment == nil) ? "No environment found for #{env_variable}" : value_from_environment
  end

  def parse(filename)
    parser = Psych::Parser.new(YamlEnvironmentParser.new)

  end

end


