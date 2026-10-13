extends Node
# Autoload this as "PickupManager"
# Project Settings > Autoload > add this script with name "PickupManager"

enum Category { RECYCLABLE, BIODEGRADABLE, GENERAL, HAZARDOUS }

# Fired every time a trash item is collected or its count changes.
# item_id: String, icon: Texture2D, count: int, category: Category
signal inventory_updated(item_id: String, icon: Texture2D, count: int, category: int)

var counts: Dictionary = {}         # item_id -> int
var icons: Dictionary = {}          # item_id -> Texture2D
var categories: Dictionary = {}     # item_id -> Category
var order: Array = []         # preserves first-seen order for UI layout

func collect(item_id: String, icon: Texture2D, category: int) -> void:
	if not counts.has(item_id):
		counts[item_id] = 0
		icons[item_id] = icon
		categories[item_id] = category
		order.append(item_id)

	counts[item_id] += 1
	total_ever_collected += 1
	inventory_updated.emit(item_id, icon, counts[item_id], category)
	progress_updated.emit(total_ever_collected)

func get_count(item_id: String) -> int:
	return counts.get(item_id, 0)

func get_category_total(category: int) -> int:
	var total := 0
	for id in counts.keys():
		if categories[id] == category:
			total += counts[id]
	return total

func reset() -> void:
	counts.clear()
	icons.clear()
	categories.clear()
	order.clear()
	total_ever_collected = 0
	total_thrown = 0
	progress_updated.emit(0)
	thrown_updated.emit(0)

# Removes ONE unit of an item (used when the player throws trash away)
func remove_one(item_id: String) -> void:
	if not counts.has(item_id) or counts[item_id] <= 0:
		return
	counts[item_id] -= 1
	total_thrown += 1
	inventory_updated.emit(item_id, icons[item_id], counts[item_id], categories[item_id])
	thrown_updated.emit(total_thrown)

# Returns [{id, icon, category, count}, ...] for items the player holds in the given categories
func get_items_in_categories(cats: Array) -> Array:
	var result: Array = []
	for id in order:
		if counts[id] > 0 and categories[id] in cats:
			result.append({
				"id": id,
				"icon": icons[id],
				"category": categories[id],
				"count": counts[id],
			})
	return result

# --- Lifetime pickup progress (for a "collected/total" counter) ---
# Unlike `counts`, this never decreases when trash is thrown away in the sorting game.
signal progress_updated(total_ever_collected: int)
var total_ever_collected: int = 0

# Lifetime thrown count (every throw counts, correct or wrong bin)
signal thrown_updated(total_thrown: int)
var total_thrown: int = 0
