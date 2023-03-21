#include "world.h"

// Godot includes required for this to work.
#include <godot_cpp/variant/utility_functions.hpp>
#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/core/binder_common.hpp>

#include <godot_cpp/classes/material.hpp>

using namespace godot;

namespace manuka {

void World::_bind_methods() {
	ClassDB::bind_method(D_METHOD("set_material", "p_material"), &World::set_material);
	ClassDB::bind_method(D_METHOD("get_material"), &World::get_material);
	ClassDB::add_property("World", PropertyInfo(Variant::OBJECT, "material", godot::PROPERTY_HINT_RESOURCE_TYPE), "set_material", "get_material");
}

World::World() {

}

World::~World() {

}
void World::set_material(const Ref<godot::Material> p_material)
{
	material = p_material;
}
Ref<godot::Material> World::get_material() const
{
	return material;
}


}