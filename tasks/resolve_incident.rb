#!/opt/puppetlabs/puppet/bin/ruby

require 'base64'
require 'json'

require 'net/http'
require 'openssl'

require_relative '../../ruby_task_helper/files/task_helper.rb'

# This task updates objects
class SnowResolveIncident < TaskHelper
  def task(table: 'incident',
           sys_id: nil,
           additional_data: {},
           close_notes: nil,
           _target: nil,
           **_kwargs)
    user = _target[:user]
    password = _target[:password]
    instance = _target[:name]

    uri = URI.parse("https://#{instance}.service-now.com/api/now/table/#{table}/#{sys_id}")

    begin
      Net::HTTP.start(uri.host, uri.port,
                      use_ssl: uri.scheme == 'https',
                      verify_mode: OpenSSL::SSL::VERIFY_NONE) do |http|
        header = { 'Content-Type' => 'application/json' }
        request = Net::HTTP::Patch.new("#{uri.path}?#{uri.query}", header)

        data = {}

        parsed = JSON.parse(additional_data)
        parsed.each do |key, val|
          data[key] = val
        end
        data.store('close_notes', close_notes)
        data.store('sys_id', sys_id)
        data.store('state', '6')
        data.store('incident_state', '6')

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
      raise TaskHelper::Error.new('Failure!', 'snow_record.create', e)
    end
  end
end

if $PROGRAM_NAME == __FILE__
  SnowResolveIncident.run
end
