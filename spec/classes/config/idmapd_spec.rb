# frozen_string_literal: true

require 'spec_helper'

describe 'nfs::config::idmapd' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      context 'when using defaults' do
        it { is_expected.to compile }
        it {
          is_expected.to contain_file('/etc/idmapd.conf')
            .with_ensure('present')
            .with_owner('root')
            .with_group('root')
            .with_mode('0644')
            .with_content(%r{^\[General\]$})
            .with_content(%r{^Domain=example.com$})
            .with_content(%r{^\[Mapping\]$})
            .with_content(%r{^Nobody-User=nobody$})
        }
      end

      context 'with params' do
        let(:params) do
          {
            'idmapd_config_hash' => { 'General': { 'Domain': 'exists' }, 'Mapping': { 'Nobody-User': 'user', 'Nobody-Group': 'group' }, 'Translation': { 'Method': 'static' } }
          }
        end

        it { is_expected.to compile }
        it {
          is_expected.to contain_file('/etc/idmapd.conf')
            .with_ensure('present')
            .with_owner('root')
            .with_group('root')
            .with_mode('0644')
            .with_content(%r{^\[General\]$})
            .without_content(%r{^Domain=example.com$})
            .with_content(%r{^Domain=exists$})
            .with_content(%r{^\[Mapping\]$})
            .with_content(%r{^Nobody-User=user$})
            .with_content(%r{^Nobody-Group=group$})
            .with_content(%r{^\[Translation\]$})
            .with_content(%r{^Method=static$})
        }
      end
    end
  end
end
