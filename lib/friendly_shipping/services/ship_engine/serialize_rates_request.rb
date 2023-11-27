# frozen_string_literal: true

module FriendlyShipping
  module Services
    class ShipEngine
      class SerializeRatesRequest
        class << self
          def call(shipment:, options:)
            rates_hash = {
              shipment: {
                carrier_ids: options.carrier_ids,
                service_code: options.service_code,
                ship_to: serialize_address(shipment.destination),
                ship_from: serialize_address(shipment.origin),
                items: serialize_items(shipment.packages.first),
                packages: serialize_packages(shipment, options),
                confirmation: 'none',
                address_residential_indicator: shipment.destination.residential? ? "yes" : "no"
              },
              rate_options: {
                carrier_ids: options.carrier_ids,
                service_codes: [options.service_code],
              }
            }

            if international?(shipment)
              rates_hash[:shipment][:customs] = {
                contents: "merchandise",
                non_delivery: "return_to_sender",
              }
            end

            rates_hash
          end

          private

          def serialize_items(package)
            package.items.map do |item|
              {
                name: item.description,
              }
            end
          end

          def serialize_address(address)
            {
              name: address.name,
              phone: address.phone,
              company_name: address.company_name,
              address_line1: address.address1,
              address_line2: address.address2,
              city_locality: address.city,
              state_province: address.region.code,
              postal_code: address.zip,
              country_code: address.country.code,
              address_residential_indicator: "No"
            }
          end

          def serialize_packages(shipment, options)
            shipment.packages.map do |package|
              {
                weight: {
                  value: package.weight.convert_to(:pound).value.to_f,
                  unit: 'pound'
                },
                dimensions: {
                  unit: 'inch',
                  length: package.length.convert_to(:inch).value.to_f,
                  width: package.width.convert_to(:inch).value.to_f,
                  height: package.height.convert_to(:inch).value.to_f
                },
                products: serialize_products(package, options),
              }
            end
          end

          def serialize_products(package, options)
            package.items.group_by(&:sku).map do |sku, items|
              reference_item = items.first
              package_options = options.options_for_package(package)
              item_options = package_options.options_for_item(reference_item)
              {
                sku: sku,
                description: reference_item.description,
                quantity: items.count,
                value: {
                  amount: reference_item.cost.to_d,
                  currency: reference_item.cost.currency.to_s
                },
                harmonized_tariff_code: item_options.commodity_code,
                country_of_origin: item_options.country_of_origin
              }
            end
          end

          def international?(shipment)
            shipment.origin.country != shipment.destination.country
          end
        end
      end
    end
  end
end
