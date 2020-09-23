extends Control

#Control the game, e.g. placing of tiles, initializing tiles

#hold the amount of each tile to be put into play
var initializeTiles = [4,5,1,2,3,1,1,3,2,3,2,2,1,2,8,3,3,2,9,3,3,4,3,1]

var rng = RandomNumberGenerator.new()
var playerTurn = 0
var currentTile = null
var has_intitialized = false
var init_delay = 5

export var playerCount = 0

onready var gameBoard = get_node("../GameBoard")
onready var camera = get_node("../Camera")
onready var preloadTile = preload("res://Tile.tscn").duplicate(true)

func _ready():
	rng.randomize()

func get_playable_tile():
	for tile in get_tree().get_nodes_in_group("Tile"):
		if(tile.get_played() == false):
			#if the tile can be played somewhere
			if(gameBoard.is_tile_possible(tile)):
				return tile
			else: #else destroy the tile
				tile.queue_free()
				print("tile not playable")
	#else, end the game because no more playable tiles

func _input(event):
	if(has_intitialized):
		#highlight collider mouse is hovering over on tile
		var hoveringTile = camera.get_raycast_hovering_tile()
		if(hoveringTile):
			#print(camera.get_raycast_collider_id())
			gameBoard.highlight_all_area(camera.get_raycast_collider_id())
			#hoveringTile.highlight_area(camera.get_raycast_collider_id())
		
		if(currentTile == null):
			currentTile = get_playable_tile()
		if(currentTile != null):
			var tileWidth = currentTile.get_tile_width()
			var pos = [clamp(round((camera.get_raycast_pos().z) / tileWidth),0,22), clamp(round(camera.get_raycast_pos().x / tileWidth),0,22)]
			
			if(event.is_pressed() and event.is_action_pressed("click")):
				if(event.button_index == BUTTON_LEFT):
					#place tile at position
					if(gameBoard.is_tile_allowed(currentTile, pos)):
						gameBoard.place_tile(currentTile, pos)
						currentTile = null
						#gameBoard.print_areamap()
						
				elif(event.button_index == BUTTON_RIGHT):
					currentTile.rotate_tile()
			elif(event is InputEventMouseMotion):
				currentTile.global_transform.origin = Vector3(pos[1]*tileWidth, 0, pos[0]*tileWidth)


func _process(delta):
	init_delay -= 1
	if(init_delay == 0):
		init_tiles()
		
	update()

func init_tiles():
	#initliaze the start middle tile
	var tile = preloadTile.instance()
	get_parent().add_child(tile)
	tile.set_name(String("start_tile"))
	tile.init(15)
	gameBoard.place_tile(tile, [11,11])
	
	var i = 0
	#randomly initialize the tile stack
	var found = false
	var emptyArray = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
	while(initializeTiles != emptyArray):
		i+=1
		if(i == 10):
			break
		var rand = 0
		while(found == false):
			rand = rng.randi_range(0, 23)
			if(initializeTiles[rand] >= 1):
				initializeTiles[rand] -= 1
				found = true
		found = false
			
		tile = preloadTile.instance()
		get_parent().add_child(tile)
		tile.set_name(String(rand) + String(initializeTiles[rand]))
		tile.init(rand)
	
	has_intitialized = true

