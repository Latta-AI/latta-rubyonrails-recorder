require 'securerandom'
require 'httparty'
require 'sys/uname'
require 'iso-639'


module Latta
  class Configuration
    attr_accessor :api_key, :relation_id, :instance_id

    def initialize
      @api_key = nil
      @relation_id = SecureRandom.uuid
      @instance_id = nil
    end

    def fetch_instance_id
      raise "API key must be set before fetching ID" if @api_key.nil?
      url = "#{LattaProperties::LATTA_API_URI}/#{LattaEndpoints::LATTA_PUT_INSTANCE}"
      uname = Sys::Uname.uname

      locale = I18n.locale.to_s
      locale = locale.split('-').first if locale.include?('-')
      language = ISO_639.find(locale)
      lang = 'en'

      if language
        lang = language.alpha2
      end


      response = HTTParty.put(url,body:{
          framework: "rails",
            framework_version: Rails.version,
            device: 'server',
            lang: lang,
            os: uname.sysname, 
            os_version: uname.release
      }.to_json, headers: {
          "Content-Type" => "application/json",
            "Authorization" => "Bearer #{@api_key}"
        })

      if response.success?
        @instance_id = JSON.parse(response.body)["id"]
      else
        raise "Failed to fetch ID from API: #{response.code} - #{response.body}"
      end
    rescue => e
      Rails.logger.error "Error fetching API provided ID: #{e.message}"
      raise
    end
  end

  class << self
    attr_writer :configuration
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.configure
    yield(configuration)
    configuration.fetch_instance_id
  end
end