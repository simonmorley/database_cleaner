module DatabaseCleaner
  module Mongo2
    module TruncationMixin

      def clean
        if @only
          collections.each { |c| database[c].find.delete_many if @only.include?(c) }
        else
          collections.each { |c| database[c].find.delete_many unless @tables_to_exclude.include?(c) }
        end
        true
      end

      private

      def database
        if @db.nil? || @db == :default
          ::Mongoid::Clients.default
        else
          ::Mongoid::Clients.with_name(@db)
        end
      end

      def collections
        if db != :default
          database.use(db)
        end

        def session
          ::Mongoid.default_client
        end

        session.command(listCollections: 1).first[:cursor][:firstBatch].map do |collection|
          collection[:name]
        end

      end

    end
  end
end
