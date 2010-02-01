require 'test/unit'

rcsid = %w$Id: runner.rb 1751 2007-05-02 08:15:55Z nahi $
Version = rcsid[2].scan(/\d+/).collect!(&method(:Integer)).freeze
Release = rcsid[3].freeze

exit Test::Unit::AutoRunner.run(true, File.dirname($0))
