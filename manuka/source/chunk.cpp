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

using namespace godot;



namespace manuka {


const int chunk_width = 16;
const int chunk_height = 16;

// Array of all block types in the chunk.
bool voxels[chunk_width][chunk_height][chunk_width];

int vertex_index = 0;
//std::vector<godot::Vector3> vertices; // PackedVector3Array instead?
//godot::PackedVector3Array vertices;
//std::vector<int> quads;
//std::vector<godot::Vector2> uvs;

// Generates the mesh for the chunk.
//godot::ArrayMesh array_mesh;
//godot::SurfaceTool surface_tool;
//godot::MeshInstance3D mesh_instance;
//godot::Array surface_arrays;
Chunk::Chunk()
{
}

Chunk::~Chunk()
{
}


void Chunk::_bind_methods() {
	// Bind methods here to be called in GDScript.
	godot::ClassDB::bind_method(godot::D_METHOD("print_something", "bruh"), &Chunk::print_something);
	godot::ClassDB::bind_method(godot::D_METHOD("do_thing"), &Chunk::do_thing);
	godot::ClassDB::bind_method(godot::D_METHOD("add_voxel_data_to_chunk"), &Chunk::add_voxel_data_to_chunk);
	godot::ClassDB::bind_method(godot::D_METHOD("create_mesh"), &Chunk::create_mesh);

	//godot::ClassDB::bind_method(godot::D_METHOD("get_array_mesh"), &Chunk::get_array_mesh);
}


// Add functionality to declared functions and stuff here.
void Chunk::print_something(const String& thing){
	godot::UtilityFunctions::print(thing);
}

void Chunk::do_thing() {
	for (int x = 0; x < chunk_width; x++){
		for (int y = 0; y < chunk_height; y++) {
			for (int z = 0; z < chunk_width; z++) {
				Chunk::add_voxel_data_to_chunk(godot::Vector3(x, y, z));
			}
		}
	}
	Chunk::create_mesh();
}

void Chunk::add_voxel_data_to_chunk(const godot::Vector3& position) {
	for (int p = 0; p < 6; p++){
		for (int i = 0; i < 6; i++) {
			int triangle_index = VoxelData::VOXEL_TRIS[p][i];
			vertices.push_back(VoxelData::VOXEL_VERTICES[triangle_index] + position);
			uvs.push_back(VoxelData::VOXEL_UVS[i]);

			vertex_index++;
		}
	}
}

Ref<Mesh> Chunk::create_mesh() {
	Ref<ArrayMesh> mesh;



	mesh.instantiate();

	surface_arrays.resize(godot::ArrayMesh::ARRAY_MAX);

	surface_arrays[godot::ArrayMesh::ARRAY_VERTEX] = { vertices };
	surface_arrays[godot::ArrayMesh::ARRAY_TEX_UV] = { uvs };

	mesh->add_surface_from_arrays(godot::Mesh::PRIMITIVE_TRIANGLES, surface_arrays);

	return mesh;

	// = array_mesh;
	//mesh_instance.set_mesh(array_mesh);
	//mesh_instance.mesh = array_mesh;
	//godot::MeshInstance3D mesh_instance

	//add_child(mesh_instance);
}

//godot::TypedArray<ArrayMesh> Chunk::get_array_mesh(){
	//godot::TypedArray<ArrayMesh> arr;
	//arr.resize(1);

	//arr[0] = array_mesh;

	//return arr;
//}


Vector2 Chunk::get_custom_position() const {
	return custom_position;
}





} // Namespace manuka.