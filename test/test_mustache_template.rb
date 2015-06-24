require 'util/lumber'
require 'test/unit'
require 'mustache'
require 'json'


class RCMMustacheTemplateTest < Test::Unit::TestCase

  include Util::Lumber::LumberJack

  @@log = lumber("RCMMustacheTemplateTest")

  # TODO: Do we really need to initialise class variables?
  @@json_data = nil


  JSON_FILE = 'test/client.post.test.json'
  FULL_TEMPLATE_FILE = 'conf/email-template.mustache'
  SIMPLE_DOT_TEMPLATE = 'test/dot-notation.mustache'
  DEEP_DOT_TEMPLATE = 'test/dot-notation-deep.mustache'

  SIMPLE_DOT_RESULT = "Hello Terry Pratchett!\nHow are you today?"
  DEEP_DOT_RESULT = "Hello Terry Pratchett!\nHow are you today string?"

  def self.read_json
    @@log.debug('Reading file ...')
    json_text = File.read(JSON_FILE)

    @@log.debug('... Read file, parsing ...')
    @@json_data = JSON.parse(json_text)

    @@log.debug('... done parsing, got %d text for a hash with %d entries', json_text.length, @@json_data.size)
  end


  def setup
    RCMMustacheTemplateTest::read_json if @@json_data.nil?
  end


  def test_loading_template
    mustache = Mustache.new
    mustache.template_file = FULL_TEMPLATE_FILE

    assert(mustache.template_file == FULL_TEMPLATE_FILE, 'Template file wasn\'t set to the correct value')
  end


  def test_dot_notation
    mustache = Mustache.new
    mustache.template_file = SIMPLE_DOT_TEMPLATE

    assert(mustache.template_file == SIMPLE_DOT_TEMPLATE, 'Template file wasn\'t set to the correct value')

    data_hash = {
        name: 'Terry Pratchett',
        date: {
            when: 'today'
        }
    }

    mustache[:data] = data_hash
    output = mustache.render

    assert(output != nil, 'Didn\'t get any output')
    @@log.debug('Got output from template: "%s", expected: "%s"', output, SIMPLE_DOT_RESULT)

    assert(output == SIMPLE_DOT_RESULT, 'Didn\'t get correct result')
  end


  def test_dot_notation_deep
    mustache = Mustache.new
    mustache.template_file = DEEP_DOT_TEMPLATE

    assert(mustache.template_file == DEEP_DOT_TEMPLATE, 'Template file wasn\'t set to the correct value')

    data_hash = {
        name: 'Terry Pratchett',
        date: {
            when: {
                number: {
                    string: 'today string'
                }
            }
        }
    }

    mustache[:data] = data_hash
    output = mustache.render

    assert(output != nil, 'Didn\'t get any output')
    @@log.debug('Got output from template: "%s" expected: "%s"', output, DEEP_DOT_RESULT)

    assert(output == DEEP_DOT_RESULT, 'Didn\'t get correct result')
  end

end

