class Thing

  ES_CLIENT = Elasticsearch::Client.new url: ENV.fetch('ELASTICSEARCH_URL'), log: false

  attr_reader :metadata, :title, :id

  def initialize(metadata)
    @metadata = metadata
    @title = metadata['gfs_title']
    @id = metadata['gfs_id']
  end

  def self.find(id)
    thing = ES_CLIENT.get index: 'dev', type: 'record', id: id
    thing['_source']
  end

end