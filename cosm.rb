require 'rubygems'
require 'cosm-rb'

config = YAML.load_file('cosm.yml')
API_KEY = config["api_key"]
FEED_ID = config["feed_id"]


git_diff = `git diff --stat HEAD HEAD^1`

files_changed = git_diff.match(/\d+ files changed/).to_s.gsub(/files changed*/, "")
insertions    = git_diff.match(/\d+ insertions/).to_s.gsub(/insertions*/, "")
deletions     = git_diff.match(/\d+ deletions/).to_s.gsub(/deletions*/, "")


{:FilesChanged => files_changed, :Insertions => insertions, :Deletions => deletions}.each_pair do |key,value|
  datapoint = Cosm::Datapoint.new(:at => Time.now, :value => value)
  Cosm::Client.post("/v2/feeds/#{FEED_ID}/datastreams/#{key}/datapoints",
	:headers => {"X-ApiKey" => API_KEY},
	:body => {:datapoints => [datapoint]}.to_json)
end

puts 'data posted to Cosm'
