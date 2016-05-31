require 'net/ssh'
require 'etc'

def debug(msg)
  $stderr.puts "DEBUG: #{msg}" unless ENV['debug'].nil?
end

def vagrant_ssh_config
  config = {}
  `unset RUBYLIB ; vagrant ssh-config --machine-readable`.split(',')[7]
    .split('\n')[0..9].collect(&:lstrip)
    .each do |element|
      key, value = element.split(' ')
      config[key] = value
    end
  config
end

def build_vagrant_connection(config)
  Net::SSH.start(
    config['HostName'],
    config['User'],
    port: config['Port'],
    password: 'vagrant'
  )
end

# Helper method to separate ssh output into streams and error code
# Sample use:
# Net::SSH.start(server, Etc.getlogin) do |ssh|
#  puts ssh_exec!(ssh, "true").inspect
#  # => ["", "", 0, nil]

#  puts ssh_exec!(ssh, "false").inspect
#  # => ["", "", 1, nil]
# end

# rubocop:disable Metrics/AbcSize
# rubocop:disable Metrics/MethodLength
def ssh_exec!(ssh, command)
  stdout_data = ''
  stderr_data = ''
  exit_code = nil
  exit_signal = nil
  ssh.open_channel do |channel|
    channel.exec(command) do |_ch, success|
      unless success
        abort 'FAILED: couldn\'t execute command (ssh.channel.exec)'
      end
      channel.on_data do |_ch, data|
        stdout_data += data
        puts stdout_data
      end

      channel.on_extended_data do |_ch, _type, data|
        stderr_data += data
        puts stderr_data
      end

      channel.on_request('exit-status') do |_ch, data|
        exit_code = data.read_long
      end

      channel.on_request('exit-signal') do |_ch, data|
        exit_signal = data.read_long
      end
    end
  end
  ssh.loop
  [stdout_data, stderr_data, exit_code, exit_signal]
end
# rubocop:enable Metrics/MethodLength
# rubocop:enable Metrics/AbcSize
