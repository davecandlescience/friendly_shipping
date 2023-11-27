# frozen_string_literal: true

# This is necessary for classes with acronyms to autoload in Rails
if Object.const_defined?('ActiveSupport::Inflector')
  ActiveSupport::Inflector.inflections(:en) do |inflect|
    inflect.acronym 'BOL'
    inflect.acronym 'RL'
  end
end
