require 'active_record'

module Associates
  module Persistence
    extend ActiveSupport::Concern

    included do
    end

    module ClassMethods
    end

    # Persists each associated model
    #
    # @return [Boolean] Wether or not all models are valid and persited
    def save(*args)
      return false unless valid?

      ActiveRecord::Base.transaction do
        begin
          associates.all? do |associate|

            # Assign associate dependent(s) attribute
            associate.dependent_names.each do |dependent_name|
              depending_value = send(dependent_name)
              send(associate.name).send("#{dependent_name}=", depending_value)
            end

            send(associate.name).send(:save!, *args)
          end
        rescue ActiveRecord::RecordInvalid
          false
        end
      end
    end

    # @return [True, ActiveRecord::RecordInvalid]
    def save!
      save || raise(ActiveRecord::RecordInvalid)
    end
  end
end
