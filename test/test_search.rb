require 'test/unit'
require '../lib/indeed-ruby'
require 'json'
require 'rexml/document'

class SearchTest < Test::Unit::TestCase

    def setup
        @client = Indeed::Client.new "6899355879139391"
        @params = {
            :q => 'ruby',
            :l => 'austin',
            :userip => '1.2.3.4',
            :useragent => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_2)',
        }
    end

    def teardown
        @params = nil
    end

    def test_search
        assert @client.search(@params).is_a?(Hash)
    end

    def test_missing_one_required
        @params.delete(:l)
        assert @client.search(@params).is_a?(Hash)
    end

    def test_missing_both_required
        @params.delete(:q)
        @params.delete(:l)
        assert_raise Indeed::IndeedClientError do
            @client.search(@params)
        end
    end

    def test_missing_userip
        @params.delete(:userip)
        assert_raise Indeed::IndeedClientError do
            @client.search(@params)
        end
    end

    def test_missing_useragent
        @params.delete(:useragent)
        assert_raise Indeed::IndeedClientError do
            @client.search(@params)
        end
    end

    def test_raw_json
        @params[:raw] = true
        response = @client.search(@params)
        assert_instance_of String, response
        assert JSON.parse(response).is_a?(Hash)
    end

    def test_raw_xml_with_parameter
        @params[:format] = "xml"
        @params[:raw] = true
        response = @client.search(@params)
        assert_instance_of String, response
        doc = REXML::Document.new(response)
        assert doc.root.has_elements?
    end

    def test_raw_xml_without_parameter
        @params[:format] = "xml"
        response = @client.search(@params)
        assert_instance_of String, response
        doc = REXML::Document.new(response)
        assert doc.root.has_elements?
    end

end