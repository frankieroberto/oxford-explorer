require 'open-uri'
require 'csv'

namespace :update do

  desc 'Update Institutions from the Google Spreadsheet'
  task institutions: :environment do

    source_file = open(ENV.fetch('INSTITUTIONS_CSV_URL')).read

    institutions_csv_file = File.open("#{File.dirname(__FILE__)}/../../db/institutions.csv", "wb")

    institutions_csv_file.write source_file
    institutions_csv_file.close

  end


end
