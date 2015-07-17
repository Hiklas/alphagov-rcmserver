require 'test/unit'
require 'test_utils'

require 'util/lumber'
require 'util/yamlEnvironmentParser'


class RCMYamlParserTest < Test::Unit::TestCase

  include Util::Lumber::LumberJack

  @@log = lumber("RCMYamlParserTest")

  # This includes the changeEnv method for testing with different environment variable settings
  include TestUtils

  TEST_EMPTY_ENV = 'SILLY_SILLY_DAFT_NULL'
  TEST_VALID_ENV_NAME = 'SILLY_SILLY_VALID_ENV'
  TEST_VALID_ENV_VALUE = 'sensible value'

  TEST_REPLACEMENT_STRING = "This is ${#{TEST_VALID_ENV_NAME}}"
  TEST_REPLACEMENT_STRING_RESULT = "This is #{TEST_VALID_ENV_VALUE}"

  TEST_REPLACEMENT_STRING_FAIL = "This is ${#{TEST_EMPTY_ENV}}"
  TEST_REPLACEMENT_STRING_FAIL_RESULT = "This is (No value found for #{TEST_EMPTY_ENV})"

  TEST_YAML_SIMPLE_STRING = "object:\n  obj1: fred\n  obj2: jim\n\nanother:\n  obj1: sheila"
  TEST_YAML_REPLACE_STRING = "object:\n  obj1: ${#{TEST_VALID_ENV_NAME}}\n  obj2: jim\n\nanother:\n  obj1: sheila"
  TEST_YAML_REPLACE_EMPTY_STRING = "object:\n  obj1: ${#{TEST_EMPTY_ENV}}\n  obj2: jim\n\nanother:\n  obj1: sheila"



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


  def test_parsing_simple_yaml
    changeEnv({ TEST_VALID_ENV_NAME => TEST_VALID_ENV_VALUE }) do
      result = Util::YamlEnvironmentParser.parse(TEST_YAML_SIMPLE_STRING)
      @@log.debug('Parsed simple yaml and got this: %s', result)
      @@log.debug('Parsed simple yaml and got this object: %s', result['object'])
      @@log.debug('Parsed simple yaml and got this another: %s', result['another'])
      fred = result['object']['obj1']
      sheila = result['another']['obj1']
      assert(fred == 'fred', "Didn't get fred, got #{fred}")
      assert(sheila == 'sheila', "Didn't get sheila, got #{sheila}")

    end
  end


  def test_parsing_replace_yaml
    changeEnv({ TEST_VALID_ENV_NAME => TEST_VALID_ENV_VALUE }) do
      result = Util::YamlEnvironmentParser.parse(TEST_YAML_REPLACE_STRING)
      fred = result['object']['obj1']
      sheila = result['another']['obj1']
      assert(fred == TEST_VALID_ENV_VALUE, "Didn't get valid value, got #{fred}")
      assert(sheila == 'sheila', "Didn't get sheila, got #{sheila}")
    end
  end


  def test_parsing_replace_missing_environment_variable
    changeEnv({ TEST_VALID_ENV_NAME => TEST_VALID_ENV_VALUE }) do
      result = Util::YamlEnvironmentParser.parse(TEST_YAML_REPLACE_EMPTY_STRING)
      fred = result['object']['obj1']
      sheila = result['another']['obj1']
      assert(fred == "(No value found for #{TEST_EMPTY_ENV})", "Didn't get empty/missing result, got #{fred}")
      assert(sheila == 'sheila', "Didn't get sheila, got #{sheila}")
    end
  end


  private

  def createTestParser
    Util::YamlEnvironmentParser.new
  end

end

