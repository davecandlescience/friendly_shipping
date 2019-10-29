# frozen_string_literal: true

module FriendlyShipping
  module Services
    class Usps
      class ParseXMLResponse
        extend Dry::Monads::Result::Mixin
        ERROR_TAG = 'Error'

        class << self
          def call(response_body, expected_root_tag)
            xml = Nokogiri.XML(response_body, &:strict)

            if xml.root.nil? || ![expected_root_tag, 'Error'].include?(xml.root.name)
              Failure('Invalid document')
            elsif request_successful?(xml)
              Success(xml)
            else
              Failure(error_message(xml))
            end
          rescue Nokogiri::XML::SyntaxError => e
            Failure(e)
          end

          private

          def request_successful?(xml)
            xml.xpath('//Error/Number')&.text.blank?
          end

          def error_message(xml)
            number = xml.xpath('//Error/Number')&.text
            desc = xml.xpath('//Error/Description')&.text
            [number, desc].select(&:present?).join(': ').presence&.strip || 'USPS could not process the request.'
          end
        end
      end
    end
  end
end
