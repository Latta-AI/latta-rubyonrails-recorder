module LattaProperties
  LATTA_API_URI = 'https://recording.latta.ai/v1'
  LATTA_INSTANCE_CACHE_KEY = 'latta_instance_id'
end

module LattaEndpoints
  LATTA_PUT_INSTANCE = 'instance/backend'
  LATTA_PUT_SNAPSHOT = 'snapshot/%s'
  LATTA_PUT_SNAPSHOT_ATTACHMENT = 'snapshot/%s/attachment'

  def self.put_snapshot(snapshot_id)
    format(LATTA_PUT_SNAPSHOT, snapshot_id)
  end

  def self.put_snapshot_attachment(snapshot_id)
    format(LATTA_PUT_SNAPSHOT_ATTACHMENT, snapshot_id)
  end
end

module LattaRecordLevels
  LATTA_ERROR = 'ERROR'
  LATTA_WARN = 'WARN'
  LATTA_FATAL = 'FATAL'

end