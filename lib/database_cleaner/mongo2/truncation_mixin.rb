module DatabaseCleaner
  module Mongo2
    module TruncationMixin

      def clean
        if @only
          collections.each { |c| database[c].find.delete_many if @only.include?(c) }
        else
          collections.each { |c| database[c].find.delete_many unless (@tables_to_exclude.include?(c) || c == 'system' )}
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

      def session
        ::Mongoid.default_client
      end

      def version
        @version ||= session.command('buildinfo' => 1).first[:version]
      end

      def collections
        if db != :default
          database.use(db)
        end

        if version.split('.').first.to_i >= 3
          session.command(listCollections: 1, :name => { '$not' => /\.system\.|\$/ }).first[:cursor][:firstBatch].map do |collection|
            collection[:name]
          end
        else
          session['system.namespaces'].find(name: { '$not' => /\.system\.|\$/ }).to_a.map do |collection|
            _, name = collection['name'].split('.', 2)
            name
          end
        end

      end

    end
  end
end
