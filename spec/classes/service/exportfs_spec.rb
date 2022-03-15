# frozen_string_literal: true

require 'spec_helper'

describe 'nfs::service::exportfs' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      context 'when using defaults' do
        it { is_expected.to compile }
        it {
          is_expected.to contain_exec('Refresh NFS Exports')
            .with_refreshonly(true)
            .with_command('/usr/sbin/exportfs -a -r -v')
        }
      end

      context 'when defining weird stuff' do
        let(:params) do
          {
            'exportfs' => '/bin/true',
            'exportfs_arguments' => ['-a', '-lll', '-b'],
          }
        end

        it { is_expected.to compile }
        it {
          is_expected.to contain_exec('Refresh NFS Exports')
            .with_refreshonly(true)
            .with_command('/bin/true -a -lll -b')
        }
      end
    end
  end
end
