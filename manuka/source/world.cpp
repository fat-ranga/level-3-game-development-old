#include "world.h"

// Godot includes required for this to work.
#include <godot_cpp/variant/utility_functions.hpp>
#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/core/binder_common.hpp>

#include <godot_cpp/classes/material.hpp>

#include "chunk.h"

using namespace godot;

namespace manuka {

void World::_bind_methods() {
	//ClassDB::bind_method(D_METHOD("set_material", "p_material"), &World::set_material);
	//ClassDB::bind_method(D_METHOD("get_material"), &World::get_material);
	//ClassDB::add_property("World", PropertyInfo(Variant::OBJECT, "material", godot::PROPERTY_HINT_RESOURCE_TYPE), "set_material", "get_material");
	ClassDB::bind_method(D_METHOD("get_block_id"), &World::get_block_id);
	//ClassDB::bind_method(D_METHOD("check_for_voxel"), &World::check_for_voxel);
}

World::World() {
}

World::~World() {

}


//bool is_chunk_in_world(const Vector2i& coord, int world_size_in_chunks) {
//
//	if (coord.x > 0 && coord.x < world_size_in_chunks - 1 && coord.y > 0 && coord.y < world_size_in_chunks - 1)
//		return true;
//	else
//		return
//		false;
//
//}

uint8_t World::get_block_id(const godot::String block_string_id)
{
	return 0;
}


}