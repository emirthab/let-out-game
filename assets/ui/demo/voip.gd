extends Control

var effect
var recording

var timer = Timer.new()

func _ready():
	timer.wait_time = 0.1
	timer.one_shot = false
	add_child(timer)
	timer.connect("timeout",_on_timeout)
	
	var idx = AudioServer.get_bus_index("Record")
	effect = AudioServer.get_bus_effect(idx, 0)
	effect.set_recording_active(true)
	timer.start()

	#ProjectSettings.set_setting("audio/driver/mix_rate",48000)
	#ProjectSettings.save()

func _on_record_button_pressed():
	if effect.is_recording_active():
		recording = effect.get_recording()
		$PlayButton.disabled = false
		effect.set_recording_active(false)
		$RecordButton.text = "Record"
	else:
		$PlayButton.disabled = true
		effect.set_recording_active(true)
		$RecordButton.text = "Stop"


func _on_play_button_pressed():
	$Map/AudioStreamPlayer.set_stream(recording)
	$Map/AudioStreamPlayer.play()

func _on_timeout():
	effect.set_recording_active(false)
	recording = effect.get_recording()
	$Map/AudioStreamPlayer.set_stream(recording)
	$Map/AudioStreamPlayer.play()
	effect.set_recording_active(true)
