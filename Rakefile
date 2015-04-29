require 'rake/testtask'

Rake::TestTask.new(:test) do |t|
  t.libs << "tests"
  t.libs << "lib"
  t.pattern = 'test/**/test_*.rb'
  t.warning = true
end

