require_relative '../../../spec_helper'

describe Puppet::Type.type(:collector_installer).provider(:collector_installer) do
  let :resource do
    Puppet::Type.type(:collector_installer).new(
      {
        :ensure      => :present,
        :description => 'UnitTestCollector',
        :install_dir => '/usr/local/logicmonitor/',
        :architecture => 'x86_64',
        :account     => 'lmsdacanay',
        :user        => 'puppetadmin',
        :password    => 'marionette',
      }
    )
  end

  let :provider do
    resource.provider
  end

  let :collector_api_resource do
    Puppet::Type.type(:collector).new(
      {
        :ensure      => :present,
        :description => 'UnitTestCollector',
        :osfam       => 'RedHat',
        :account     => 'lmsdacanay',
        :user        => 'puppetadmin',
        :password    => 'marionette',
      }
    )
  end

  let :collector_api_provider do
    collector_api_resource.provider
  end

  # describe 'exists?' do
  #   it 'checks if a collector exists in LogicMonitor, and that the installation binary exists' do
  #     collector_api_provider.create
  #     expect(provider.exists?).to be_falsey
  #   end
  # end
  #
  # describe 'create' do
  #   it 'downloads and installs a LogicMonitor collector binary' do
  #     expect(provider.create).to_not raise_error
  #   end
  # end
  #
  # describe 'destroy' do
  #   it 'removes the LogicMonitor collector binary' do
  #     expect(provider.destroy).to_not raise_error
  #     collector_api_provider.destroy
  #   end
  # end
end