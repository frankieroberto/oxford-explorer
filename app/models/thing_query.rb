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
        }
      }

    end
  end

end