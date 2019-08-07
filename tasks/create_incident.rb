#!/opt/puppetlabs/puppet/bin/ruby

require "base64"
require "json"

require "net/http"
require "openssl"

require_relative "../../ruby_task_helper/files/task_helper.rb"

class SnowCreateIncident < TaskHelper
  def task(table: "incident",
           state: "present",
           urgency: nil,
           priority: nil,
           severity: nil,
           additional_data: {},
           _target: nil,
           **kwargs)
    user = _target[:user]
    password = _target[:password]
    instance = _target[:name]

    uri = URI.parse("https://#{instance}.service-now.com/api/now/table/incident")

    begin
      Net::HTTP.start(uri.host, uri.port,
                      :use_ssl => uri.scheme == "https",
                      :verify_mode => OpenSSL::SSL::VERIFY_NONE) do |http|
        header = { 'Content-Type': "application/json" }
        request = Net::HTTP::Post.new("#{uri.path}?#{uri.query.to_s}", header)

        data = Hash.new

        parsed = JSON.parse(additional_data)
        parsed.each do |key, val|
          data[key] = val
        end

        unless urgency.nil?
          data.store("urgency", urgency)
        end

        unless severity.nil?
          data.store("severity", severity)
        end

        unless priority.nil?
          data.store("priority", priority)
        end

        request.body = data.to_json
        request.basic_auth(user, password)
        response = http.request(request)
        datum = response.body
        obj = JSON.parse(datum)
        pretty_str = JSON.pretty_unparse(obj)
        res = [pretty_str]
        puts res
      end
    rescue => e
      puts "ERROR: #{e}"
      raise TaskHelper::Error.new("Failure!", "snow_record.create_incident", e)
    end
  end
end

if __FILE__ == $0
  SnowCreateIncident.run
end
