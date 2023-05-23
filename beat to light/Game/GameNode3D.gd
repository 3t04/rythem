extends Node3D

export var noteSpeed = 5.0
export (PackedScene) var noteScene
export (String) var SongFile

var notes = []
var timingPoints = []
var songStartTime = 0.0
var musicPlayer
var score = 0
var combo = 0
var maxCombo = 0
var perfectCount = 0
var greatCount = 0
var goodCount = 0
var badCount = 0
var missCount = 0

var judge_line_pos = Vector3(0, 0, -10)
var judge_line_width = 16.0
var timing_threshold = 0.5

var badTiming = 0.2
var goodTiming = 0.1
var greatTiming = 0.05
var perfectTiming = 0.02

func _ready() -> void:
	# ノーツの本体シーンをプレロードする
	var noteSceneInstance = preload(noteScene)
	
	musicPlayer = get_node("MusicPlayer")

	var file = File.new()
	if file.file_exists(SongFile):
		file.open(SongFile, File.READ)
		while not file.eof_reached():
			var line = file.get_line().strip_edges()
			if line.empty():
				continue
			var note = line.split(",")
			if note.size() == 3:
				var timing = float(note[0])
				var lane = int(note[1])
				var note_instance = noteSceneInstance.instance()
				note_instance.translation = Vector3(lane * judge_line_width, 0, 0)
				add_child(note_instance)
				notes.append({"instance": note_instance, "timing": timing})

func _process(delta: float) -> void:
	# ノーツを移動させる
	for note in notes:
		var note_instance = note["instance"]
		note_instance.translation += Vector3(0, 0, -noteSpeed * delta)
		
		# ノーツが画面外に出たらインスタンスを削除する
		if note_instance.translation.z < -judge_line_pos.z:
			note_instance.queue_free()
			notes.erase(note)
