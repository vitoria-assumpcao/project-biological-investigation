extends Node
## Autoload singleton. Register this in Project > Project Settings > Autoload
## with the name "ClueManager" so it's globally accessible.
##
## Implements the Observer pattern as the Subject: emits clue_added so that
## Hud, Inventory and other systems can react without tight coupling.

signal clue_added(clue_id: String, clue_label: String)

var collected: Dictionary = {}


func add_clue(id: String, label: String) -> void:
	if collected.has(id):
		return
	collected[id] = label
	clue_added.emit(id, label)


func has_clue(id: String) -> bool:
	return collected.has(id)


func count() -> int:
	return collected.size()


func reset() -> void:
	collected.clear()
