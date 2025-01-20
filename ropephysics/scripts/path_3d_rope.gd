extends Path3D
# Script by Elijah Martin/Palin_drome
@export_range(3,200,1) var number_of_segments = 10
@export_range(3,50,1) var mesh_sides = 6
@export var cable_thickness = 0.1
@export var fixed_start_point = true
@export var fixed_end_point = true
@export var rigidbody_attached_to_start : RigidBody3D
@export var rigidbody_attached_to_end : RigidBody3D
@export var material : Material
@onready var mesh := $CSGPolygon3D
@onready var distance = curve.get_baked_length()
# instances
var segments : Array
var joints : Array
var curve_points : Array

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# store position and rotation
	var rotation_buffer = rotation
	rotation = Vector3(0,0,0)
	var position_buffer = position
	position = Vector3(0,0,0)
	# CSG Mesh shape array
	var myShape : PackedVector2Array
	for i in (number_of_segments+1):
		curve_points.append(curve.sample_baked((distance*(i))/(number_of_segments), true))
	curve.clear_points()

	# create cable segments
	for i in number_of_segments:
		# create rigidbodies
		segments.append(RigidBody3D.new())
		self.add_child(segments[i])
		# position rigidbodies between the joints
		segments[i].position = curve_points[i] + (curve_points[i+1] - curve_points[i])/2
		# create collision shape 3Ds
		segments[i].add_child(CollisionShape3D.new())
		# add capsule shape
		segments[i].get_child(0).shape = CapsuleShape3D.new()
		segments[i].get_child(0).shape.radius = cable_thickness
		segments[i].get_child(0).shape.height = (curve_points[i+1]-curve_points[i]).length()
		# small offset added to prevent Vector UP
		segments[i].look_at_from_position(curve_points[i] + (curve_points[i+1] - curve_points[i])/2 + Vector3(0.001, 0, -0.001), curve_points[i+1])
		segments[i].rotation.x += PI/2
		
		# create pin joints
		# attach joints to rigidbodies path
		if i == 0 && fixed_start_point:
			#joints.append(ConeTwistJoint3D.new())
			joints.append(PinJoint3D.new())
			self.add_child(joints[i])
			joints[i].position = curve_points[i]
		else:
			#joints.append(ConeTwistJoint3D.new())
			joints.append(PinJoint3D.new())
			self.add_child(joints[i])
			joints[i].position = curve_points[i]
			joints[i].node_a = segments[i-1].get_path()
			joints[i].node_b = segments[i].get_path()
		#add new curve points
		curve.add_point(curve_points[i])
	curve.add_point(curve_points[number_of_segments])
	# setup mesh array
	for i in mesh_sides:
		myShape.append(Vector2(sin(2*PI*(i+1)/mesh_sides), cos(2*PI*(i+1)/mesh_sides)) * cable_thickness)
	
	# setup mesh
	mesh.polygon = myShape
	if material != null:
		mesh.material = material
	
	# restore position and rotation
	rotation = rotation_buffer
	# lock joints and segments position and rotation 
	for segment in segments:
		segment.top_level = true
		segment.position += position_buffer
	for joint in joints:
		joint.top_level = true
		joint.position += position_buffer
	
	# set rotation and position to 0
	# fix start point
	rotation = Vector3(0,0,0)
	if fixed_start_point:
		joints[0].node_b = segments[0].get_path()
	if fixed_end_point:
		#joints.append(ConeTwistJoint3D.new())
		joints.append(PinJoint3D.new())
		self.add_child(joints[-1])
		joints[-1].position = curve_points[-1] + position_buffer
		joints[-1].node_a = segments[number_of_segments - 1].get_path()
	# attach rigid bodies if they exist
	if rigidbody_attached_to_start != null:
		joints[0].node_b = rigidbody_attached_to_start.get_path()
	if rigidbody_attached_to_end != null:
		if fixed_end_point == false:
			joints.append(PinJoint3D.new())
			self.add_child(joints[-1])
			joints[-1].position = curve_points[-1] + position_buffer
			joints[-1].node_a = segments[-1].get_path()
		joints[-1].node_b = rigidbody_attached_to_end.get_path()


func _physics_process(_delta: float) -> void:
	# update curve positions
	for p in (curve.point_count):
		if  p < (number_of_segments):
			# get the first segment and subtract it's basis * distance to point at the endpoint 
			curve.set_point_position(p, segments[p].position + segments[p].transform.basis.y * segments[p].get_child(0).shape.height/2)
		else:
			# get the last segment and add it's basis * distance to point at the endpoint 
			curve.set_point_position(p, segments[p-1].position - segments[p-1].transform.basis.y * segments[p-1].get_child(0).shape.height/2)
