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
	godot::PackedVector2Array uvs;
	godot::Array surface_arrays;

	godot::PackedInt32Array triangles;

	godot::ArrayMesh array_mesh;
	Vector2 custom_position;

	const int chunk_width = 16;
	const int chunk_height = 16;

	bool voxel_map[16][16][16];
	int vertex_index;

protected:
	static void _bind_methods();
public:
	Chunk();
	~Chunk();

	// Reference to the world this chunk is parented to.
	// This is where we get a lot of our data from.

	// Declare functions here.
	void print_something(const String& thing);
	void add_voxel_data_to_chunk(const godot::Vector3& position, manuka::World *world);
	void populate_voxel_map();
	void create_mesh_data(manuka::World *world);
	bool check_voxel(const godot::Vector3& position, manuka::World *world);

	Ref<Mesh> create_mesh(); // Keep in mind: Godot likes Refs when returning stuff.
};

} // Namespace manuka.

#endif // MANUKA_CHUNK_H