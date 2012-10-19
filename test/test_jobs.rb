require 'test/unit'
require '../lib/indeed-ruby'
require 'json'
require 'rexml/document'

class JobsTest < Test::Unit::TestCase

    def setup
        @client = Indeed::Client.new "YOUR_PUBLISHER_NUMBER"
        @params = {
            :jobkeys => ["5898e9d8f5c0593f", "c2c41f024581eae5"],
        }
    end

    def teardown
        @params = nil
    end

    def test_jobs
        assert @client.jobs(@params).is_a?(Hash)
    end

    def test_missing_jobkeys
        @params.delete(:jobkeys)
        assert_raise Indeed::IndeedClientError do
            @client.jobs(@params)
        end
    end

    def test_raw_json
        @params[:raw] = true
        response = @client.jobs(@params)
        assert_instance_of String, response
        assert JSON.parse(response).is_a?(Hash)
    end

    def test_raw_xml_with_parameter
        @params[:format] = "xml"
        @params[:raw] = true
        response = @client.jobs(@params)
        assert_instance_of String, response
        doc = REXML::Document.new(response)
        assert doc.root.has_elements?
    end

    def test_raw_xml_without_parameter
        @params[:format] = "xml"
        response = @client.jobs(@params)
        assert_instance_of String, response
        doc = REXML::Document.new(response)
        assert doc.root.has_elements?
    end

end