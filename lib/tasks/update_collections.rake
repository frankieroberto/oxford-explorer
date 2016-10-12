require 'open-uri'
require 'csv'

namespace :update do

  desc 'Update Collections from the Google Spreadsheet'
  task collections: :environment do

    source_file = open(ENV.fetch('COLLECTIONS_CSV_URL')).read

    collections_csv_file = File.open("#{File.dirname(__FILE__)}/../../db/collections.csv", "wb")

    collections_csv_file.write source_file
    collections_csv_file.close

  end


end
