extends Node
## Autoload singleton. Register this in Project > Project Settings > Autoload
## with the name "ClueManager" so it's globally accessible.

signal clue_added(clue_id: String, clue_label: String)

var collected: Dictionary = {}


func add_clue(id: String, label: String) -> void:
	if collected.has(id):
		return
	collected[id] = label
	clue_added.emit(id, label)
	print("Clue collected: ", label)


func has_clue(id: String) -> bool:
	return collected.has(id)


func count() -> int:
	return collected.size()


func reset() -> void:
	collected.clear()
