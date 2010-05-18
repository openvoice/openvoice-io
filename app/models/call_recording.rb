class CallRecording

  include DataMapper::Resource

  property :id,           Serial 
  property :data,         Blob
  property :created_at,   DateTime

  belongs_to :call_log

end
