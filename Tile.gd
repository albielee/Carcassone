extends StaticBody

enum TYPE{
	ROAD = 0,
	GRASS = 1,
	CITY = 2,
	CHURCH = 3
}

#using https://upload.wikimedia.org/wikipedia/commons/thumb/f/f8/Carcassonne_tiles.svg/500px-Carcassonne_tiles.svg.png
#reading from left to right
var tileIdSet = {
	#  road        grass                  city      church citybonus
	0: [[0,0,0,0], [[1,1,1,1],[1,1,1,1]], [0,0,0,0], 1, 0],
	1: [[0,0,0,0], [[0,0,1,1],[1,1,1,1]], [1,0,0,0], 0, 0],
	2: [[0,0,0,0], [[1,1,2,2],[0,0,0,0]], [0,1,0,1], 0, 0],
	3: [[0,0,0,0], [[1,1,2,2],[0,0,0,0]], [0,1,0,1], 0, 1],
	4: [[0,0,0,0], [[0,0,1,1],[0,0,0,0]], [1,1,0,1], 0, 0],
	5: [[0,0,0,0], [[0,0,1,1],[0,0,0,0]], [1,1,0,1], 0, 1],
	6: [[0,0,0,0], [[0,0,0,0],[0,0,0,0]], [1,1,1,1], 0, 1],
	7: [[0,0,0,0], [[0,0,1,1],[1,0,0,1]], [1,1,0,0], 0, 0],
	8: [[0,0,0,0], [[0,0,1,1],[1,0,0,1]], [1,1,0,0], 0, 1],
	9: [[0,0,0,0], [[0,0,0,0],[1,1,1,1]], [1,0,2,0], 0, 0],
	10:[[0,0,0,0], [[0,0,1,1],[1,0,0,1]], [1,2,0,0], 0, 0],
	11:[[0,0,1,0], [[1,1,1,1],[1,1,1,1]], [0,0,0,0], 1, 0],
	12:[[0,0,1,0], [[0,0,1,2],[0,0,0,0]], [1,1,0,1], 0, 0],
	13:[[0,0,1,0], [[0,0,1,2],[0,0,0,0]], [1,1,0,1], 0, 1],
	14:[[0,1,0,1], [[1,1,2,2],[1,1,2,2]], [0,0,0,0], 0, 0],
	15:[[0,1,0,1], [[0,0,2,2],[1,1,2,2]], [1,0,0,0], 0, 0],
	16:[[0,0,1,1], [[0,0,1,2],[1,0,0,2]], [1,1,0,0], 0, 0],
	17:[[0,0,1,1], [[0,0,1,2],[1,0,0,2]], [1,1,0,0], 0, 1],
	18:[[0,0,1,1], [[1,1,1,2],[1,1,1,2]], [0,0,0,0], 0, 0],
	19:[[0,0,1,1], [[0,0,1,2],[1,1,1,2]], [1,0,0,0], 0, 0],
	20:[[0,1,1,0], [[0,0,2,1],[1,1,2,1]], [1,0,0,0], 0, 0],
	21:[[0,1,2,3], [[0,0,2,3],[1,1,2,3]], [0,0,0,0], 0, 0],
	22:[[0,1,2,3], [[0,0,2,3],[1,1,2,3]], [1,0,0,0], 0, 0],
	23:[[1,2,3,4], [[1,2,3,4],[1,2,3,4]], [0,0,0,0], 0, 0]
}

var tileWidth = 1
var meshInstance = null

var boardPos = [0,0]
var churchID = 0
var isChurch = false
var hasCityBonus = false
var played = false

var tileColliderDict = {}

onready var roadIDs = tileIdSet[0]
onready var grassIDs= tileIdSet[0]
onready var cityIDs = tileIdSet[0]

func init(tileID):
	roadIDs = tileIdSet[tileID][TYPE.ROAD]
	grassIDs = tileIdSet[tileID][TYPE.GRASS]
	cityIDs = tileIdSet[tileID][TYPE.CITY]
	
	isChurch = tileIdSet[tileID][TYPE.CHURCH]
	hasCityBonus = tileIdSet[tileID][4]
	
	
	meshInstance = MeshInstance.new()
	var meshPiece = load("res://Voxels/" + String(tileID) + ".vox")
	meshInstance.set_mesh(meshPiece)
	add_child(meshInstance)
	tileWidth = meshInstance.get_aabb().get_longest_axis_size()
	
	assign_tile_collision(tileID)

func assign_tile_collision(tileID):
	#c tile ID, type, ID, number of that ID
	var collisionBoxes = get_tree().get_nodes_in_group(String(tileID))
	for box in collisionBoxes:
		box.disabled = false
		box.visible = true
		var boxType = box.get_name()[3]
		var boxID = box.get_name()[4]
		if(tileColliderDict.has([int(boxType), int(boxID)])):
			tileColliderDict[  [int(boxType), int(boxID)]  ].append(box)
		else:
			tileColliderDict[  [int(boxType), int(boxID)]  ] = [box]
	
func set_played():
	played = true
	
func get_played():
	return played

func rotate_tile():
	meshInstance.set_rotation_degrees(Vector3(0,meshInstance.get_rotation_degrees().y - 90,0))
	
	rotate_array(roadIDs)
	#vertical grass array needs to move to horizontal array on 90 degree rotation
	rotate_array(grassIDs[0])
	rotate_array(grassIDs[1])
	rotate_array(cityIDs)
	
	var temp = grassIDs[0]
	grassIDs[0] = grassIDs[1]
	grassIDs[1] = temp

func rotate_array(arr):
	var temp = arr[arr.size()-1]
	for i in range(arr.size()-1, 0, -1):
		arr[i] = arr[i-1]
	arr[0] = temp

func get_ids(type):
	match type:
		0:
			return roadIDs
		2:
			return cityIDs
		1:
			return grassIDs #vertical and horizontal
		_:
			print("ERROR get: Unknown area type")

func set_ids(type, ids):
	match type:
		0:
			roadIDs = ids
		2:
			cityIDs = ids
		1:
			grassIDs = ids 
		_:
			print("ERROR set: Unknown area type")

func is_church():
	return isChurch

func get_church_id():
	return churchID

func set_church_id(id):
	churchID = id

func has_city_bonus():
	return hasCityBonus
	
func set_pos(pos):
	boardPos = pos
	global_transform.origin = Vector3(pos[1]*tileWidth, 0, pos[0]*tileWidth)

func get_pos():
	return boardPos

func get_tile_width():
	return tileWidth
