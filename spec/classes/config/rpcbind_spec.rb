# frozen_string_literal: true

require 'spec_helper'

describe 'nfs::config::rpcbind' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      context 'when using defaults' do
        it { is_expected.to compile }
        it { is_expected.to have_file_resource_count(1) }
        if os_facts[:os]['family'] == 'Debian'
          it { is_expected.to contain_file('/etc/default/rpcbind') }
        else
          it { is_expected.to contain_file('/etc/sysconfig/rpcbind') }
        end
      end

      context 'with params' do
        let(:params) do
          {
            'rpcbind_config_opt_file' => '/file/path',
            'rpcbind_config_opt_key' => 'THING',
            'rpcbind_config_opt_values' => ['-c', '-a', '-b']
          }
        end

        it { is_expected.to compile }
        it {
          is_expected.to contain_file('/file/path')
            .with_ensure('file')
            .with_owner('root')
            .with_group('root')
            .with_mode('0644')
            .with_content(%r{THING="-a -b -c"$})
        }
      end
    end
  end
end
