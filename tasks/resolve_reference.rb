#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../../ruby_task_helper/files/task_helper.rb'
require_relative '../../baseline/lib/facter/inventory.rb'
require 'yaml'

class BaselineReference < TaskHelper
  def task(**opts)
    result = []
    zone = opts[:zone] || '*'
    domain = opts[:domain] || '*'

    systemconfig = Systemconfig::Facts::Inventory.new('data/**/*.yaml')
    systemconfig.to_facts.map do |host, item|
      next unless File.fnmatch(zone, item[:zone])
      next unless File.fnmatch(domain, item[:domain])
      result.push(host)
    end

    { value: result.sort }
  end
end

if $PROGRAM_NAME == __FILE__
  BaselineReference.run
end