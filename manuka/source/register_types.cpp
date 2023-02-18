#include <gdextension_interface.h>
#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/core/defs.hpp>
#include <godot_cpp/godot.hpp>

// Include our class headers.
#include "register_types.h"
#include "test_node2d.h"
#include "voxel_data.h"
#include "chunk.h"

using namespace godot;

// Register our custom classes and stuff.
void initialise_manuka_types(ModuleInitializationLevel p_level)
{
	if (p_level != MODULE_INITIALIZATION_LEVEL_SCENE) {
		return;
	}
	// REGISTER ALL CLASSES HERE.
	ClassDB::register_class<manuka::TestNode2D>();
	ClassDB::register_class<manuka::Chunk>();
}

// Unregister them??? Apparently important for memory management or something.
void uninitialise_manuka_types(ModuleInitializationLevel p_level) {
	if (p_level != MODULE_INITIALIZATION_LEVEL_SCENE) {
		return;
	}
	// The code for that would go here, I think.
}

extern "C"
{

	// Initialisation.

	GDExtensionBool GDE_EXPORT manuka_library_init(const GDExtensionInterface *p_interface, const GDExtensionClassLibraryPtr p_library, GDExtensionInitialization *r_initialization)
	{
		GDExtensionBinding::InitObject init_obj(p_interface, p_library, r_initialization);

		init_obj.register_initializer(initialise_manuka_types);
		init_obj.register_terminator(uninitialise_manuka_types);
		init_obj.set_minimum_library_initialization_level(MODULE_INITIALIZATION_LEVEL_SCENE);

		return init_obj.init();
	}
}