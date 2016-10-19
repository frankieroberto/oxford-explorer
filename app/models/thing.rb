class Thing

  ES_CLIENT = Elasticsearch::Client.new url: ENV.fetch('ELASTICSEARCH_URL'), log: false

  attr_reader :metadata, :title, :id, :description

  def initialize(metadata)
    @metadata = metadata
    @title = Array(metadata['gfs_title']).first || '(untitled)'
    @description = Array(metadata['gfs_description']).first
    @id = metadata['gfs_id']
  end

  def [](key)
    @metadata[key]
  end

  def self.find(id)
    thing = ES_CLIENT.get index: 'dev', type: 'record', id: id
    self.new(thing['_source'])
  end

end