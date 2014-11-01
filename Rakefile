require 'puppetlabs_spec_helper/rake_tasks'
require 'puppet-lint/tasks/puppet-lint'
require 'puppet-syntax/tasks/puppet-syntax'

task :test => [:lint, :syntax, :spec]

task :default => :test

PuppetLint.configuration.send("disable_80chars")
