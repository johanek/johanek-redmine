require 'puppetlabs_spec_helper/rake_tasks'
require 'puppet-lint/tasks/puppet-lint'

task :test => [:spec, :lint]

task :default => :test

PuppetLint.configuration.send("disable_80chars")