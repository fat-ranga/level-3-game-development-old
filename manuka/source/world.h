// Define the class macro for this thing.
#ifndef MANUKA_WORLD_H
#define MANUKA_WORLD_H

// Godot stuff that we're using.
#include <godot_cpp/classes/control.hpp>
#include <godot_cpp/classes/global_constants.hpp>
#include <godot_cpp/core/binder_common.hpp>

#include <godot_cpp/classes/node3d.hpp>
#include <godot_cpp/classes/material.hpp>
#include <godot_cpp/classes/resource.hpp>

#include "voxel_data.h"

using namespace godot;

namespace manuka {

class World : public Node3D {
	GDCLASS(World, Node3D)
private:
	Ref<godot::Material> material;
protected:
	static void _bind_methods();
public:
	World();
	~World();

	//uint8_t get_block_id(const godot::String p_name);
	//bool is_block_solid(const uint8_t p_block_id);

	// TODO: these empty variables will be set in the _ready function of the 
	// world.gd, which will have its data passed to it from Main,
	// which gets its data from the DataImporter.
	// 
	// So, you need to add a bunch of add_property and methods for all
	// this stuff. They don't need to be visible in the @export, and in
	// fact shouldn't be. TODO: remove @export hint for the material for consistency!!!!!
	// - can't specify it's a material anyway, so might as well.
	// 
	// This is so that we don't get the 'has no member <variable>' error.
	// 
	// Another solution would be to pass each variable as a paramater
	// into the various chunk functions, but that isn't too scalable I think!
	// 

	// Unfortunately we can't specify the type of custom resource, since all those
	// are defined in the GDScript side of things.
	
	//godot::Array block_types[];
	//godot::Array block_types[256];
	//godot::Dictionary block_dictionary = {};
	//int get_block_type();

	void set_material(const Ref<godot::Material> p_material);
	Ref<godot::Material> get_material() const;

	uint8_t get_block_id(const godot::String block_string_id);
};



} // Namespace manuka.

#endif // MANUKA_WORLD_H