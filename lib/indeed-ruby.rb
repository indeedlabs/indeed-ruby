require 'rest_client'
require 'json'
module Indeed

    class IndeedClientError < StandardError
    end

    class Client

        API_ROOT = 'http://api.indeed.com/ads'
        DEFAULT_FORMAT = 'json'

        API_SEARCH = {
            :end_point => "#{API_ROOT}/apisearch",
            :required_fields => [:userip, :useragent, [:q, :l]],
        }

        API_JOBS = {
            :end_point => "#{API_ROOT}/apigetjobs",
            :required_fields => [:jobkeys],
        }

        def initialize(publisher, version = "2")
            @publisher = publisher
            @version = version
        end

        def search(params)
            process_request(API_SEARCH[:end_point], valid_args(API_SEARCH[:required_fields], params))
        end

        def jobs(params)
            valid_args = valid_args(API_JOBS[:required_fields], params)
            valid_args[:jobkeys] = valid_args[:jobkeys].join(',')
            process_request(API_JOBS[:end_point], valid_args)
        end

        private

        def process_request(endpoint, args)
            format = args.fetch(:format, DEFAULT_FORMAT)
            raw = format == 'xml' ? true : args.fetch(:raw, false)
            args.merge!({:v => @version, :publisher => @publisher, :format => format})
            response = RestClient.get endpoint, {:params => args}
            r = (not raw) ? JSON.parse(response.to_str) : response.to_str
            r
        end

        def valid_args(required_fields, args)
          required_fields.each do |field|
            if field.kind_of?(Array)
              at_least_one_is_required_from field, args
            else
              raise IndeedClientError.new('The field %s is required' % [field]) unless args.has_key?(field)
            end
          end

          args
        end

        def at_least_one_is_required_from field, args
          field.each do |key|
            if args.has_key?(key)
              return true
            else
              raise IndeedClientError.new('You must provide one of the following %s' % [field.join(', ')])
            end
          end
        end
    end
end
