require 'rest_client'
require 'json'
module Indeed
    
    class IndeedClientError < StandardError
        attr_reader :object
        
        def initialize(object)
            @object = object
        end
    end

    class Client

        API_ROOT = 'https://api.indeed.com/ads'
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
            begin
                valid_args = valid_args(API_SEARCH[:required_fields], params)
            rescue IndeedClientError => err
                return error_response(err.object)
            end

            process_request(API_SEARCH[:end_point], valid_args)
        end

        def jobs(params)
            begin
                valid_args = valid_args(API_JOBS[:required_fields], params)
            rescue IndeedClientError => err
                return error_response(err.object)
            end
            
            valid_args[:jobkeys] = valid_args[:jobkeys].join(',')
            process_request(API_JOBS[:end_point], valid_args)
        end

        private

        def process_request(endpoint, args)
            format = args.fetch(:format, DEFAULT_FORMAT)
            raw = format == 'xml' ? true : args.fetch(:raw, false)
            args.merge!({:v => @version, :publisher => @publisher, :format => format})
            begin
                Timeout.timeout(5) do
                    response = RestClient.get endpoint, {:params => args}
                    r = (not raw) ? JSON.parse(response.to_str) : response.to_str
                    r
                end
            rescue Timeout::Error => err
                error_response({message: err.message})
            rescue => err
                error_response({message: err.message})
            end
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
                        raise IndeedClientError.new({message: 'You must provide one of the following %s' % [field.join(', ')]})
                    end
                elsif not args.has_key?(field)
                    raise IndeedClientError.new({message: 'The field %s is required' % [field]})
                end
            end
            args
        end

        def error_response(response_object)
            { errors: [response_object], results: [], totalResults: 0 }
        end
    end
end
