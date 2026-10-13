extends HBoxContainer

@export var icon_size: Vector2 = Vector2(32, 32) #The sizeo f each trash icon in the HUD
@export var entry_separation: int = 12 #remembers the HUD row created for each trash type

# item_id -> { "label": Label }
var entries: Dictionary = {}

func _ready() -> void: #runs once when the scene loads
	add_theme_constant_override("separation", entry_separation) #applies the spacing between entries.
	PickupManager.inventory_updated.connect(_on_inventory_updated) #connects to PickupManager

func _on_inventory_updated(item_id: String, icon: Texture2D, count: int, _category: int) -> void:
	#runs each time an  item is collected or thrown
	if count <= 0: #Count is 0 or less: the player has thrown all of that item, so the entr'y riw us deleted
		if entries.has(item_id):
			entries[item_id]["container"].queue_free()
			entries.erase(item_id)
		return

	if not entries.has(item_id): #if there's no row for this item yet, _create_entry() makes one.
		_create_entry(item_id, icon, count)
	else:#if already exists, it updates the text to the new count (x3) 
		entries[item_id]["label"].text = "x%d" % count 
		_pulse(entries[item_id]["label"])

func _create_entry(item_id: String, icon: Texture2D, count: int) -> void: #builds a new HUD row in code
	var entry := HBoxContainer.new() #holds a texture rect for the icon and a label for count
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

func _pulse(label: Label) -> void: #small visual effect
	label.scale = Vector2(1.4, 1.4)
	var tween := create_tween()
	tween.tween_property(label, "scale", Vector2.ONE, 0.15).set_trans(Tween.TRANS_BACK)
