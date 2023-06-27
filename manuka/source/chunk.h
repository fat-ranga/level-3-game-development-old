// Define the class macro for this thing.
#ifndef MANUKA_CHUNK_H
#define MANUKA_CHUNK_H

// Godot stuff that we're using.
#include <godot_cpp/classes/control.hpp>
#include <godot_cpp/classes/global_constants.hpp>
#include <godot_cpp/core/binder_common.hpp>

#include <godot_cpp/classes/static_body3d.hpp>
#include <godot_cpp/classes/mesh_instance3d.hpp>
#include <godot_cpp/classes/array_mesh.hpp>

#include "world.h"

using namespace godot;

namespace manuka {
class Chunk : public MeshInstance3D{
	GDCLASS(Chunk, MeshInstance3D)

	godot::PackedVector3Array vertices;
	godot::PackedVector3Array normals;
	godot::PackedVector2Array uvs;
	godot::Array surface_arrays;

	godot::PackedInt32Array triangles;

	godot::ArrayMesh array_mesh;
	Vector2 custom_position;

	const int chunk_width = 16;
	const int chunk_height = 16;

	//uint8_t voxel_map[16][16][16];

	// This will be accessed as a three-dimensional array
	// using some multiplication stuff!
	// TODO: Find some way to generate the thing at runtime using chunk_width and stuff.
	std::array<uint8_t, 4096> voxel_map;

	//int* voxel_map;

	//std::vector<uint8_t> voxel_map();
	//std::vector<uint8_t, 4096> voxel_map;
	//uint8_t voxel_map[4096];

	int vertex_index;

protected:
	static void _bind_methods();
public:
	Chunk();
	~Chunk();
	// Remember to prepend everything with const, especially Vector3!!!
	// Declare functions here.
	void print_something(const String& thing);
	void add_voxel_data_to_chunk(
		const godot::Vector3& position,
		const Dictionary& block_types);
	void populate_voxel_map(
		const Vector3& position,
		int world_size_in_voxels,
		const Dictionary block_types);
	void create_mesh_data(const Dictionary& block_types);
	bool is_voxel_in_chunk(int x, int y, int z);
	bool check_voxel(
		const godot::Vector3& position,
		const Dictionary& block_types);
	void add_texture(int texture_id);
	uint8_t get_voxel(
		const Vector3& position,
		int world_size_in_voxels,
		const Dictionary block_types);
	bool is_voxel_in_world(const Vector3& position, int world_size_in_voxels);

	// Stuff for getting block data and stuff.
	

	//Dictionary get_voxel_data_from_string(const String voxel_name, const Dictionary block_types) {
	//	if (block_types.has(voxel_name) == true) {
	//		return block_types[voxel_name];
	//	}
	//		
	//	return null;
	//}
		

	//func get_voxel_data_from_int(voxel_integer) :
	//	return voxel_dictionary[voxel_list[voxel_integer]];

	//func get_voxel_int_from_string(voxel_name) :
	//	return voxel_list.find(voxel_name);

	Ref<Mesh> create_mesh(); // Keep in mind: Godot likes Refs when returning stuff.
};

} // Namespace manuka.

#endif // MANUKA_CHUNK_H