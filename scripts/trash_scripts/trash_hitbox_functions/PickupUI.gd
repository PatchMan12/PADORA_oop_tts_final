extends HBoxContainer
# Attach to an HBoxContainer inside a CanvasLayer, anchored top-left.
# Scene structure:
#   CanvasLayer
#     PickupUI (HBoxContainer)   <- this script here

@export var icon_size: Vector2 = Vector2(32, 32)
@export var entry_separation: int = 12

# item_id -> { "label": Label }
var entries: Dictionary = {}

func _ready() -> void:
	add_theme_constant_override("separation", entry_separation)
	PickupManager.inventory_updated.connect(_on_inventory_updated)

func _on_inventory_updated(item_id: String, icon: Texture2D, count: int, _category: int) -> void:
	# Count hit zero (all thrown away) -> remove icon + label from the HUD
	if count <= 0:
		if entries.has(item_id):
			entries[item_id]["container"].queue_free()
			entries.erase(item_id)
		return

	if not entries.has(item_id):
		_create_entry(item_id, icon, count)
	else:
		entries[item_id]["label"].text = "x%d" % count
		_pulse(entries[item_id]["label"])

func _create_entry(item_id: String, icon: Texture2D, count: int) -> void:
	var entry := HBoxContainer.new()
	entry.add_theme_constant_override("separation", 4)

	var texture_rect := TextureRect.new()
	texture_rect.texture = icon
	texture_rect.custom_minimum_size = icon_size
	texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE

	var label := Label.new()
	label.text = "x%d" % count
	label.add_theme_font_size_override("font_size", 20)

	entry.add_child(texture_rect)
	entry.add_child(label)
	add_child(entry)

	entries[item_id] = { "label": label, "container": entry }
	_pulse(label)

func _pulse(label: Label) -> void:
	label.scale = Vector2(1.4, 1.4)
	var tween := create_tween()
	tween.tween_property(label, "scale", Vector2.ONE, 0.15).set_trans(Tween.TRANS_BACK)
