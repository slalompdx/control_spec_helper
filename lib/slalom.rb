require 'net/ssh'
require 'etc'

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

# Helper method to separate ssh output into streams and error code
# Sample use:
# Net::SSH.start(server, Etc.getlogin) do |ssh|
#  puts ssh_exec!(ssh, "true").inspect
#  # => ["", "", 0, nil]

#  puts ssh_exec!(ssh, "false").inspect
#  # => ["", "", 1, nil]
# end

def ssh_exec!(ssh, command, debug=false)
  stdout_data = ""
  stderr_data = ""
  exit_code = nil
  exit_signal = nil
  ssh.open_channel do |channel|
    channel.exec(command) do |ch, success|
      unless success
        abort "FAILED: couldn't execute command (ssh.channel.exec)"
      end
      channel.on_data do |ch,data|
        stdout_data+=data
        puts stdout_data
      end

      channel.on_extended_data do |ch,type,data|
        stderr_data+=data
        puts stderr_data
      end

      channel.on_request("exit-status") do |ch,data|
        exit_code = data.read_long
      end

      channel.on_request("exit-signal") do |ch, data|
        exit_signal = data.read_long
      end
    end
  end
  ssh.loop
  [stdout_data, stderr_data, exit_code, exit_signal]
end
