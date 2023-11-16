# frozen_string_literal: true

require 'spec_helper'

describe 'nfs::config::nfsmount_conf' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      context 'when using defaults' do
        it { is_expected.to compile }
        it { is_expected.to have_file_resource_count(2) }
        it {
          is_expected.to contain_file('/etc/nfsmount.conf')
            .with_ensure('file')
            .with_owner('root')
            .with_group('root')
            .with_mode('0644')
            .with_content(%r{^\[ NFSMount_Global_Options \]$})
            .with_content(%r{^Defaultvers=4$})
            .without_content(%r{^\[ Server})
            .without_content(%r{^\[ MountPoint})
        }
        it {
          is_expected.to contain_file('/etc/nfsmount.conf.d')
            .with_ensure('directory')
            .with_owner('root')
            .with_group('root')
            .with_mode('0755')
            .with_recurse(true)
            .with_purge(true)
        }
      end

      context 'with params' do
        let(:params) do
          {
            'nfsmount_conf_hash' => { 'NFSMount_Global_Options': { 'Proto': 'tcp' }, 'hostname.example.com': { 'Defaultvers': 4 }, '/mnt/place': { 'Sloppy': false } },
            'purge_unmanaged_nfsmount_conf_d' => false,
          }
        end

        it { is_expected.to compile }
        it { is_expected.to have_file_resource_count(2) }
        it {
          is_expected.to contain_file('/etc/nfsmount.conf')
            .with_ensure('file')
            .with_owner('root')
            .with_group('root')
            .with_mode('0644')
            .with_content(%r{^\[ NFSMount_Global_Options \]$})
            .with_content(%r{^Defaultvers=4$})
            .with_content(%r{^Proto=tcp$})
            .with_content(%r{^\[ Server "hostname.example.com" \]$})
            .with_content(%r{^Defaultvers=4$})
            .with_content(%r{^\[ MountPoint "/mnt/place" \]$})
            .with_content(%r{^Sloppy=false$})
        }
        it {
          is_expected.to contain_file('/etc/nfsmount.conf.d')
            .with_ensure('directory')
            .with_owner('root')
            .with_group('root')
            .with_mode('0755')
            .with_recurse(false)
            .with_purge(false)
        }
      end
    end
  end
end
