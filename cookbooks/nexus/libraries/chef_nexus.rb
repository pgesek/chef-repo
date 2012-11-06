#
# Cookbook Name:: nexus
# Library:: chef_nexus
#
# Author:: Kyle Allan (<kallan@riotgames.com>)
# Copyright 2012, Riot Games
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
#
class Chef
  module Nexus
    DATABAG = "nexus"
    CREDENTIALS_DATABAG_ITEM = "credentials"
    LICENSE_DATABAG_ITEM = "license"
    CERTIFICATES_DATABAG_ITEM = "certificates"
    SSL_CERTIFICATE_DATABAG_ITEM = "ssl_certificate"
    PROXY_REPOSITORIES_DATABAG_ITEM = "proxy_repositories"
    HOSTED_REPOSITORIES_DATABAG_ITEM = "hosted_repositories"
    GROUP_REPOSITORIES_DATABAG_ITEM = "group_repositories"
    SSL_CERTIFICATE_CRT = "crt"
    SSL_CERTIFICATE_KEY = "key"
    
    class << self
      def get_proxy_repositories_data_bag
        Chef::DataBagItem.load(DATABAG, PROXY_REPOSITORIES_DATABAG_ITEM)
      end

      def get_hosted_repositories_data_bag
        Chef::DataBagItem.load(DATABAG, HOSTED_REPOSITORIES_DATABAG_ITEM)
      end

      def get_group_repositories_data_bag
        Chef::DataBagItem.load(DATABAG, GROUP_REPOSITORIES_DATABAG_ITEM)
      end

      def get_ssl_certificate_data_bag
        begin
          data_bag_item = Chef::EncryptedDataBagItem.load(DATABAG, SSL_CERTIFICATE_DATABAG_ITEM)
        rescue Net::HTTPServerException => e
          raise Nexus::EncryptedDataBagNotFound.new(CREDENTIALS_DATABAG_ITEM)
        end
        data_bag_item
      end

      def get_ssl_certificate_crt(data_bag_item)
        require 'base64'
        Base64.decode64(data_bag_item[SSL_CERTIFICATE_CRT])
      end

      def get_ssl_certificate_key(data_bag_item)
        require 'base64'
        Base64.decode64(data_bag_item[SSL_CERTIFICATE_KEY])
      end

      def get_credentials_data_bag
        begin
          data_bag_item = Chef::EncryptedDataBagItem.load(DATABAG, CREDENTIALS_DATABAG_ITEM)
        rescue Net::HTTPServerException => e
          raise Nexus::EncryptedDataBagNotFound.new(CREDENTIALS_DATABAG_ITEM)
        end
        validate_credentials_data_bag(data_bag_item)
        data_bag_item
      end

      def get_license_data_bag
        begin
          data_bag_item = Chef::EncryptedDataBagItem.load(DATABAG, LICENSE_DATABAG_ITEM)
        rescue Net::HTTPServerException => e
          raise Nexus::EncryptedDataBagNotFound.new(LICENSE_DATABAG_ITEM)
        end
        validate_license_data_bag(data_bag_item)
        data_bag_item
      end

      def get_certificates_data_bag(node)
        begin
          data_bag_item = Chef::EncryptedDataBagItem.load(DATABAG, CERTIFICATES_DATABAG_ITEM)
        rescue Net::HTTPServerException => e
          raise Nexus::EncryptedDataBagNotFound.new(CERTIFICATES_DATABAG_ITEM)
        end
        validate_certificates_data_bag(data_bag_item, node)
        data_bag_item
      end

      def nexus(node)
        require 'nexus_cli'
        data_bag_item = get_credentials_data_bag
        default_credentials = data_bag_item["default_admin"]
        updated_credentials = data_bag_item["updated_admin"]
        overrides = {"url" => node[:nexus][:cli][:url], "repository" => node[:nexus][:cli][:repository]}
        begin
          merged_credentials = overrides.merge(default_credentials)
          NexusCli::Factory.create(merged_credentials, node[:nexus][:ssl][:verify])
        rescue NexusCli::PermissionsException, NexusCli::CouldNotConnectToNexusException, NexusCli::UnexpectedStatusCodeException => e
          merged_credentials = overrides.merge(updated_credentials)
          NexusCli::Factory.create(merged_credentials, node[:nexus][:ssl][:verify])
        end
      end

      def check_old_credentials(username, password, node)
        require 'nexus_cli'
        overrides = {"url" => node[:nexus][:cli][:url], "repository" => node[:nexus][:cli][:repository], "username" => username, "password" => password}
        begin
          nexus = NexusCli::Factory.create(overrides, node[:nexus][:ssl][:verify])
          true
        rescue NexusCli::PermissionsException, NexusCli::CouldNotConnectToNexusException, NexusCli::UnexpectedStatusCodeException => e
          false
        end
      end

      def decode(value)
        require 'base64'
        Base64.decode64(value)
      end

      private

        def validate_credentials_data_bag(data_bag_item)
          raise Nexus::InvalidDataBagItem.new(CREDENTIALS_DATABAG_ITEM, "default_admin") unless data_bag_item["default_admin"]
          raise Nexus::InvalidDataBagItem.new(CREDENTIALS_DATABAG_ITEM, "updated_admin") unless data_bag_item["updated_admin"]
        end

        def validate_license_data_bag(data_bag_item)
          raise Nexus::InvalidDataBagItem.new(LICENSE_DATABAG_ITEM, "file") unless data_bag_item["file"]
        end

        def validate_certificates_data_bag(data_bag_item, node)
          data_bag_item.to_hash.each do |key, value|
            unless key == "id"
              raise Nexus::InvalidDataBagItem.new(CERTIFICATES_DATABAG_ITEM, "#{value}::certificate") unless value["certificate"]
              raise Nexus::InvalidDataBagItem.new(CERTIFICATES_DATABAG_ITEM, "#{value}::description") unless value["description"]
            end
          end
        end
    end
  end
end