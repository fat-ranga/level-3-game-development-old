// Define the class macro for this thing.
#ifndef MANUKA_VOXEL_DATA_H
#define MANUKA_VOXEL_DATA_H

// Godot stuff that we're using.
#include <godot_cpp/classes/control.hpp>
#include <godot_cpp/classes/global_constants.hpp>
#include <godot_cpp/core/binder_common.hpp>

using namespace godot;

namespace manuka {
class VoxelData {
public:
	// Array of vertex positions, this is what we access.
	static const godot::Vector3 VOXEL_VERTICES[8];
	// Array of the faces that make up a cube.
	static const int VOXEL_TRIS[6][4];
	// TODO: face_check_directions? Pretty much the normals of a cube.
	static const godot::Vector3 FACE_CHECKS[6];
	//
	static const godot::Vector2 VOXEL_UVS[4];
};

} // Namespace manuka.

#endif // MANUKA_VOXEL_DATA_H