# frozen_string_literal: true

require 'friendly_shipping/shipment_options'

module FriendlyShipping
  module Services
    class ShipEngine
      # Options for generating rates for a shipment
      #
      # @attribute carriers [Array<FriendlyShipping::Carrier>] a list of the carriers we want to get IDs from.
      # @attribute service_code [String] The service code we want to get rates for.
      class RatesOptions < FriendlyShipping::ShipmentOptions
        attr_reader :carriers, :service_code

        def initialize(carriers:, service_code:, **kwargs)
          @carriers = carriers
          @service_code = service_code
          super(**kwargs.merge(package_options_class: RatesPackageOptions))
        end

        def carrier_ids
          carriers.map(&:id)
        end
      end
    end
  end
end
