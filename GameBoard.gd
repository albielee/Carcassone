extends Node


var board = [
	[null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null],
	[null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null],
	[null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null],
	[null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null],
	[null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null],
	[null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null],
	[null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null],
	[null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null],
	[null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null],
	[null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null],
	[null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null],
	[null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null],
	[null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null],
	[null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null],
	[null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null],
	[null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null],
	[null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null],
	[null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null],
	[null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null],
	[null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null],
	[null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null],
	[null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null],
	[null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null],
	[null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null]
]
#board will be filled with arrays of tiles each part of the board belongs to

#each tile can be a part of multiple areas, the tiles will have a list of areas they
#belong to. When a tile is placed that extends an area, the placed tile will adopt the
#areaID it was placed into and we will update the areamap with the areaID for that tile.

#areas will need to be joined. When a connecting tile joins two or most areas, a new areaID will
#be created and all joining areas will be placed into this new area, including the meaples of each player
enum TYPE{
	ROAD = 0,
	GRASS = 1,
	CITY = 2,
	CHURCH = 3
}
enum MAP{
	PATH = 0,
	MEAPLES = 1,
	TYPE = 2
}
enum SEARCH{
	Y= 0,
	X= 1
}

#update this every time a new time increases an area size
var areaMap = {
	#areaID: path, meaple count for each player ID
}
#make sure no areas get the same ID assigned to them by increasing this everytime an area is created
var ID = 4

var startPos = [5, 5]
		
func print_areamap():
	for key in areaMap.keys():
		print(String(key) + ": " + String(areaMap[key]))

func print_board():
	for row in board:
		print(row)

func highlight_all_area(areaID):
	#print(areaID)
	#print_areamap()
	#print("*****")
	if(areaMap.has(areaID)):
		for pos in areaMap[areaID][MAP.PATH]:
			var tile = board[pos[1]][pos[0]]
			if(tile != null):
				tile.highlight_area(areaID)

#test if there is any possible place for the tile to be put
func is_tile_possible(tile):
	var dirs = [[-1,0],[0,1],[1,0],[0,-1]]
	for row in board:
		for foundTile in row:
			if(foundTile == null):
				continue
			else:
				#dir
				for i in range(4):
					var pos = foundTile.get_pos()
					var dirPosX = pos[1] + dirs[i][1]
					var dirPosY = pos[0] + dirs[i][0]
					var currentTile = board[dirPosY][dirPosX]
					if(currentTile == null):
						#rotation
						for rot in range(4):
							if(is_tile_allowed(tile, [dirPosY,dirPosX])):
								return true
							tile.rotate_tile()
	return false

#test if an area ID is completed, i.e. all open links are ended
func is_area_completed(areaID, type):
	if(type == TYPE.ROAD or type == TYPE.CITY):
		var dirs = [[-1,0],[0,1],[1,0],[0,-1]]
		for pos in areaMap[areaID][MAP.PATH]:
			var tile = board[pos[0]][pos[1]]
			var tileIDs = tile.get_ids(type)
			for i in range(4):
				var dirPosX = pos[1] + dirs[i][1]
				var dirPosY = pos[0] + dirs[i][0]
				var dirID = tileIDs[i]
				var currentTile = board[dirPosY][dirPosX]
				if(dirID == areaID):
					if(currentTile == null):
						return false
	elif(type == TYPE.CHURCH):
		var path = areaMap[areaID][MAP.PATH]
		print(path)
		if(path.size() != 9):
			return false
	elif(type == TYPE.GRASS):
		var dirVertical = [[-1,0],[-1,0],[1,0],[1,0]]
		var dirHorizontal = [[0,-1],[0,1],[0,1],[0,-1]]
		for pos in areaMap[areaID][MAP.PATH]:
			var tile = board[pos[0]][pos[1]]
			var tileIDs = tile.get_ids(type)
			for j in range(2):
				var directions = []
				if(j == 0):
					directions = dirVertical
				else:
					directions = dirHorizontal
					
				for i in range(4):
					var dirPosX = pos[1] + directions[i][1]
					var dirPosY = pos[0] + directions[i][0]
					var currentTile = board[dirPosY][dirPosX]
					var dirID = tileIDs[j][i]
					if(currentTile == null):
						return false
	return true
func is_tile_allowed(tile, pos):
	var dirs = [[-1,0],[0,1],[1,0],[0,-1]]
	var areaIDs = tile.get_ids(TYPE.ROAD)
	var neighbouringTiles = 4
	for i in range(4):
		var dirPosX = pos[1] + dirs[i][1]
		var dirPosY = pos[0] + dirs[i][0]
		var currentTile = board[dirPosY][dirPosX]
		var dirID = areaIDs[i]
		if(currentTile != null):
			var otherIDs = currentTile.get_ids(TYPE.ROAD)
			var oppositeID = get_opposite_id(otherIDs, i, dirs[i], TYPE.ROAD)
			if(dirID != 0 and oppositeID == 0):
				return false
			if(oppositeID != 0 and dirID == 0):
				return false
		else:
			neighbouringTiles -= 1
	if(neighbouringTiles == 0):
		return false		
	
	areaIDs = tile.get_ids(TYPE.CITY)
	for i in range(4):
		var dirPosX = pos[1] + dirs[i][1]
		var dirPosY = pos[0] + dirs[i][0]
		var currentTile = board[dirPosY][dirPosX]
		var dirID = areaIDs[i]
		if(currentTile != null):
			var otherIDs = currentTile.get_ids(TYPE.CITY)
			var oppositeID = get_opposite_id(otherIDs, i, dirs[i], TYPE.CITY)
			if(dirID != 0 and oppositeID == 0):
				return false
			if(oppositeID != 0 and dirID == 0):
				return false
	
	return true
func place_tile(tile, pos):
	#if pos out of range
	if(pos[0] < board.size()-1 and pos[1] < board.size()-1):
		
		var oldRoadIDs =  [] + tile.get_ids(TYPE.ROAD)
		var oldGrassIDs = [] + tile.get_ids(TYPE.GRASS)
		var oldCityIDs =  [] + tile.get_ids(TYPE.CITY)
		var oldChurchID = tile.get_church_id()
		#print("old road ids:" +String(oldRoadIDs))
		
		board[pos[0]][pos[1]] = tile
		tile.set_played()
		tile.set_pos(pos)
		#add to areas
		add_areas(tile, pos, TYPE.ROAD)
		add_areas(tile, pos, TYPE.CITY)
		#exlusively for grass
		add_grass_areas(tile, pos)
		add_church_areas(tile, pos)
		
		print("ID="+String(ID))
		var newRoadIDs = [] + tile.get_ids(TYPE.ROAD)
		var newCityIDs = [] + tile.get_ids(TYPE.CITY)
		var newGrassIDs = [] + tile.get_ids(TYPE.GRASS)
		
		for i in range(0,4):
			#print("new road ids:" + String(tile.get_ids(TYPE.ROAD)))
			#print("old road ids:" + String(oldRoadIDs[i]))
			#print("new road ids:" + String(newRoadIDs[i]))
			tile.rename_colliders(TYPE.ROAD, oldRoadIDs[i], newRoadIDs[i])
			tile.rename_colliders(TYPE.CITY, oldCityIDs[i], newCityIDs[i])
			tile.rename_colliders(TYPE.GRASS, oldGrassIDs[0][i], newGrassIDs[0][i])
			tile.rename_colliders(TYPE.GRASS, oldGrassIDs[1][i], newGrassIDs[1][i])
		
		tile.rename_colliders(TYPE.CHURCH, oldChurchID, tile.get_church_id())
		#print(tile.tileColliderDict)
		#for t in tile.tileColliderDict:
		#	print(t.get_name())

func add_church_areas(tile, pos):
	var directions = [[-1,-1],[-1,0],[-1,1],[0,1],[1,1],[1,0],[1,-1],[0,-1]]
	if(tile.is_church()):
		create_area(tile, TYPE.CHURCH, pos)
		tile.set_church_id(ID)
		
		for i in range(8):
			var dirPosX = pos[1] + directions[i][1]
			var dirPosY = pos[0] + directions[i][0]
			var currentTile = board[dirPosY][dirPosX]
			if(currentTile != null):
				var churchID = tile.get_church_id()
				add_to_area(churchID, currentTile.get_pos())
				
	for i in range(8):
		var dirPosX = pos[1] + directions[i][1]
		var dirPosY = pos[0] + directions[i][0]
		var currentTile = board[dirPosY][dirPosX]
		if(currentTile != null):
			if(currentTile.is_church()):
				var churchID = currentTile.get_church_id()
				add_to_area(churchID, pos)
				if(is_area_completed(churchID, TYPE.CHURCH)):
					print("church completed")
				
#for roads and city
func add_areas(tile, pos, type):
	var dirs = [[-1,0],[0,1],[1,0],[0,-1]]
	var areaIDs = tile.get_ids(type)
	
	for i in range(4):
		var dirPosX = pos[1] + dirs[i][1]
		var dirPosY = pos[0] + dirs[i][0]
		var currentTile = board[dirPosY][dirPosX]
		var dirID = areaIDs[i]
		if(currentTile != null):
			#check roads
			#if the road direction is not empty and not already added to an area
			if(dirID != 0):
				if(dirID <= 4):
					var otherIDs = currentTile.get_ids(type)
					var oppositeID = get_opposite_id(otherIDs, i, dirs[i], type)
					#if the connecting road on the opposite tile is not empty
					if(oppositeID != 0):
						#add to tile road area path
						add_to_area(oppositeID, pos)
						replace(areaIDs, dirID, oppositeID)
						tile.set_ids(type, areaIDs)
						if(is_area_completed(oppositeID, type)):
							print("completed in add to" +String(type) +" section")
						#for all road ids, if road id == current id, id = oppositeID
						#
				else: #join two areas
					var otherIDs = currentTile.get_ids(type)
					var oppositeID = get_opposite_id(otherIDs, i, dirs[i], type)
					if(oppositeID != 0):
						join_areas([dirID, oppositeID], type)
						if(is_area_completed(ID, type)):
							print("completed in join  "+String(type) +" section")
		else: #if no opposite tile
			if(dirID != 0 and dirID <= 4): #if road doesnt have an assigned ID, create a new road area on the map
				create_area(tile, type, pos)
				replace(areaIDs, dirID, ID)
				tile.set_ids(type, areaIDs)
				if(is_area_completed(ID, type)):
					print("completed in create area section")
		
	#print(is_area_completed(ID, type))


func add_grass_areas(tile, pos):
	var areaIDs = tile.get_ids(TYPE.GRASS)
	var dirVertical = [[-1,0],[-1,0],[1,0],[1,0]]
	var dirHorizontal = [[0,-1],[0,1],[0,1],[0,-1]]
	for j in range(2):
		var directions = []
		if(j == 0):
			directions = dirVertical
		else:
			directions = dirHorizontal
			
		for i in range(4):
			var dirPosX = pos[1] + directions[i][1]
			var dirPosY = pos[0] + directions[i][0]
			var currentTile = board[dirPosY][dirPosX]
			var dirID = areaIDs[j][i]
				
			if(currentTile != null):
				#check roads
				#if the road direction is not empty and not already added to an area
				if(dirID != 0 and dirID <= 4):
					var otherIDs = currentTile.get_ids(TYPE.GRASS)[j]
					var oppositeID = get_opposite_id(otherIDs, i, directions[i], TYPE.GRASS)
					#if the connecting road on the opposite tile is not empty
					if(oppositeID != 0):
						#add to tile road area path
						add_to_area(oppositeID, pos)
						replace(areaIDs[0], dirID, oppositeID)
						replace(areaIDs[1], dirID, oppositeID)
						tile.set_ids(TYPE.GRASS, areaIDs)
						if(is_area_completed(oppositeID, TYPE.GRASS)):
							print("completed in add to grass section")
				else: #join two areas
					if(dirID != 0):
						var otherIDs = currentTile.get_ids(TYPE.GRASS)[j]
						var oppositeID = get_opposite_id(otherIDs, i, directions[i], TYPE.GRASS)
						if(oppositeID != 0 and dirID != oppositeID):
							join_grass_areas([dirID, oppositeID])
							if(is_area_completed(ID, TYPE.GRASS)):
								print("completed in join grass section")
			else: #if no opposite tile
				if(dirID != 0 and dirID <= 4): #if road doesnt have an assigned ID, create a new road area on the map
					create_area(tile, TYPE.GRASS, pos)
					replace(areaIDs[0], dirID, ID)
					replace(areaIDs[1], dirID, ID)
					tile.set_ids(TYPE.GRASS, areaIDs)
					#if(is_area_completed(ID, TYPE.GRASS)):
					#	print("completed in create section")

func join_grass_areas(listIDs):
	ID+=1
	var newAreaPath = []
	var newMeaples = []
	for areaID in listIDs:
		var positions = areaMap[areaID][MAP.PATH]
		newAreaPath += positions
		newMeaples += areaMap[areaID][MAP.MEAPLES]
	
		for pos in positions:
			#for each pos in path, set the new road ids to new area id
			var tileAtPos = board[pos[0]][pos[1]]
			var areaIDs = tileAtPos.get_ids(TYPE.GRASS)
			
			replace(areaIDs[0], areaID, ID)
			replace(areaIDs[1], areaID, ID)
			tileAtPos.set_ids(TYPE.GRASS, areaIDs)
		
	for areaID in listIDs:
		#remove unused area ids	
		areaMap.erase(areaID)
	
	areaMap[ID] = [newAreaPath, newMeaples, TYPE.GRASS]

func join_areas(listIDs, type):
	ID+=1
	var newAreaPath = []
	var newMeaples = []
	
	for areaID in listIDs:
		var positions = areaMap[areaID][MAP.PATH]
		newAreaPath += positions
		newMeaples += areaMap[areaID][MAP.MEAPLES]
	
		for pos in positions:
			#for each pos in path, set the new road ids to new area id
			var tileAtPos = board[pos[0]][pos[1]]
			var areaIDs = tileAtPos.get_ids(type)
					
			replace(areaIDs, areaID, ID)
			tileAtPos.set_ids(type, areaIDs)
		
	for areaID in listIDs:
		#remove unused area ids	
		areaMap.erase(areaID)
	
	areaMap[ID] = [newAreaPath, newMeaples, type]

func create_area(tile, type, pos):
	ID+=1
	areaMap[ID] = [[pos], [], type]

func add_to_area(areaID, pos):
	#add the tile pos to the areaMap path
	areaMap[areaID][MAP.PATH].append(pos)

func replace(array: Array, find, replace) -> void:
	for i in array.size():
		if array[i] == find:
			array[i] = replace

func get_opposite_id(ids, index, direction, type):
	#up or down
	if(direction[0] != 0 or type != TYPE.GRASS):
		index -= 1
		if(index < 0):
			index = 3
		index -= 1
		if(index < 0):
			index = 3
	#left or right
	else:
		if(index == 0):
			index = 1
		elif(index == 1):
			index = 0
		elif(index == 2):
			index = 3
		elif(index == 3):
			index = 2
	return ids[index]
