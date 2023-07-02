#include "chunk.h"

// Godot includes required for this to work.
#include <godot_cpp/variant/utility_functions.hpp>
#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/classes/surface_tool.hpp>
#include <godot_cpp/classes/mesh_instance3d.hpp>
#include <godot_cpp/classes/array_mesh.hpp>
#include <godot_cpp/classes/fast_noise_lite.hpp>

#include <godot_cpp/classes/control.hpp>
#include <godot_cpp/classes/global_constants.hpp>
#include <godot_cpp/classes/viewport.hpp>

#include <godot_cpp/core/binder_common.hpp>

#include "voxel_data.h"
#include "world.h"

using namespace godot;



namespace manuka {
// TODO: Are constructors and deconstructors required?
Chunk::Chunk()
{

	// Array of all block types in the chunk.
	//voxel_map[chunk_width][chunk_height][chunk_width];

	//voxel_map.;
	//uint8_t fr_voxel_map* = new uint8_t[16][16][16];
	vertex_index = 0;

	

	//voxel_map = new std::array<uint8_t, chunk_width>;

	//std::array<uint8_t, 4096> voxel_map;

	//voxel_map;

	//voxel_map.

	//std::array

}

Chunk::~Chunk()
{
}

void Chunk::_bind_methods() {
	// Bind methods here to be called in GDScript.
	godot::ClassDB::bind_method(godot::D_METHOD("print_something", "bruh"), &Chunk::print_something);
	godot::ClassDB::bind_method(godot::D_METHOD("populate_voxel_map"), &Chunk::populate_voxel_map);
	godot::ClassDB::bind_method(godot::D_METHOD("add_voxel_data_to_chunk"), &Chunk::add_voxel_data_to_chunk);
	godot::ClassDB::bind_method(godot::D_METHOD("create_mesh"), &Chunk::create_mesh);
	godot::ClassDB::bind_method(godot::D_METHOD("create_mesh_data"), &Chunk::create_mesh_data);
	godot::ClassDB::bind_method(godot::D_METHOD("is_voxel_in_chunk"), &Chunk::is_voxel_in_chunk);
	godot::ClassDB::bind_method(godot::D_METHOD("get_voxel"), &Chunk::get_voxel);
	godot::ClassDB::bind_method(godot::D_METHOD("is_voxel_in_world"), &Chunk::is_voxel_in_world);
	godot::ClassDB::bind_method(godot::D_METHOD("block_string_to_id"), &Chunk::block_string_to_id);
}


// Add functionality to declared functions and stuff here.

// Test function.
void Chunk::print_something(const String& thing){

	godot::UtilityFunctions::print(thing);
	//godot::UtilityFunctions::print(world->block_types[0]);

	
}

void Chunk::populate_voxel_map(const Vector3& world_position, int world_size_in_voxels, const Dictionary& block_types) {
	for (int x = 0; x < chunk_width; x++) {
		for (int y = 0; y < chunk_height; y++) {
			for (int z = 0; z < chunk_width; z++) {
				Vector3 voxel_pos = Vector3(x, y, z);
				Vector3 final_position = voxel_pos + world_position;

				// Cache coherency or something!
				voxel_map[(x * chunk_width * chunk_height) + (y * chunk_width) + z] = get_voxel(final_position, world_size_in_voxels, block_types);
				//godot::UtilityFunctions::print((x * chunk_width * chunk_height) + (y * chunk_width) + z);
				//voxel_map[(x * 16 * 16) + (y * 16) + z] = 2;
				//voxel_map[x][y][z] = world->get_block_id("stone");// must fit into uint_8, numeric ids at runtime
			}
		}
	}
}


bool Chunk::check_voxel(const godot::Vector3& position, const Dictionary& block_types, const Vector3& chunk_position, int world_size_in_voxels) {
	int x = std::floorf(position.x);
	int y = std::floorf(position.y);
	int z = std::floorf(position.z);

	// Always draw faces at the edges of the chunk.
	if (!is_voxel_in_chunk(x, y, z)) {
		Vector3 global_voxel_position = position + chunk_position;

		Array block_type_keys = block_types.keys();

		uint8_t thing = get_voxel(global_voxel_position, world_size_in_voxels, block_types);
		godot::String edge_block_string = block_type_keys[thing];

		Dictionary edge_block_type = block_types[edge_block_string];
		return edge_block_type["is_solid"];
	}
	// This converts the block ID to a string, which we can use to
	// index into the block_types dictionary.
	godot::String block_string = block_types.keys()[voxel_map[(x * chunk_width * chunk_height) + (y * chunk_width) + z]];

	// For some reason I get a silent crash when I index a dictionary like this:
	// block_types[block_string]["is_solid"]
	// so that is why I put it into the separate 'block' dictionary before
	// accessing the 'is_solid' property.
	Dictionary block = block_types[block_string];
	return block["is_solid"];
}

void Chunk::create_mesh_data(const Dictionary& block_types, const Vector3& chunk_position, int world_size_in_voxels, int texture_atlas_size_in_blocks, const Dictionary& texture_ids) {
	//godot::UtilityFunctions::print(block_types[0]);

	for (int y = 0; y < chunk_height; y++) { // Build from the bottom up.
		for (int x = 0; x < chunk_width; x++) {
			for (int z = 0; z < chunk_width; z++) {

				int block_id = voxel_map[(x * chunk_width * chunk_height) + (y * chunk_width) + z];
				godot::String block_string = block_types.keys()[block_id];
				Dictionary block = block_types[block_string];

				// Only draw solid blocks. We don't want to render air faces.
				if (block["is_solid"]){
					Chunk::add_voxel_data_to_chunk(godot::Vector3(x, y, z), block_types, chunk_position, world_size_in_voxels, texture_atlas_size_in_blocks, texture_ids);
				}
				
			}
		}
	}
}

void Chunk::add_voxel_data_to_chunk(
	const godot::Vector3& position,
	const Dictionary& block_types,
	const Vector3& chunk_position,
	int world_size_in_voxels,
	int texture_atlas_size_in_blocks,
	const Dictionary& texture_ids) {

	// Probably correct.
	int block_id = voxel_map[((int)position[0] * chunk_width *  chunk_height) + ((int)position[1] * chunk_width) + (int)position[2]];
	godot::String block_string = block_types.keys()[block_id];
	Dictionary block = block_types[block_string];
	Array block_texture_id_array = block["texture_id"];
	
	for (int p = 0; p < 6; p++){ // 6 faces per voxel.
		if (!Chunk::check_voxel(position + VoxelData::FACE_CHECKS[p], block_types, chunk_position, world_size_in_voxels)) { // Only draw blocks that are visible.
			// These values below aren't in a for loop because there are 4 vertices
			// per face. Two triangles per face would be 6 vertices, but that results
			// in 2 duplicate verts, which is why we use 4 and do this manually instead.
			vertices.push_back(position + VoxelData::VOXEL_VERTICES[VoxelData::VOXEL_TRIS[p][0]]);
			vertices.push_back(position + VoxelData::VOXEL_VERTICES[VoxelData::VOXEL_TRIS[p][1]]);
			vertices.push_back(position + VoxelData::VOXEL_VERTICES[VoxelData::VOXEL_TRIS[p][2]]);
			vertices.push_back(position + VoxelData::VOXEL_VERTICES[VoxelData::VOXEL_TRIS[p][3]]);

			//godot::UtilityFunctions::print("after vertex push");
			//uvs.push_back(VoxelData::VOXEL_UVS[0]);
			//uvs.push_back(VoxelData::VOXEL_UVS[1]);
			//uvs.push_back(VoxelData::VOXEL_UVS[2]);
			//uvs.push_back(VoxelData::VOXEL_UVS[3]);

			
			//godot::UtilityFunctions::print();
			//godot::UtilityFunctions::print(block_texture_id_array);
			String texture_name = block_texture_id_array[p];
			int texture_id = texture_ids[texture_name];

			add_texture(texture_id, texture_atlas_size_in_blocks);
			//add_texture(2);

			triangles.push_back(vertex_index);
			triangles.push_back(vertex_index + 1);
			triangles.push_back(vertex_index + 2);
			triangles.push_back(vertex_index + 2);
			triangles.push_back(vertex_index + 1);
			triangles.push_back(vertex_index + 3);
			normals.push_back(VoxelData::FACE_CHECKS[p]);
			normals.push_back(VoxelData::FACE_CHECKS[p]);
			normals.push_back(VoxelData::FACE_CHECKS[p]);
			normals.push_back(VoxelData::FACE_CHECKS[p]);
			vertex_index += 4;

		}
	}
}

Ref<Mesh> Chunk::create_mesh() {
	Ref<ArrayMesh> mesh;

	mesh.instantiate(); // Not entirely sure what this does, but it makes this thing not crash.

	// To fit all the different enum types below.
	surface_arrays.resize(godot::ArrayMesh::ARRAY_MAX);

	surface_arrays[godot::ArrayMesh::ARRAY_VERTEX] = { vertices };
	surface_arrays[godot::ArrayMesh::ARRAY_TEX_UV] = { uvs };
	surface_arrays[godot::ArrayMesh::ARRAY_INDEX] = { triangles };
	surface_arrays[godot::ArrayMesh::ARRAY_NORMAL] = { normals };

	mesh->add_surface_from_arrays(godot::Mesh::PRIMITIVE_TRIANGLES, surface_arrays);

	return mesh;

}

void Chunk::add_texture(int texture_id = 1, int texture_atlas_size_in_blocks = 4)
{
	//godot::UtilityFunctions::print(texture_id);

	//int p_texture_id = 2;

	//float texture_atlas_size_in_blocks = 4.0;
	float normalised_block_texture_size = 1.0 / (float)texture_atlas_size_in_blocks;

	int current_row = floor(texture_id / (float)texture_atlas_size_in_blocks) + 1;

	float x = (texture_id / (float)texture_atlas_size_in_blocks) - (current_row - 1);

	float y = (current_row - 1) / (float)texture_atlas_size_in_blocks;

	//godot::UtilityFunctions::print(x);
	//godot::UtilityFunctions::print(y);

	//uvs.push_back({ x, y + normalised_block_texture_size });
	//uvs.push_back({ x + normalised_block_texture_size, y + normalised_block_texture_size });
	//uvs.push_back({ x, y });
	//uvs.push_back({ x + normalised_block_texture_size, y });

	uvs.push_back({ x + normalised_block_texture_size, y });
	uvs.push_back({ x, y });
	uvs.push_back({ x + normalised_block_texture_size, y + normalised_block_texture_size });
	uvs.push_back({ x, y + normalised_block_texture_size });
	
	
	
	
	
}


uint8_t Chunk::get_voxel(const Vector3& position, int world_size_in_voxels, const Dictionary& block_types) {
	int stone = block_string_to_id("stone", block_types);
	int air = block_string_to_id("air", block_types);
	int bedrock = block_string_to_id("bedrock", block_types);
	int grass = block_string_to_id("grass_block", block_types);
	
	int y_pos = (int)std::floor(position.y);

	/* IMMUTABLE PASS */

	if (!is_voxel_in_world(position, world_size_in_voxels)) {
		// Important that we return something transparent, otherwise
		// no meshes will be generated, since chunks at world's edge would be surrounded in
		// something solid, and therefore not visible.
		return air;
	}

	if (y_pos < 1) {
		return bedrock;
	}

	Ref<FastNoiseLite> noise;
	noise.instantiate();
	float noise_value = godot::MAX(noise->get_noise_2d(position.x, position.z), 0);

	//float temp_noise = noise->get_noise_2d(position.x, position.z);

	/* BASIC TERRAIN PASS */

	int terrain_height = (int)std::floor(chunk_height * noise_value);

	if (y_pos == terrain_height) {
		return grass;
	}
	else if(y_pos > terrain_height){
		return air;
	}
	else {
		return stone;
	}
}

bool Chunk::is_voxel_in_world(const Vector3& position, int world_size_in_voxels) {


	if (position.x < 0 || position.x >= world_size_in_voxels)
		return false;
	if (position.y < 0 || position.y >= chunk_height)
		return false;
	if (position.z < 0 || position.z >= world_size_in_voxels)
		return false;
	
	return true;
}

int Chunk::block_string_to_id(const String& block_name, const Dictionary& block_types)
{
	Dictionary block = block_types[block_name];
	int block_numeric_id = block["numeric_id"];

	return block_numeric_id;
}

bool Chunk::is_voxel_in_chunk(int x, int y, int z)
{
	if (x < 0 || x > chunk_width - 1 || y < 0 || y > chunk_height - 1 || z < 0 || z > chunk_width - 1)
		return false;
	else {
		return true;
	}
}


} // Namespace manuka.
