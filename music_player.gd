extends AudioStreamPlayer

var rng = RandomNumberGenerator.new()
var number_of_songs = 2
var songs = []

func _ready():
	rng.randomize()
	number_of_songs = get_child_count()
	playSong()

func playSong():
	var songNo = rng.randi_range(1, number_of_songs)
	var song = get_node(str(songNo))
	song.play()
	yield(song, "finished")
	playSong()
