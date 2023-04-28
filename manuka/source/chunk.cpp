#include "chunk.h"

// Godot includes required for this to work.
#include <godot_cpp/variant/utility_functions.hpp>
#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/classes/surface_tool.hpp>
#include <godot_cpp/classes/mesh_instance3d.hpp>
#include <godot_cpp/classes/array_mesh.hpp>

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
	//voxel_map[16][16][16];

	vertex_index = 0;
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
}


// Add functionality to declared functions and stuff here.

// Test function.
void Chunk::print_something(const String& thing){

	godot::UtilityFunctions::print(thing);
	//godot::UtilityFunctions::print(world->block_types[0]);

	
}

void Chunk::populate_voxel_map() {
	for (int x = 0; x < chunk_width; x++) {
		for (int y = 0; y < chunk_height; y++) {
			for (int z = 0; z < chunk_width; z++) {
				voxel_map[x][y][z] = 0;
				//voxel_map[x][y][z] = true;
				//voxel_map[x][y][z] = world->get_block_id("stone");// must fit into uint_8, numeric ids at runtime
			}
		}
	}
}

bool Chunk::check_voxel(const godot::Vector3& position) {//TODO: maybe change this to a generic Node3D to get data from?
	int x = std::floorf(position.x);
	int y = std::floorf(position.y);
	int z = std::floorf(position.z);

	// Always draw faces at the edges of the chunk.
	if (x < 0 || x > chunk_width - 1 || y < 0 || y > chunk_height - 1 || z < 0 || z > chunk_width - 1)
		return false;

	//return world->block_types[voxel_map[x][y][z]].is_solid;
	//return world->is_block_solid(voxel_map[x][y][z]); // checks the is_solid property of the block id (uint8_t)
	//return world->get_block_property(voxel_map[x][y][z], "is_solid")
	//return world->block_types[voxel_map[x][y][z]].is_solid;
	//return world->get_block_type(voxel_map[x][y][z]).is_solid;
	//return false;
	//return world->call()?;
	// //
	// //
	// 
	// 
	// 
	//return world->block_types[voxel_map[x][y][z]].is_solid
	switch (voxel_map[x][y][z]) {
	case 0:
		return true;
	default:
		return false;
	}
	//return voxel_map[x][y][z];
}

void Chunk::create_mesh_data() {
	for (int y = 0; y < chunk_width; y++) { // Build from the bottom up.
		for (int x = 0; x < chunk_height; x++) {
			for (int z = 0; z < chunk_width; z++) {
				Chunk::add_voxel_data_to_chunk(godot::Vector3(x, y, z));
			}
		}
	}
}

void Chunk::add_voxel_data_to_chunk(const godot::Vector3& position) {
	for (int p = 0; p < 6; p++){ // 6 faces per voxel.
		if (!Chunk::check_voxel(position + VoxelData::FACE_CHECKS[p])) { // Only draw blocks that are visible.
			// These values below aren't in a for loop because there are 4 vertices
			// per face. Two triangles per face would be 6 vertices, but that results
			// in 2 duplicate verts, which is why we use 4 and do this manually instead.
			vertices.push_back(position + VoxelData::VOXEL_VERTICES[VoxelData::VOXEL_TRIS[p][0]]);
			vertices.push_back(position + VoxelData::VOXEL_VERTICES[VoxelData::VOXEL_TRIS[p][1]]);
			vertices.push_back(position + VoxelData::VOXEL_VERTICES[VoxelData::VOXEL_TRIS[p][2]]);
			vertices.push_back(position + VoxelData::VOXEL_VERTICES[VoxelData::VOXEL_TRIS[p][3]]);
			uvs.push_back(VoxelData::VOXEL_UVS[0]);
			uvs.push_back(VoxelData::VOXEL_UVS[1]);
			uvs.push_back(VoxelData::VOXEL_UVS[2]);
			uvs.push_back(VoxelData::VOXEL_UVS[3]);
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
	// TODO: add normals as well
	surface_arrays[godot::ArrayMesh::ARRAY_NORMAL] = { normals };

	mesh->add_surface_from_arrays(godot::Mesh::PRIMITIVE_TRIANGLES, surface_arrays);

	return mesh;

}




} // Namespace manuka.
