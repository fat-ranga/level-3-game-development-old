#include "voxel_data.h"

// Godot includes required for this to work.
#include <godot_cpp/variant/utility_functions.hpp>
#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/classes/surface_tool.hpp>
#include <godot_cpp/classes/mesh_instance3d.hpp>

// Defines the positions of all eight vertices in a voxel.

using namespace godot;

// Vertex positions.


// Vertex positions that make up each face.




const godot::Vector2 UV_0(0.0f, 0.0f);
const godot::Vector2 UV_1(0.0f, 0.0f);
const godot::Vector2 UV_2(0.0f, 0.0f);
const godot::Vector2 UV_3(0.0f, 0.0f);
const godot::Vector2 UV_4(0.0f, 0.0f);
const godot::Vector2 UV_5(0.0f, 0.0f);


namespace manuka {

	/*
	// Array of vertex positions, this is what we access.
	const godot::Vector3 VoxelData::VOXEL_VERTICES[8] = {
		{0.0f, 0.0f, 0.0f},
		{1.0f, 0.0f, 0.0f},
		{1.0f, 1.0f, 0.0f},
		{0.0f, 1.0f, 0.0f},
		{0.0f, 0.0f, 1.0f},
		{1.0f, 0.0f, 1.0f},
		{1.0f, 1.0f, 1.0f},
		{0.0f, 1.0f, 1.0f}
	};
	*/
	// Array of vertex positions, this is what we access.
	const godot::Vector3 VoxelData::VOXEL_VERTICES[8] = {
		{0.0f, 0.0f, 0.0f},
		{1.0f, 0.0f, 0.0f},
		{1.0f, 1.0f, 0.0f},
		{0.0f, 1.0f, 0.0f},
		{0.0f, 0.0f, 1.0f},
		{1.0f, 0.0f, 1.0f},
		{1.0f, 1.0f, 1.0f},
		{0.0f, 1.0f, 1.0f}
	};

	const int VoxelData::VOXEL_TRIS[6][4] = {
		{2, 3, 1, 0}, // Back Face
		{7, 6, 4, 5}, // Front Face
		{6, 7, 2, 3}, // Top Face
		{4, 5, 0, 1}, // Bottom Face
		{3, 7, 0, 4}, // Left Face
		{6, 2, 5, 1} // Right Face
	};

	/*
	// Array of the faces that make up a cube.
	const int VoxelData::VOXEL_TRIS[6][4] = {
		{0, 3, 1, 2}, // Back Face
		{5, 6, 4, 7}, // Front Face
		{3, 7, 2, 6}, // Top Face
		{1, 5, 0, 4}, // Bottom Face
		{4, 7, 0, 3}, // Left Face
		{1, 2, 5, 6} // Right Face
	};
	*/

	const godot::Vector3 VoxelData::FACE_CHECKS[6] = {
		{0.0f, 0.0f, -1.0f},
		{0.0f, 0.0f, 1.0f},
		{0.0f, 1.0f, 0.0f},
		{0.0f, -1.0f, 0.0f},
		{-1.0f, 0.0f, 0.0f},
		{1.0f, 0.0f, 0.0f}
	};

	// Voxel UV co-ordinates.
	const godot::Vector2 VoxelData::VOXEL_UVS[4] = {
		{0.0f, 0.0f},
		{0.0f, 1.0f},
		{1.0f, 0.0f},
		{1.0f, 1.0f}
	};

} // Namespace manuka.