extends Node
# An Autoload (one global copy for the whole game). The game's memory for trash
enum Category { RECYCLABLE, BIODEGRADABLE, GENERAL, HAZARDOUS } #fixed list of the four trash types: RECYCLABLE, BIODEGRADABLE, GENERAL, HAZARDOUS

#Whenever an item is collected or thrown (carries the item, icon, new count, and category).
signal inventory_updated(item_id: String, icon: Texture2D, count: int, category: int)

var counts: Dictionary = {}  #How many of each item the player currently holds        
var icons: Dictionary = {}   #The picture for each item, so the HUD and sorting screen can show it 
var categories: Dictionary = {}     #Which category each item belongs to
var order: Array = []    #The order items were first collected, so the HUD keeps a stable layout

func collect(item_id: String, icon: Texture2D, category: int) -> void: #is called by TrashItem when the player pick something up. 
	if not counts.has(item_id): #If it's a new item, it stores its icon and category. Then it adds 1 to that item's count and to total_evel_collected, and fires inventory_updated and progress_updated.
		counts[item_id] = 0
		icons[item_id] = icon
		categories[item_id] = category
		order.append(item_id)

	counts[item_id] += 1
	total_ever_collected += 1
	inventory_updated.emit(item_id, icon, counts[item_id], category)
	progress_updated.emit(total_ever_collected)

func get_count(item_id: String) -> int: #returns how many of one item the player holds, or 0 if none.
	return counts.get(item_id, 0)

func get_category_total(category: int) -> int: #adds up how many items the player holds in one category.
	var total := 0
	for id in counts.keys():
		if categories[id] == category:
			total += counts[id]
	return total

func reset() -> void: #clears everything and sets both lifetime totals to 0, then fires the two progress signals so the HUD shows zeros. It is called when the player restarts after dying or finishing.
	counts.clear()
	icons.clear()
	categories.clear()
	order.clear()
	total_ever_collected = 0
	total_thrown = 0
	progress_updated.emit(0)
	thrown_updated.emit(0)


func remove_one(item_id: String) -> void: #is called by SortingGame when the player throws an item. It checks the player actually has that item, subtracts 1 from its count, adds 1 to total_thrown, and fires inventory_updated and thrown_updated. When the count reaches 0, the HUD removes that icon.
	if not counts.has(item_id) or counts[item_id] <= 0:
		return
	counts[item_id] -= 1
	total_thrown += 1
	inventory_updated.emit(item_id, icons[item_id], counts[item_id], categories[item_id])
	thrown_updated.emit(total_thrown)


func get_items_in_categories(cats: Array) -> Array: #For SortingGame to find the what the play can sort at the current can.
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

#Lifetime throws, It only goes up, even after trash in thrown 
signal progress_updated(total_ever_collected: int)
var total_ever_collected: int = 0 

# Lifetime thrown count (every throw counts, correct or wrong bin)
signal thrown_updated(total_thrown: int)
var total_thrown: int = 0
