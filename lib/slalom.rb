def vagrant_ssh_config
  config = {}
  `vagrant ssh-config --machine-readable`.split(',')[7]
    .split('\n')[0..9].collect(&:lstrip)
    .each do |element|
      key, value = element.split(' ')
      config[key] = value
    end
  config
end
