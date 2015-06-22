require 'util/lumber'

module TestUtils

  include Util::Lumber::LumberJack

  @@log = lumber('TestUtils')


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