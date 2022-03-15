# frozen_string_literal: true

require 'spec_helper'

describe 'nfs::install' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      describe 'with defaults' do
        it { is_expected.to compile }
        it { is_expected.to have_package_resource_count(0) }
      end

      describe 'with client' do
        let(:params) do
          {
            'client' => true,
            'client_packages' => ['a', 'b', 'b']
          }
        end

        it { is_expected.to compile }
        it { is_expected.to have_package_resource_count(2) }
        it { is_expected.to contain_package('a').with_ensure('present') }
        it { is_expected.to contain_package('b').with_ensure('present') }
      end

      describe 'with client, but not packages' do
        let(:params) do
          {
            'client' => true,
            'manage_client_packages' => false,
          }
        end

        it { is_expected.to compile }
        it { is_expected.to have_package_resource_count(0) }
      end

      describe 'with server, but not packages' do
        let(:params) do
          {
            'server' => true,
            'manage_server_packages' => false,
          }
        end

        it { is_expected.to compile }
        it { is_expected.to have_package_resource_count(0) }
      end

      describe 'with server' do
        let(:params) do
          {
            'server' => true,
            'server_packages' => ['a', 'b', 'b'],
          }
        end

        it { is_expected.to compile }
        it { is_expected.to have_package_resource_count(2) }
        it { is_expected.to contain_package('a').with_ensure('present') }
        it { is_expected.to contain_package('b').with_ensure('present') }
      end

      describe 'with client and server' do
        let(:params) do
          {
            'client' => true,
            'client_packages' => ['a', 'b', 'b'],
            'server' => true,
            'server_packages' => ['a', 'b', 'c'],
          }
        end

        it { is_expected.to compile }
        it { is_expected.to have_package_resource_count(3) }
        it { is_expected.to contain_package('a').with_ensure('present') }
        it { is_expected.to contain_package('b').with_ensure('present') }
        it { is_expected.to contain_package('c').with_ensure('present') }
      end
    end
  end
end
