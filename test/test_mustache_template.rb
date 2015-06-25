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
  FULL_TEMPLATE_FILE = 'conf/email-template-plain.mustache'

  SIMPLE_DOT_TEMPLATE = 'test/dot-notation.mustache'
  DEEP_DOT_TEMPLATE = 'test/dot-notation-deep.mustache'
  VISIBLE_SECTION_TEMPLATE = 'test/visible-section.mustache'
  MISSING_SECTION_TEMPLATE = 'test/missing-section.mustache'

  SIMPLE_DOT_RESULT = "Hello Terry Pratchett!\nHow are you today?"
  DEEP_DOT_RESULT = "Hello Terry Pratchett!\nHow are you today string?"
  VISIBLE_SECTION_RESULT = "TimeStamp: Thu Jun 11 2015 16:32:28 GMT+0100 (BST)\nFirst name: Joe\nLast name: Bloggs\nAlias first name: Carrot\nAlias last name: Ironfoundersson\n"
  MISSING_SECTION_RESULT = "TimeStamp: Thu Jun 11 2015 16:32:28 GMT+0100 (BST)\nFirst name: Joe\nLast name: Bloggs\n"
  FULL_RESULT = "TimeStamp: Thu Jun 11 2015 16:32:28 GMT+0100 (BST)\nFraud type: workEarning\nFirst name: Joe\nLast name: Bloggs\nAlternative name present: No\nAlias first name: Carrot\nAlias last name: Ironfoundersson\nDate of birth present: No\nDate of birth: //\nAge: 35\nAddress present: Yes\nAddress: 1 Terrace street Hull  HU11 1DS\nNINO Present: No\nNINO: \nTelephone present: Yes\nMobile: 07780807070\nHome: \nOther: \nE-mail present: Yes\nEmail: joe@bloggs.com\nSocial media: facebook\nWork location: At home\nSelf employed present: Yes\nType of work: He makes beer\nWork duration: years\nTimings: N/A (he works from home)\nAdditional information: He makes very nice beer that I buy while he&#39;s on benefit\n"



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


  def test_nested_sections_present_in_data
    mustache = Mustache.new
    mustache.template_file = VISIBLE_SECTION_TEMPLATE

    assert(mustache.template_file == VISIBLE_SECTION_TEMPLATE, 'Template file wasn\'t set to the correct value')

    data_hash = @@json_data

    mustache[:timestamp] = data_hash['timestamp']
    mustache[:values] = data_hash['values']

    output = mustache.render

    assert(output != nil, 'Didn\'t get any output')
    @@log.debug('Got output from template: "%s", expected: "%s"', output, VISIBLE_SECTION_RESULT)
    assert(output == VISIBLE_SECTION_RESULT, "Didn't get expected output")
  end


  def test_nested_sections_missing_in_data
    mustache = Mustache.new
    mustache.template_file = MISSING_SECTION_TEMPLATE

    assert(mustache.template_file == MISSING_SECTION_TEMPLATE, 'Template file wasn\'t set to the correct value')

    data_hash = @@json_data

    mustache[:timestamp] = data_hash['timestamp']
    mustache[:values] = data_hash['values']

    output = mustache.render

    assert(output != nil, 'Didn\'t get any output')
    @@log.debug('Got output from template: "%s", expected: "%s"', output, MISSING_SECTION_RESULT)
    assert(output == MISSING_SECTION_RESULT, "Didn't get expected output")
  end


  def test_full_template
    mustache = Mustache.new
    mustache.template_file = FULL_TEMPLATE_FILE

    assert(mustache.template_file == FULL_TEMPLATE_FILE, 'Template file wasn\'t set to the correct value')

    data_hash = @@json_data

    mustache[:timestamp] = data_hash['timestamp']
    mustache[:values] = data_hash['values']

    output = mustache.render

    assert(output != nil, 'Didn\'t get any output')
    @@log.debug('Got output from template: "%s", expected: "%s"', output, FULL_RESULT)

    assert(output == FULL_RESULT, "Didn't get expected output")
  end

end

