if ENV['TRAVIS']
    require 'coveralls'
      Coveralls.wear!
end


require 'bundler/setup'
Bundler.require
require 'minitest/autorun'

