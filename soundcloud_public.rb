require 'soundcloud'
require 'awesome_print'
p 1
tracks = File.readlines('tracks.txt')

tracks = ARGV unless tracks
unless tracks
  ap 'Add tracks please' 
  exit
end
p 2
client = SoundCloud.new({
  :client_id     => ENV['SPOTIFY_CLIENT'],
  :client_secret => ENV['SPOTIFY_SECRET'],
  :username      => ENV['SPOTIFY_USER'],
  :password      => ENV['SPOTIFY_PASSWORD']
})

playlist = client.get("/me/playlists").first
p 3
tracks.map! do |track|
  ap track
  begin
  track = client.get('/tracks', limit:  1, q: track)
  track = track.first
  unless track.nil?
    track = {
      title: track['title'],
      url: track['permalink_url'],
      id: track['id']
    }
  else
    nil
  end
  rescue
    ap track
    ap 'WTF DUDE'
    nil
  end
end



new_tracks = tracks.compact.map{|x| x[:id]}
track_ids = playlist.tracks.map(&:id) if playlist.tracks.size > 0# => [22448500, 21928809]
# adding a new track 21778201
track_ids ||= []
track_ids += new_tracks # => [22448500, 21928809, 21778201]
track_ids.uniq!
# map array of ids to array of track objects:
tracks = track_ids.map{|id| {:id => id}} # => [{:id=>22448500}, {:id=>21928809}, {:id=>21778201}]

# send update/put request to playlist
playlist = client.put(playlist.uri, :playlist => {
  :tracks => tracks
})


