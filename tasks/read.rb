#!/opt/puppetlabs/puppet/bin/ruby

require "base64"
require "json"

require "net/http"
require "openssl"

require_relative "../../ruby_task_helper/files/task_helper.rb"

# Return an error
def return_error(message)
  result = {}
  result[:_error] = {
    msg: message,
    kind: "snow_record.read",
    details: {},
  }
  #puts result.to_json
  raise TaskHelper::Error.new("Failure!", "snow_record.read", result)
end

class SnowRead < TaskHelper
  def task(table: "incident",
           lookup_field: "number",
           data: nil,
           number: nil,
           _target: nil,
           **kwargs)
    user = _target[:user]
    password = _target[:password]
    instance = _target[:name]

    # if number is nil then return all results
    unless number.nil?
      qp = "#{lookup_field}=#{number}"
    end

    uri = URI.parse("https://#{instance}.service-now.com/api/now/table/#{table}")

    Net::HTTP.start(uri.host, uri.port,
                    :use_ssl => uri.scheme == "https",
                    :verify_mode => OpenSSL::SSL::VERIFY_NONE) do |http|
      request = Net::HTTP::Get.new("#{uri.path}?#{qp}", initheader = { "Content-Type" => "application/json" })
      request.basic_auth(user, password)
      response = http.request(request)
      pretty_str = JSON.pretty_unparse(JSON.parse(response.body))
      res = [pretty_str]
      puts res
    end
  rescue StandardError => e
    puts e.backtrace
    return_error(e.message, e.backtrace)
  end
end

SnowRead.run if __FILE__ == $0
