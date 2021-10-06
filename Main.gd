extends Node

# Called when the node enters the scene tree for the first time.
func _ready():
	print("Main::_ready: %s" % self.name)
	GameManager.connect("score_update", self, "_update_score")
	print("Connected to GameManager::score_update")
	print("ScoreCounter: %s" % $ScoreCounter)
	

func _update_score():
	print("New score: %s" % GameManager.score)
	print("New score counter: %s" % $ScoreCounter)
	if !$ScoreCounter: return
	$ScoreCounter.text = str(GameManager.score)
	print("Score updated: %s" % GameManager.score)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
