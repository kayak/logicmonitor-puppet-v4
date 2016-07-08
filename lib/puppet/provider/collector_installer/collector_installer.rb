# collector_installer.rb
# === Authors
#
# Sam Dacanay <sam.dacanay@logicmonitor.com>
# Ethan Culler-Mayeno <ethan.culler-mayeno@logicmonitor.com>
#
# === Copyright
#
# Copyright 2016 LogicMonitor, Inc
#

require 'json'

Puppet::Type.type(:collector_installer).provide(:collector_installer) do
  desc 'This provider handles the download and installation of a collector'

  def create
    debug 'Downloading new collector installer'
    collector = rest('setting/collectors',
                      HTTP_GET,
                      build_query_params("description:#{resource[:description]}", 'id'), 1)
    if valid_api_response?(collector, true)
      debug collector
      if resource[:architecture].include?('64')
        installation_binary = "#{resource[:install_dir]}logicmonitorsetup#{id}_64.bin"
        arch = 64
      else
        installation_binary = "#{resource[:install_dir]}logicmonitorsetup#{id}_32.bin"
        arch = 32
      end
      File.open(installation_binary, 'w+') do |file|
        download_query_params = {'id' => collector['id'], 'arch' => arch.to_s}
        file.write(rest('', HTTP_GET, download_query_params))
      end
      debug 'Installing Collector'
      File.chmod(0755, installation_binary)
      execution = `#{installation_binary} -y`
      debug execution.to_s
    else
      alert collector
    end
  end

  def destroy
    debug 'Uninstalling LogicMonitor collector'
    collector = rest('setting/collectors',
                     HTTP_GET,
                     build_query_params("description:#{resource[:description]}", 'id'), 1)
    if valid_api_response?(collector, true)
      # Collector shutdown process
      `#{resource[:install_dir]}agent/bin/sbshutdown`
      `#{resource[:install_dir]}agent/bin/uninstall.pl`

      if resource[:architecture].include?('64')
        installation_binary = "#{resource[:install_dir]}logicmonitorsetup#{id}_64.bin"
      else
        installation_binary = "#{resource[:install_dir]}logicmonitorsetup#{id}_32.bin"
      end
      File.delete installation_binary
    else
      alert collector
    end
  end

  # TODO: should probably do a service running check here?
  def exists?
    collector = rest('setting/collectors',
                     HTTP_GET,
                     build_query_params("description:#{resource[:description]}", 'id'), 1)
    if valid_api_response?(collector, true)
      if resource[:architecture].include?('64')
        installation_binary = "#{resource[:install_dir]}logicmonitorsetup#{id}_64.bin"
      else
        installation_binary = "#{resource[:install_dir]}logicmonitorsetup#{id}_32.bin"
      end
      return File.exists?(installation_binary)
    else
      alert collector
      return false
    end
  end
end
