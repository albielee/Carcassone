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

func _ready():
	rng.randomize()

func get_playable_tile():
	for tile in get_tree().get_nodes_in_group("Tile"):
		if(tile.get_played() == false):
			return tile
	#else, end the game because no more playable tiles

func _input(event):
	if(has_intitialized):
		currentTile = get_playable_tile()
		var tileWidth = currentTile.get_tile_width()
		var pos = [round(get_global_mouse_position().y / tileWidth), round(get_global_mouse_position().x / tileWidth)]
		if(event.is_pressed()):
			if(event.button_index == BUTTON_LEFT):
				#place tile at position
				if(gameBoard.is_tile_allowed(currentTile, pos)):
					gameBoard.place_tile(currentTile, pos)
					gameBoard.print_areamap()
					
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
	var tile = load("res://Tile.tscn").instance()
	get_parent().add_child(tile)
	tile.set_name(String("start_tile"))
	tile.init(15)
	gameBoard.place_tile(tile, [5,5])
	
	
	#randomly initialize the tile stack
	var found = false
	var emptyArray = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
	while(initializeTiles != emptyArray):
		var rand = 0
		while(found == false):
			rand = rng.randi_range(0, 23)
			if(initializeTiles[rand] >= 1):
				initializeTiles[rand] -= 1
				found = true
		found = false
			
		tile = load("res://Tile.tscn").instance()
		get_parent().add_child(tile)
		tile.set_name(String(rand) + String(initializeTiles[rand]))
		tile.init(rand)
	
	has_intitialized = true

func _draw():
	var start = -26*10
	var end = 26*10
	for i in range(start, end, 26):
		draw_line(Vector2(i,0), Vector2(i, end*2), Color(0, 0, 0), 1)
	for i in range(start, end, 26):
		draw_line(Vector2(0,i), Vector2(end*2, i), Color(0, 0, 0), 1)
