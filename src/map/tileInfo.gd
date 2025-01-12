class_name TileInfo # TileData was taken
extends Resource

enum TerrainType {
    Plains,
    Forest,
    Water,
    Mountain
}

var terrainType: TerrainType

func _init(type: TerrainType):
    terrainType = type

static func random() -> TileInfo:
    var values = TerrainType.values()
    var type = values[randi() % values.size()]

    return TileInfo.new(type)