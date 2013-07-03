require 'test_helper'

module RemotePartial
  class PartialTest < ActiveSupport::TestCase

    def setup      
      @partial = Partial.find(1)
      @first_p = '<p>One</p>'
      @body = "<body><h1>Foo</h1><div>#{@first_p}<p>Bar</p></div></body>"
      enable_mock(@partial.url, @body)
    end

    def teardown
      disable_mock
    end

    def test_output_file_name
      expected = "#{RemotePartial.partial_location}/_#{@partial.name}.html.erb"
      assert_equal expected, @partial.output_file_name
    end

    def test_update_file
      remove_output_file
      @partial.update_file
      assert(File.exists?(@partial.output_file_name), "File should exist: #{@partial.output_file_name}")
      assert_equal_ignoring_cr @first_p, File.read(@partial.output_file_name)
      remove_output_file
    end

    def remove_output_file
      File.delete(@partial.output_file_name) if File.exists?(@partial.output_file_name)
    end

    def test_stale_at
      @partial.save
      expected = @partial.updated_at + @partial.repeat_period
      assert_equal expected.to_s(:db), @partial.stale_at.to_s(:db)
    end
  end
end
