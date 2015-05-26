require 'util/lumber'
require 'yamlEnvironmentParser'
require 'test/unit'

class RCMYamlParserTest < Test::Unit::TestCase

  include Util::Lumber::LumberJack

  @@log = lumber("RCMYamlParserTest")

  TEST_EMPTY_ENV = 'SILLY_SILLY_DAFT_NULL'
  TEST_VALID_ENV_NAME = 'SILLY_SILLY_VALID_ENV'
  TEST_VALID_ENV_VALUE = 'sensible value'

  TEST_REPLACEMENT_STRING = "This is ${#{TEST_VALID_ENV_NAME}}"
  TEST_REPLACEMENT_STRING_RESULT = "This is #{TEST_VALID_ENV_VALUE}"

  TEST_REPLACEMENT_STRING_FAIL = "This is ${#{TEST_EMPTY_ENV}}"
  TEST_REPLACEMENT_STRING_FAIL_RESULT = "This is (No value found for #{TEST_EMPTY_ENV})"


  def test_get_missing_environment_variable
    parser = createTestParser
    result = parser.get_environment_value(TEST_EMPTY_ENV)
    assert(result == '(No value found for SILLY_SILLY_DAFT_NULL)', "Result wasn't as expected, was '#{result}'")
  end


  def test_get_test_value_from_environment_variable
    parser = createTestParser

    changeEnv({ TEST_VALID_ENV_NAME => TEST_VALID_ENV_VALUE }) do
      result = parser.get_environment_value(TEST_VALID_ENV_NAME)
      assert(result == TEST_VALID_ENV_VALUE, "Result wasn't correct, was '#{result}'")
    end
  end


  def test_replace_test_value_from_environment_variable
    parser = createTestParser

    changeEnv({ TEST_VALID_ENV_NAME => TEST_VALID_ENV_VALUE }) do
      result = parser.replace_env_value(TEST_REPLACEMENT_STRING)
      assert(result == TEST_REPLACEMENT_STRING_RESULT, "Result wasn't correct, was '#{result}'")
    end
  end


  def test_replace_test_value_for_invalid_environment_variable
    parser = createTestParser

    changeEnv({ TEST_VALID_ENV_NAME => TEST_VALID_ENV_VALUE }) do
      result = parser.replace_env_value(TEST_REPLACEMENT_STRING_FAIL)
      assert(result == TEST_REPLACEMENT_STRING_FAIL_RESULT, "Result wasn't correct, was '#{result}'")
    end
  end


  private

  def createTestParser
    YamlEnvironmentParser.new
  end


  def changeEnv(hashOfEnvValues, *args, &block)
    @@log.debug('Setting environment: %s', hashOfEnvValues)

    hashOfEnvValues.each_key do |key|
      value = hashOfEnvValues[key]
      @@log.debug('Setting %s to %s', key, value)
      ENV[key] = value
    end

    @@log.debug('Calling block ...')
    block.call(args)
    @@log.debug('...  resetting environment')

    hashOfEnvValues.each_key do |key|
      ENV[key] = nil
    end

  end
end

