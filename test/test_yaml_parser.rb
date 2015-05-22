require 'util/logger'
require 'yamlEnvironmentParser'
require 'test/unit'

class RCMYamlParserTest < Test::Unit::TestCase

  @@log = Util::LoggerLikeJava.new("RCMYamlParserTest")

  TEST_EMPTY_ENV = 'SILLY_SILLY_DAFT_NULL'
  TEST_VALID_ENV_NAME = 'SILLY_SILLY_VALID_ENV'
  TEST_VALID_ENV_VALUE = 'sensible value'

  def test_get_missing_environment_variable
    parser = createTestParser
    result = parser.get_environment_value(TEST_EMPTY_ENV)
    assert(result == 'No environment found for SILLY_SILLY_DAFT_NULL', "Result wasn't as expected, was '#{result}'")
  end


  def test_get_test_value_from_environment_variable
    parser = createTestParser

    changeEnv({ TEST_VALID_ENV_NAME => TEST_VALID_ENV_VALUE }) do
      result = parser.get_environment_value(TEST_VALID_ENV_NAME)
      assert(result == TEST_VALID_ENV_VALUE, "Result wasn't correct, was '#{result}'")
    end
  end


  private

  def createTestParser
    YamlEnvironmentParser.new
  end

  def changeEnv(hashOfEnvValues, *args, &block)
    @@log.debug("Setting environment: #{hashOfEnvValues}")

    hashOfEnvValues.each_key do |key|
      value = hashOfEnvValues[key]
      @@log.debug("Setting #{key} to #{value}")
      ENV[key] = value
    end

    @@log.debug("Calling block ...")
    block.call(args)
    @@log.debug("...  resetting environment")

    hashOfEnvValues.each_key do |key|
      ENV[key] = nil
    end

  end
end

