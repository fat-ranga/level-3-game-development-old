// Define the class macro for this thing.
#ifndef MANUKA_WORLD_H
#define MANUKA_WORLD_H

// Godot stuff that we're using.
#include <godot_cpp/classes/control.hpp>
#include <godot_cpp/classes/global_constants.hpp>
#include <godot_cpp/core/binder_common.hpp>
#include <godot_cpp/classes/node3d.hpp>

using namespace godot;

namespace manuka {
	class World : public Node3D {
		GDCLASS(World, Node3D);
		// Vertex positions that make up each face.
	protected:
		static void _bind_methods();
	public:
		// Array of vertex positions, this is what we access.
		static const godot::Vector3 VOXEL_VERTICES[8];
		// Array of the faces that make up a cube.
		static const int VOXEL_TRIS[6][4];
		// TODO:
		static const godot::Vector3 FACE_CHECKS[6];
		//
		static const godot::Vector2 VOXEL_UVS[4];
	};

} // Namespace manuka.

#endif // MANUKA_VOXEL_DATA_H