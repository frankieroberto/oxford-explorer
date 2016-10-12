class Thing

  ES_CLIENT = Elasticsearch::Client.new url: ENV.fetch('ELASTICSEARCH_URL'), log: false

  def self.find(id)
    ES_CLIENT.get index: 'dev', type: 'record', id: id
  end


end