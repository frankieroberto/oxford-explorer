class ThingAggregation

  ES_CLIENT = Elasticsearch::Client.new url: ENV.fetch('ELASTICSEARCH_URL'), log: false

  def initialize(field, size)
    @field = field
    @size = size
  end

  def aggregation
    result['aggregations'][@field]['buckets']
      .reject {|bucket| bucket['key'].blank? }
  end

  private

  def result
    @result ||= begin


    ES_CLIENT.search index: 'dev',
      size: 50,
      body: {
        aggs: {
          @field => {
            terms: {
              field: @field,
              size: @size
            }
          }
        }
      }

    end
  end

end