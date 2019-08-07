#!/opt/puppetlabs/puppet/bin/ruby

require 'base64'
require 'json'

require 'net/http'
require 'openssl'

require_relative '../../ruby_task_helper/files/task_helper.rb'

# Return an error
def return_error(message)
  result = {}
  result[:_error] = {
    msg: message,
    kind: 'snow_record.read',
    details: {},
  }
  # puts result.to_json
  raise TaskHelper::Error.new('Failure!', 'snow_record.read', result)
end

# This task reads incidents
class SnowRead < TaskHelper
  def task(table: 'incident',
           lookup_field: 'number',
           number: nil,
           _target: nil,
           **_kwargs)
    user = _target[:user]
    password = _target[:password]
    instance = _target[:name]

    # if number is nil then return all results
    unless number.nil?
      qp = "#{lookup_field}=#{number}"
    end

    uri = URI.parse("https://#{instance}.service-now.com/api/now/table/#{table}")

    Net::HTTP.start(uri.host, uri.port,
                    use_ssl: uri.scheme == 'https',
                    verify_mode: OpenSSL::SSL::VERIFY_NONE) do |http|
      header = { 'Content-Type' => 'application/json' }
      request = Net::HTTP::Get.new("#{uri.path}?#{qp}", header)
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

SnowRead.run if $PROGRAM_NAME == __FILE__
