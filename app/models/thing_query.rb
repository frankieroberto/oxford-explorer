require 'ostruct'

class ThingQuery

  ES_CLIENT = Elasticsearch::Client.new url: ENV.fetch('ELASTICSEARCH_URL'), log: false

  def initialize(query)
    @query = query
  end

  def things_count
    result['hits']['total']
  end

  def things
    result['hits']['hits'].collect {|hit| Thing.new(hit['_source']) }
  end

  def things_in_collections
    result['aggregations']['collections']['buckets'].collect do |bucket|
      OpenStruct.new(collection: Collection.find(bucket['key']), count: bucket['doc_count'])
    end
  end

  def things_by_authors
    result['aggregations']['authors']['buckets'].collect do |bucket|
      OpenStruct.new(author: bucket['key'], count: bucket['doc_count'])
    end
  end

  def things_by_item_type
    result['aggregations']['item_types']['buckets'].collect do |bucket|
      OpenStruct.new(item_type: bucket['key'], count: bucket['doc_count'])
    end
  end

  def things_by_subjects
    result['aggregations']['subjects']['buckets'].collect do |bucket|
      OpenStruct.new(subject: bucket['key'], count: bucket['doc_count'])
    end
  end

  def things_by_institution
    result['aggregations']['institutions']['buckets'].collect do |bucket|
      OpenStruct.new(institution_id: bucket['key'], count: bucket['doc_count'])
    end
  end

  def min_pubyear
    result['aggregations']['min_pubyear']['value']
  end

  def max_pubyear
    result['aggregations']['max_pubyear']['value']
  end

  private

  def result
    @result ||= begin

    ES_CLIENT.search index: 'dev',
      size: 50,
      body: {
        query: {
          filtered: {
            filter: {
             term: @query
            }
          }
        },
        aggs: {
          collections: {
            terms: {
              field: 'gfs_collection_id',
              size: 0
            }
          },
          item_types: {
            terms: {
              field: 'gfs_item_type.raw',
              size: 10
            }
          },
          authors: {
            terms: {
              field: 'gfs_author.raw',
              size: 10
            }
          },
          subjects: {
            terms: {
              field: 'gfs_subject.raw',
              size: 10
            }
          },
          institutions: {
            terms: {
              field: 'gfs_institution_id',
              size: 0
            }
          },
          min_pubyear: {
            min: {
              field: 'gfs_pubyear_clean'
            }
          },
          max_pubyear: {
            max: {
              field: 'gfs_pubyear_clean'
            }
          }
        }
      }

    end
  end

end