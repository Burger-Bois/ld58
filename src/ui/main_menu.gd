class_name MainMenu
extends Control

signal start_pressed()

@onready
var start_button: Button = %StartButton

@onready
var s1_letter: RigidBody2D = $S1
@onready
var h1_letter: RigidBody2D = $H1
@onready
var i1_letter: RigidBody2D = $I1
@onready
var p1_letter: RigidBody2D = $P1
@onready
var s2_letter: RigidBody2D = $S2
@onready
var h2_letter: RigidBody2D = $H2
@onready
var a1_letter: RigidBody2D = $A1
@onready
var p2_letter: RigidBody2D = $P2
@onready
var e1_letter: RigidBody2D = $E1


func _ready() -> void:
	start_button.pressed.connect(start_pressed.emit)
	push_letters([s1_letter, h1_letter, i1_letter, p1_letter, s2_letter, h2_letter, a1_letter, p2_letter, e1_letter])
	
func push_letters(letters: Array) -> void:
	for l in letters:
		l.apply_central_impulse(Vector2.RIGHT.rotated(randf_range(0, TAU)) * 5)
