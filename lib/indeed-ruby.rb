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
            (not raw) ? JSON.parse(response.to_str) : response.to_str
        end

        def valid_args(required_fields, args)
            for field in required_fields
                if field.kind_of?(Array)
                    has_one_required = false
                    for f in field
                        if args.has_key?(f)
                            has_one_required = true
                            break
                        end
                    end
                    if not has_one_required
                        raise IndeedClientError.new('You must provide one of the following %s' % [field.join(', ')])
                    end
                elsif not args.has_key?(field)
                    raise IndeedClientError.new('The field %s is required' % [field])
                end
            end
            args
        end

    end
end
