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


// Face check directions.
const godot::Vector3 FACE_CHECK_BACK(0.0f, 0.0f, -1.0f);
const godot::Vector3 FACE_CHECK_FRONT(0.0f, 0.0f, 1.0f);
const godot::Vector3 FACE_CHECK_TOP(0.0f, -1.0f, 0.0f);
const godot::Vector3 FACE_CHECK_BOTTOM(0.0f, 1.0f, 0.0f);
const godot::Vector3 FACE_CHECK_LEFT(-1.0f, 0.0f, 0.0f);
const godot::Vector3 FACE_CHECK_RIGHT(1.0f, 0.0f, 0.0f);

// Voxel UV co-ordinates.
const godot::Vector2 UV_0(0.0f, 0.0f);
const godot::Vector2 UV_1(0.0f, 0.0f);
const godot::Vector2 UV_2(0.0f, 0.0f);
const godot::Vector2 UV_3(0.0f, 0.0f);
const godot::Vector2 UV_4(0.0f, 0.0f);
const godot::Vector2 UV_5(0.0f, 0.0f);


namespace manuka {

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

	// Array of the faces that make up a cube.
	const int VoxelData::VOXEL_TRIS[6][6] = {
		{0, 3, 1, 1, 3, 2}, // Back Face
		{5, 6, 4, 4, 6, 7}, // Front Face
		{3, 7, 2, 2, 7, 6}, // Top Face
		{1, 5, 0, 0, 5, 4}, // Bottom Face
		{4, 7, 0, 0, 7, 3}, // Left Face
		{1, 2, 5, 5, 2, 6} // Right Face
	};

	const godot::Vector3 VoxelData::FACE_CHECKS[6] = {
		FACE_CHECK_BACK,
		FACE_CHECK_FRONT,
		FACE_CHECK_TOP,
		FACE_CHECK_BOTTOM,
		FACE_CHECK_LEFT,
		FACE_CHECK_RIGHT
	};

	const godot::Vector2 VoxelData::VOXEL_UVS[6] = {
		{0.0f, 0.0f},
		{0.0f, 1.0f},
		{1.0f, 0.0f},
		{1.0f, 0.0f},
		{0.0f, 1.0f},
		{1.0f, 1.0f}
	};

} // Namespace manuka.