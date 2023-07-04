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

	const int chunk_width = 32;
	const int chunk_height = 32;

	//uint8_t voxel_map[16][16][16];

	// This will be accessed as a three-dimensional array
	// using some multiplication stuff!
	// TODO: Find some way to generate the thing at runtime using chunk_width and stuff.
	std::array<uint8_t, 32768> voxel_map;

	//int* voxel_map;

	const Dictionary block_types;
	const Vector3 chunk_position;
	int world_size_in_voxels;
	int texture_atlas_size_in_blocks;
	const Dictionary texture_ids;
	const Dictionary biomes;

	//std::vector<uint8_t> voxel_map();
	//std::vector<uint8_t, 4096> voxel_map;
	//uint8_t voxel_map[4096];

	int vertex_index;

	float noise_value;
	float noise_value_3d;

	int stone;
	int air;
	int bedrock;
	int grass;
	int dirt;

protected:
	static void _bind_methods();
public:
	Chunk();
	~Chunk();
	// Remember to prepend everything with const, especially Vector3!!!
	// Declare functions here.
	void print_something(const String& thing);
	void update_mesh_data(
		const godot::Vector3& position,
		const Dictionary& block_types,
		const Vector3& chunk_position,
		int world_size_in_voxels,
		int texture_atlas_size_in_blocks,
		const Dictionary& texture_ids,
		const Dictionary& biomes);
	void populate_voxel_map(
		const Vector3& position,
		int world_size_in_voxels,
		const Dictionary& block_types,
		const Dictionary& biomes);
	void update_chunk();
	void clear_mesh_data();
	bool is_voxel_in_chunk(int x, int y, int z);
	bool check_voxel(
		const godot::Vector3& position,
		const Dictionary& block_types,
		const Vector3& chunk_position,
		int world_size_in_voxels,
		const Dictionary& biomes);
	void add_texture(
		int texture_id,
		int texture_atlas_size_in_blocks);
	uint8_t get_voxel(
		const Vector3& position,
		int world_size_in_voxels,
		const Dictionary& block_types,
		const Dictionary& biomes);

	uint8_t get_voxel_from_global_vector_3(const Vector3& pos, const Vector3& chunk_pos);

	bool is_voxel_in_world(const Vector3& position, int world_size_in_voxels);

	void set_voxel(const Vector3& pos, int block_id);
	Array get_surrounding_voxels(
		int x,
		int y,
		int z);

	int block_string_to_id(const String& block_name, const Dictionary& block_types);

	Ref<Mesh> create_mesh(); // Keep in mind: Godot likes Refs when returning some stuff.

	// Useless property functions!!!!!
	void set_block_types(const Dictionary& p_block_types);
	Dictionary get_block_types() const;

	void set_chunk_position(const Vector3& p_chunk_position);
	Vector3 get_chunk_position() const;

	void set_world_size_in_voxels(const int p_world_size_in_voxels);
	int get_world_size_in_voxels() const;

	void set_texture_atlas_size_in_blocks(const int p_texture_atlas_size);
	int get_texture_atlas_size_in_blocks() const;

	void set_texture_ids(const Dictionary& p_texture_ids);
	Dictionary get_texture_ids() const;

	void set_biomes(const Dictionary& p_biomes);
	Dictionary get_biomes() const;


}; 

} // Namespace manuka.

#endif // MANUKA_CHUNK_H