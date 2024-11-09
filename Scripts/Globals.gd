extends Node

var in_game = false
var current_location = ""
var current_floor = 0
var climbing_stairs = false
var descending_stairs = false
var at_class = false
var is_sleeping = false
var is_eating = false
var on_computer = false
var tenant_home = false

var player_speed: int = 250
var player_strength: int = 1
var player_intelligence: int = 1
var player_social: int = 1
var player_stealth: int = 1

func _ready():
	pass

func _process(_delta):
	pass

# Methods to increase stats
func increase_player_speed(amount: int):
	player_speed += amount
	print("player_speed increased to ", player_speed)

func increase_player_strength(amount: int):
	player_strength += amount
	print("player_strength increased to ", player_strength)

func increase_player_intelligence(amount: int):
	player_intelligence += amount
	print("player_intelligence increased to ", player_intelligence)

func increase_player_social(amount: int):
	player_social += amount
	print("player_social increased to ", player_social)

func increase_player_stealth(amount: int):
	player_stealth += amount
	print("player_stealth increased to ", player_stealth)

func check_tenant_availability():
	tenant_home = true
