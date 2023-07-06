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
#include "chunk.h"

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

	
	//bool check_for_voxel(const Vector3& pos, int chunk_width, int world_size_in_chunks, int chunk_height, const Array& chunks, const Dictionary& block_types);
	//bool is_chunk_in_world(const Vector2i& coord, int world_size_in_chunks);


	uint8_t get_block_id(const godot::String block_string_id);
};



} // Namespace manuka.

#endif // MANUKA_WORLD_H