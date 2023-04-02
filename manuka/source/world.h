// Define the class macro for this thing.
#ifndef MANUKA_WORLD_H
#define MANUKA_WORLD_H

// Godot stuff that we're using.
#include <godot_cpp/classes/control.hpp>
#include <godot_cpp/classes/global_constants.hpp>
#include <godot_cpp/core/binder_common.hpp>

#include <godot_cpp/classes/node3d.hpp>
#include <godot_cpp/classes/material.hpp>

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

	uint8_t get_block_id(const godot::String p_name);
	//bool is_block_solid(const uint8_t p_block_id);

	//godot::Dictionary block_types;

	void set_material(const Ref<godot::Material> p_material);
	Ref<godot::Material> get_material() const;
};



} // Namespace manuka.

#endif // MANUKA_WORLD_H