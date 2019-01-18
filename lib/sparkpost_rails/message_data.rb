module SparkPostRails
  module MessageData

    def self.included(base)
      base.class_eval do
        attr_writer :sparkpost_data

        def sparkpost_data
          @sparkpost_data ||= {}
        end
      end
    end

  end
end
