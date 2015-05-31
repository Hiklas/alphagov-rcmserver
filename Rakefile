require 'rake/testtask'

Rake::TestTask.new(:test) do |t|
  ENV['RACK_ENV'] = 'test'
  t.libs << "test"
  t.libs << "lib"
  t.pattern = 'test/**/test_*.rb'
  t.warning = true
end

