extends Resource
class_name SaveInfo

@export var level_number: int = 0
@export var party_member_names: Array[String] = []
@export var character_stats: Dictionary[String, BaseStats] = {}
@export var equipped_items: Dictionary[String, Array] = {}
@export var inventory_items: Array[Item] = []
@export var route: routes = routes.RACHELLE_ROUTE
enum routes { RACHELLE_ROUTE, MAGDA_ROUTE }
