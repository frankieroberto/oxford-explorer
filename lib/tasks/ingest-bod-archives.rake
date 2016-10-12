

namespace :ingest do

  desc 'Ingest BOD-archives'
  task bod_archives: :environment do


    s3_client = Aws::S3::Client.new(region: 'eu-west-1')
    bucket =  Aws::S3::Bucket.new('gfs-oxford-collections', s3_client)

    bucket.objects(prefix: 'raw/bod-archives/bod-archives-1500-1900').each do |object_summary|

      if object_summary.key =~ /\.xml\Z/

        puts object_summary.key
        s3_object = object_summary.get

        document = Nokogiri::XML::Document.parse(s3_object.body.read)

        ead = document.at_xpath('//ead')

        title = ead.at_xpath('frontmatter/titlepage/titleproper')&.text&.strip
        department = ead.at_xpath('frontmatter/titlepage/address/addressline')&.text&.strip
        dates = ead.at_xpath('archdesc/did/unittitle/unitdate')&.text&.strip
        extent = ead.at_xpath('archdesc/did/physdesc/extent')&.text&.strip
        abstract = ead.at_xpath('archdesc/did/abstract')&.text&.strip
        unitid = ead.at_xpath('archdesc/did/unitid')&.text&.strip
        acquisition_info = ead.at_xpath('archdesc/acqinfo')&.text&.strip
        preferred_citation = ead.at_xpath('archdesc/admininfo/prefercite')&.text&.strip
        arrangement = ead.at_xpath('archdesc/arrangement')&.text&.strip

        collection = SubCollection.find_or_initialize_by(name: title)

        collection.department ||= department
        collection.dates ||= dates
        collection.extent = extent if extent
        collection.abstract ||= abstract
        collection.unitid ||= unitid
        collection.acquisition_info ||= acquisition_info
        collection.preferred_citation ||= preferred_citation
        collection.arrangement ||= arrangement
        collection.save!

        people = ead.xpath('//persname').collect {|node|
          {
            name: node['normal'] || node.text.strip.squeeze(' '),
            authfilenumber: node['authfilenumber']
          }
        }

        puts "#{people.uniq.length} people found"

        people.uniq.each do |p|

          nf = EadNameParser::NameField.new(p[:name])

          person = Person.find_or_initialize_by(name: nf.name_in_natural_order, born: nf.born_in, died: nf.died_in)
          person.identifiers['authfilenumber'] = p[:authfilenumber] if p[:authfilenumber]
          person.other = nf.other
          person.save!

          begin
            collection.people_in_collections.new(person: person, as: p[:name]).save!
          rescue ActiveRecord::RecordNotUnique
          end

        end


      end

    end


  end


end
