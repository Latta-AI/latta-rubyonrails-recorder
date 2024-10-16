require 'httparty'
require 'securerandom'
require 'json'
require 'sys/cpu'
require 'sys/memory'
require 'stringio'

module Latta
  class Middleware
    def initialize(app)
      @app = app
    end

    def call(env)
      log_output = StringIO.new
      original_logger = Rails.logger

      begin
        Rails.logger = Logger.new(log_output)
        status, headers, response = @app.call(env)
        [status, headers, response]
      rescue => exception
        console_output = log_output.string
        capture_exception(env, exception, console_output)
        raise exception
      ensure
        Rails.logger = original_logger
      end
    end

    private

    def capture_exception(env, exception, console_output)
      request = ActionDispatch::Request.new(env)
      status = 500
      body = "An error occurred"

      begin
        status, headers, response = @app.call(env)
        body = response.body if response.respond_to?(:body)
      rescue
      end
      
      send_to_api(request, status, body, exception, console_output)
    end

    def put_snapshot(request)
      config = Latta.configuration
      api_key = config.api_key
      url = "#{LattaProperties::LATTA_API_URI}/#{LattaEndpoints::put_snapshot(config.instance_id)}"
      related_to_id = request.headers['Latta-Recording-Relation-Id'] || request.cookies['Latta-Recording-Relation-Id']
      relation_id = nil
      if !related_to_id
        relation_id = config.relation_id
      end 

      response = HTTParty.put(url,body:{
         message:'',
         relation_id:relation_id,
         related_to_relation_id: related_to_id

      }.to_json, headers: {
          "Content-Type" => "application/json",
            "Authorization" => "Bearer #{api_key}"
        })

      snapshot_id = nil

      if response.success?
        JSON.parse(response.body)["id"]
      else
        raise "Failed to fetch ID from API: #{response.code} - #{response.body}"
      end
    end


    def put_snapshost_attachment(snapshot_id, request, exception, console_output)
      config =Latta.configuration
      api_key = config.api_key
      url = "#{LattaProperties::LATTA_API_URI}/#{LattaEndpoints::put_snapshot_attachment(snapshot_id)}"
      headers = {}
      request.headers.each do |key, value|
       stringified = case value
                   when String
                     value
                   when Array
                     value.map(&:to_s).to_s
                   else
                     value.to_s
                   end
        headers[key] = stringified
      end

      response = HTTParty.put(url,body:{
            type: "record",
            data: {
                type:"request",
                timestamp: Time.now.to_i,
                level: LattaRecordLevels::LATTA_ERROR,
                request: {
                    method: request.method,
                    url: "#{request.protocol}#{request.host_with_port}#{request.path}",
                    route: request.path,
                    query: request.query_parameters,
                    body: request.raw_post,
                    headers:headers
                },
                response: {
                    status_code: 500,
                    body: "",
                    headers: {} 
                },
                name: exception.class.name,
                message: exception.message,
                stack: exception.backtrace.join("\n"),
                environment_variables: safe_serialize_environ(),
                system_info: get_system_info(),
                logs: {
                    entries: []
                }
            }
        }.to_json, headers: {
          "Content-Type" => "application/json",
            "Authorization" => "Bearer #{api_key}"
        })

      if response.success?
        JSON.parse(response.body)
      else
        raise "Failed to fetch ID from API: #{response.code} - #{response.body}"
      end
      

    end


    def safe_serialize_environ
      safe_environ = {}
      
      ENV.each do |key, value|
        begin
          JSON.generate({ key => value })
          safe_environ[key] = value
        rescue JSON::GeneratorError
          safe_environ[key] = value.to_s
        end
      end
      
      safe_environ
    end

    def get_system_info
      cpu_usage = Sys::CPU.load_avg[0] * 100 

      {
        cpu_usage: cpu_usage.round(2),
        total_memory: Sys::Memory.total,
        free_memory: Sys::Memory.free
      }
    end
   
    def response_body(response)
      body = ''
      response.each { |part| body << part }
      body
    end

    def send_to_api(request, status, body, exception, console_output)
     snapshot_id = put_snapshot(request)
     put_snapshost_attachment(snapshot_id, request, exception, console_output)

    rescue => e
      Rails.logger.error "Failed to send exception details to API: #{e.message}"
    end
  end
end