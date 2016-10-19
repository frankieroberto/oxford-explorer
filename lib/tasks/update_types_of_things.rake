require 'open-uri'
require 'csv'

namespace :update do

  desc 'Update Types of Things from the Google Spreadsheet'
  task types_of_things: :environment do

    source_file = open(ENV.fetch('TYPE_OF_THINGS_CSV_URL')).read

    types_of_things_csv_file = File.open("#{File.dirname(__FILE__)}/../../db/types_of_things.csv", "wb")

    types_of_things_csv_file.write source_file
    types_of_things_csv_file.close

  end


end
