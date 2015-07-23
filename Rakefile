require 'rake/testtask'

Rake::TestTask.new(:test) do |t|
  ENV['RACK_ENV'] = 'test'
  t.libs << "test"
  t.libs << "lib"
  t.pattern = 'test/**/test_*.rb'
  t.warning = true
end


Rake::TestTask.new(:test_mustache) do |t|
  ENV['RACK_ENV'] = 'test'
  t.libs << "test"
  t.libs << "lib"
  t.pattern = 'test/**/test_mustache_*.rb'
  t.warning = true
end


Rake::TestTask.new(:test_encrypted) do |t|
  ENV['RACK_ENV'] = 'test'
  t.libs << "test"
  t.libs << "lib"
  t.pattern = 'test/**/test_*_encrypted.rb'
  t.warning = true
end



