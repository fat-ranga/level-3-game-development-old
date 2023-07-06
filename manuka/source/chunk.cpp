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
//#include "world.h"

using namespace godot;



namespace manuka {

Chunk::Chunk(){
	vertex_index = 0;
	noise_value = 0.0;

	block_types;
	chunk_position;
	world_size_in_voxels;
	texture_atlas_size_in_blocks;
	texture_ids;
	biomes;
	is_voxel_map_populated = false;
	world_size_in_chunks = 10;

	noise.instantiate();
	noise->set_noise_type(godot::FastNoiseLite::TYPE_SIMPLEX);
	//noise->set_seed();



}

Chunk::~Chunk(){
}

void Chunk::_bind_methods() {

	// Property set and get functions bindings (wish I didn't have to make these!!!).
	ClassDB::bind_method(D_METHOD("set_block_types", "p_block_types"), &Chunk::set_block_types);
	ClassDB::bind_method(D_METHOD("get_block_types"), &Chunk::get_block_types);

	ClassDB::bind_method(D_METHOD("set_chunk_position", "p_chunk_position"), &Chunk::set_chunk_position);
	ClassDB::bind_method(D_METHOD("get_chunk_position"), &Chunk::get_chunk_position);

	ClassDB::bind_method(D_METHOD("set_world_size_in_voxels", "p_world_size_in_voxels"), &Chunk::set_world_size_in_voxels);
	ClassDB::bind_method(D_METHOD("get_world_size_in_voxels"), &Chunk::get_world_size_in_voxels);

	ClassDB::bind_method(D_METHOD("set_texture_atlas_size_in_blocks", "p_texture_atlas_size_in_blocks"), &Chunk::set_texture_atlas_size_in_blocks);
	ClassDB::bind_method(D_METHOD("get_texture_atlas_size_in_blocks"), &Chunk::get_texture_atlas_size_in_blocks);

	ClassDB::bind_method(D_METHOD("set_texture_ids", "p_texture_ids"), &Chunk::set_texture_ids);
	ClassDB::bind_method(D_METHOD("get_texture_ids"), &Chunk::get_texture_ids);

	ClassDB::bind_method(D_METHOD("set_biomes", "p_biomes"), &Chunk::set_biomes);
	ClassDB::bind_method(D_METHOD("get_biomes"), &Chunk::get_biomes);

	ClassDB::bind_method(D_METHOD("set_is_voxel_map_populated", "p_is_voxel_map_populated"), &Chunk::set_is_voxel_map_populated);
	ClassDB::bind_method(D_METHOD("get_is_voxel_map_populated"), &Chunk::get_is_voxel_map_populated);

	ClassDB::bind_method(D_METHOD("set_chunks", "p_chunks"), &Chunk::set_chunks);
	ClassDB::bind_method(D_METHOD("get_chunks"), &Chunk::get_chunks);


	// Bind methods here to be called in GDScript.
	godot::ClassDB::bind_method(godot::D_METHOD("print_something", "bruh"), &Chunk::print_something);
	godot::ClassDB::bind_method(godot::D_METHOD("populate_voxel_map"), &Chunk::populate_voxel_map);
	godot::ClassDB::bind_method(godot::D_METHOD("update_mesh_data"), &Chunk::update_mesh_data);
	godot::ClassDB::bind_method(godot::D_METHOD("create_mesh"), &Chunk::create_mesh);
	godot::ClassDB::bind_method(godot::D_METHOD("update_chunk"), &Chunk::update_chunk);
	godot::ClassDB::bind_method(godot::D_METHOD("is_voxel_in_chunk"), &Chunk::is_voxel_in_chunk);
	godot::ClassDB::bind_method(godot::D_METHOD("get_voxel"), &Chunk::get_voxel);
	godot::ClassDB::bind_method(godot::D_METHOD("is_voxel_in_world"), &Chunk::is_voxel_in_world);
	godot::ClassDB::bind_method(godot::D_METHOD("block_string_to_id"), &Chunk::block_string_to_id);
	godot::ClassDB::bind_method(godot::D_METHOD("clear_mesh_data"), &Chunk::clear_mesh_data);
	godot::ClassDB::bind_method(godot::D_METHOD("set_voxel"), &Chunk::set_voxel);
	godot::ClassDB::bind_method(godot::D_METHOD("get_surrounding_voxels"), &Chunk::get_surrounding_voxels);
	godot::ClassDB::bind_method(godot::D_METHOD("get_voxel_from_global_vector_3"), &Chunk::get_voxel_from_global_vector_3);
	godot::ClassDB::bind_method(godot::D_METHOD("check_for_voxel"), &Chunk::check_for_voxel);
	godot::ClassDB::bind_method(godot::D_METHOD("is_chunk_in_world"), &Chunk::is_chunk_in_world);

	// Properties and stuff. MAKE SURE THESE ALWAYS GO AFTER THE FUNCTIONS HAVE BEEN DEFINED!
	ADD_PROPERTY(PropertyInfo(Variant::DICTIONARY, "block_types"), "set_block_types", "get_block_types");
	ADD_PROPERTY(PropertyInfo(Variant::VECTOR3, "chunk_position"), "set_chunk_position", "get_chunk_position");
	ADD_PROPERTY(PropertyInfo(Variant::INT, "world_size_in_voxels"), "set_world_size_in_voxels", "get_world_size_in_voxels");
	ADD_PROPERTY(PropertyInfo(Variant::INT, "texture_atlas_size_in_blocks"), "set_texture_atlas_size_in_blocks", "get_texture_atlas_size_in_blocks");
	ADD_PROPERTY(PropertyInfo(Variant::DICTIONARY, "texture_ids"), "set_texture_ids", "get_texture_ids");
	ADD_PROPERTY(PropertyInfo(Variant::DICTIONARY, "biomes"), "set_biomes", "get_biomes");
	ADD_PROPERTY(PropertyInfo(Variant::BOOL, "is_voxel_map_populated"), "set_is_voxel_map_populated", "get_is_voxel_map_populated");
	ADD_PROPERTY(PropertyInfo(Variant::ARRAY, "chunks"), "set_chunks", "get_chunks");

}


// Add functionality to declared functions and stuff here.

// Test function.
void Chunk::print_something(const String& thing){

	godot::UtilityFunctions::print(thing);
	//godot::UtilityFunctions::print(world->block_types[0]);

	
}

void Chunk::populate_voxel_map(const Vector3& world_position) {

	stone = block_string_to_id("stone", block_types);
	air = block_string_to_id("air", block_types);
	bedrock = block_string_to_id("bedrock", block_types);
	grass = block_string_to_id("grass_block", block_types);
	dirt = block_string_to_id("dirt", block_types);

	for (int x = 0; x < chunk_width; x++) {
		for (int y = 0; y < chunk_height; y++) {
			for (int z = 0; z < chunk_width; z++) {
				Vector3 voxel_pos = Vector3(x, y, z);
				Vector3 final_position = voxel_pos + world_position;

				//voxel_map[(x * chunk_width * chunk_height) + (y * chunk_width) + z] = air;
				// Cache coherency or something!
				voxel_map[(x * chunk_width * chunk_height) + (y * chunk_width) + z] = get_voxel(final_position);
			}
		}
	}

	is_voxel_map_populated = true;
}


bool Chunk::check_voxel(const godot::Vector3& position){
	int x = std::floorf(position.x);
	int y = std::floorf(position.y);
	int z = std::floorf(position.z);

	// Always draw faces at the edges of the chunk.
	if (!is_voxel_in_chunk(x, y, z)) {
		//Vector3 global_voxel_position = position + chunk_position;



		//Array block_type_keys = block_types.keys();

		//uint8_t thing = get_voxel(global_voxel_position);
		//godot::String edge_block_string = block_type_keys[thing];

		//Dictionary edge_block_type = block_types[edge_block_string];
		//return edge_block_type["is_solid"];
		//godot::UtilityFunctions::print("chunk position: ");
		//godot::UtilityFunctions::print(chunk_position);
		//return check_for_voxel(position + chunk_position);
		return false;
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

void Chunk::update_chunk() {
	//godot::UtilityFunctions::print(block_types[0]);

	clear_mesh_data();

	for (int y = 0; y < chunk_height; y++) { // Build from the bottom up.
		for (int x = 0; x < chunk_width; x++) {
			for (int z = 0; z < chunk_width; z++) {

				int block_id = voxel_map[(x * chunk_width * chunk_height) + (y * chunk_width) + z];
				godot::String block_string = block_types.keys()[block_id];
				Dictionary block = block_types[block_string];

				// Only draw solid blocks. We don't want to render air faces.
				if (block["is_solid"]){
					Chunk::update_mesh_data(godot::Vector3(x, y, z));
				}
				
			}
		}
	}
}

bool Chunk::check_for_voxel(const Vector3& pos){
	//godot::UtilityFunctions::print("position: ");
	//godot::UtilityFunctions::print(pos);
	int x_check = std::floorf(pos.x);
	int z_check = std::floorf(pos.z);

	int x = x_check / chunk_width;
	int z = z_check / chunk_width;


	Vector2i this_chunk = Vector2i(x, z);

	Chunk* chunk = godot::Object::cast_to<Chunk>(chunks[this_chunk.x * world_size_in_chunks + this_chunk.y]);
	//Chunk* chunk = godot::Object::cast_to<Chunk>(chunks[5 * world_size_in_chunks + 5]);

	//godot::UtilityFunctions::print(chunk);
	//godot::UtilityFunctions::print("this_chunk: ");
	//godot::UtilityFunctions::print(this_chunk);

	if (!is_chunk_in_world(this_chunk) || pos.y < 0 || pos.y > chunk_height) {
		return false;
	}

	
	//godot::UtilityFunctions::print(chunk->is_voxel_map_populated);
	if (chunk->is_voxel_map_populated) {
		godot::UtilityFunctions::print("voxel map populated fr");
		uint8_t block_id = chunk->get_voxel_from_global_vector_3(pos, chunk->chunk_position);

		String block_string = block_types.keys()[block_id];
		Dictionary block = block_types[block_string];
		return block["is_solid"];
	}

	//uint8_t block_id = get_voxel(pos);

	//String block_string = block_types.keys()[block_id];
	//Dictionary block = block_types[block_string];
	//return block["is_solid"];

	// return block_types[GetVoxel(pos)].isSolid;

	return false;
}

bool Chunk::is_chunk_in_world(const Vector2i& coord) {
	if (coord.x > 0 && coord.x < world_size_in_chunks - 1 && coord.y > 0 && coord.y < world_size_in_chunks - 1)
		return true;
	else
		return
		false;
}

void Chunk::clear_mesh_data() {
	vertex_index = 0;
	vertices.clear();
	triangles.clear();
	normals.clear();
	uvs.clear();
	vertex_colours.clear();
}

void Chunk::update_mesh_data(const godot::Vector3& position) {

	

	// Probably correct.
	int block_id = voxel_map[((int)position[0] * chunk_width *  chunk_height) + ((int)position[1] * chunk_width) + (int)position[2]];
	godot::String block_string = block_types.keys()[block_id];
	Dictionary block = block_types[block_string];
	Array block_texture_id_array = block["texture_id"];
	
	for (int p = 0; p < 6; p++){ // 6 faces per voxel.
		if (!Chunk::check_voxel(position + VoxelData::FACE_CHECKS[p])) { // Only draw blocks that are visible.
			// These values below aren't in a for loop because there are 4 vertices
			// per face. Two triangles per face would be 6 vertices, but that results
			// in 2 duplicate verts, which is why we use 4 and do this manually instead.
			vertices.push_back(position + VoxelData::VOXEL_VERTICES[VoxelData::VOXEL_TRIS[p][0]]);
			vertices.push_back(position + VoxelData::VOXEL_VERTICES[VoxelData::VOXEL_TRIS[p][1]]);
			vertices.push_back(position + VoxelData::VOXEL_VERTICES[VoxelData::VOXEL_TRIS[p][2]]);
			vertices.push_back(position + VoxelData::VOXEL_VERTICES[VoxelData::VOXEL_TRIS[p][3]]);

			// TODO: Ambient occlusion?
			vertex_colours.push_back(Color(1.0, 0.5, 0.5));
			vertex_colours.push_back(Color(1.0, 1.0, 0.5));
			vertex_colours.push_back(Color(1.0, 0.5, 1.0));
			vertex_colours.push_back(Color(1.0, 1.0, 0.5));

			String texture_name = block_texture_id_array[p];
			int texture_id = texture_ids[texture_name];

			add_texture(texture_id);

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
	surface_arrays[godot::ArrayMesh::ARRAY_COLOR] = { vertex_colours };

	mesh->add_surface_from_arrays(godot::Mesh::PRIMITIVE_TRIANGLES, surface_arrays);

	return mesh;

}

void Chunk::add_texture(int texture_id = 1){
	float normalised_block_texture_size = 1.0 / (float)texture_atlas_size_in_blocks;

	int current_row = floor(texture_id / (float)texture_atlas_size_in_blocks) + 1;

	float x = (texture_id / (float)texture_atlas_size_in_blocks) - (current_row - 1);
	float y = (current_row - 1) / (float)texture_atlas_size_in_blocks;

	uvs.push_back({ x + normalised_block_texture_size, y });
	uvs.push_back({ x, y });
	uvs.push_back({ x + normalised_block_texture_size, y + normalised_block_texture_size });
	uvs.push_back({ x, y + normalised_block_texture_size });
}


uint8_t Chunk::get_voxel(const Vector3& position) {
	
	
	int y_pos = (int)std::floor(position.y);
	Dictionary biome = biomes["farmland"];
	Dictionary lodes = biome["lodes"];

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

	noise->set_frequency(0.01);
	noise_value = (noise->get_noise_2d(position.x, position.z) + 1.0) / 2.0;

	/* BASIC TERRAIN PASS */

	int terrain_height = (int)std::floor((int)biome["terrain_height"] * noise_value + (int)biome["solid_ground_height"]);

	uint8_t voxel_value = air;

	if (y_pos == terrain_height) {
		voxel_value = grass;
	}
	else if (y_pos < terrain_height && y_pos > terrain_height - 4){
		voxel_value = dirt;
	}
	else if(y_pos > terrain_height){
		return air;
	}
	else {
		voxel_value = stone;
	}

	/* CAVE PASS */

	/* SECOND PASS */

	if (voxel_value == stone) {
		for (int i = 0; i < lodes.size(); i++){
			Dictionary current_lode = lodes[lodes.keys()[i]];

			float offset = current_lode["offset"];
			float scale = current_lode["scale"];
			float low_threshold = current_lode["low_threshold"];
			float high_threshold = current_lode["high_threshold"];

			noise->set_frequency(scale);
			noise->set_domain_warp_frequency(0.1);
			noise->set_offset(Vector3(offset, offset, offset));

			if (y_pos > (int)current_lode["min_height"] && y_pos < (int)current_lode["max_height"]){
				// Only sample every 8 blocks in a volume.
				if (((int)position.x * chunk_width * chunk_height + (int)position.y * chunk_width + (int)position.z) % 2 == 0) {

					float noise_x = position.x;// +(float)current_lode["noise_offset"];
					float noise_y = position.y;// +(float)current_lode["noise_offset"];
					float noise_z = position.z;// +(float)current_lode["noise_offset"];


					noise_value_3d = noise->get_noise_3d(noise_x, noise_y, noise_z);
				}
				if (noise_value_3d > low_threshold && noise_value_3d < high_threshold) {
					String lode_block = current_lode["block_name"];

					voxel_value = (uint8_t)block_string_to_id(lode_block, block_types);
				}
			}
		}
	}

	return voxel_value;
}

uint8_t Chunk::get_voxel_from_global_vector_3(const Vector3& pos, const Vector3& chunk_pos)
{
	int x = std::floorf(pos.x);
	int y = std::floorf(pos.y);
	int z = std::floorf(pos.z);

	x -= std::floorf(chunk_pos.x);
	z -= std::floorf(chunk_pos.z);

	return voxel_map[x * chunk_width * chunk_height + y * chunk_width + z];
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

void Chunk::set_voxel(const Vector3& pos, int block_id){
	int x = std::floorf(pos.x);
	int y = std::floorf(pos.y);
	int z = std::floorf(pos.z);

	voxel_map[x * chunk_width * chunk_height + y * chunk_width + z] = (uint8_t)block_id;

	//get_surrounding_voxels(x, y, z);

	//update_chunk();
}

Array Chunk::get_surrounding_voxels(int x, int y, int z){
	Vector3 this_voxel = Vector3(x, y, z);
	
	Array voxels_to_update;

	for (int p = 0; p < 6; p++) { // 6 faces per voxel means 6 adjacent voxels.
			Vector3 current_voxel = this_voxel + VoxelData::FACE_CHECKS[p];

			if (!is_voxel_in_chunk((int)current_voxel.x, (int)current_voxel.y, (int)current_voxel.z)) {

				//godot::UtilityFunctions::print(x);
				voxels_to_update.append(current_voxel);

				//chunks[chunk_coords.x * world_size_in_voxels + chunk_coords.y]->update_chunk();
			}
	}

	return voxels_to_update;
}

int Chunk::block_string_to_id(const String& block_name, const Dictionary& block_types)
{
	Dictionary block = block_types[block_name];
	int block_numeric_id = block["numeric_id"];

	return block_numeric_id;
}

bool Chunk::is_voxel_in_chunk(int x, int y, int z)
{
	//if (x < 0 || x > chunk_width - 1 || y < 0 || y > chunk_height - 1 || z < 0 || z > chunk_width - 1)
	//	return false;
	//else {
	//	return true;
	//}
	if (x < 0 || x > chunk_width - 1) {
		//godot::UtilityFunctions::print("failed: ");
		//godot::UtilityFunctions::print(x);
		return false;
	}
	if (y < 0 || y > chunk_height - 1) {
		//godot::UtilityFunctions::print("y");
		//godot::UtilityFunctions::print(y);
		return false;
	}
	if (z < 0 || z > chunk_width - 1) {
		//godot::UtilityFunctions::print("z");
		//godot::UtilityFunctions::print(z);
		return false;
	}

	//godot::UtilityFunctions::print("success: ");
	//godot::UtilityFunctions::print(x);
	return true;
}

// Useless property functions!!!!!

void Chunk::set_block_types(const Dictionary &p_block_types){
	block_types = p_block_types;
}
Dictionary Chunk::get_block_types() const {
	return block_types;
}

void Chunk::set_chunk_position(const Vector3& p_chunk_position) {
	chunk_position = p_chunk_position;
}
Vector3 Chunk::get_chunk_position() const {
	return chunk_position;
}

void Chunk::set_world_size_in_voxels(const int p_world_size_in_voxels) {
	world_size_in_voxels = p_world_size_in_voxels;
}
int Chunk::get_world_size_in_voxels() const {
	return world_size_in_voxels;
}

void Chunk::set_texture_atlas_size_in_blocks(const int p_texture_atlas_size_in_blocks) {
	texture_atlas_size_in_blocks = p_texture_atlas_size_in_blocks;
}
int Chunk::get_texture_atlas_size_in_blocks() const {
	return texture_atlas_size_in_blocks;
}

void Chunk::set_texture_ids(const Dictionary& p_texture_ids) {
	texture_ids = p_texture_ids;
}
Dictionary Chunk::get_texture_ids() const {
	return texture_ids;
}

void Chunk::set_biomes(const Dictionary& p_biomes) {
	biomes = p_biomes;
}
Dictionary Chunk::get_biomes() const {
	return biomes;
}

void Chunk::set_is_voxel_map_populated(bool p_is_voxel_map_populated) {
	is_voxel_map_populated = p_is_voxel_map_populated;
}
bool Chunk::get_is_voxel_map_populated() const {
	return is_voxel_map_populated;
}

void Chunk::set_chunks(const Array& p_chunks) {
	chunks = p_chunks;
}
Array Chunk::get_chunks() const {
	return chunks;
}

} // Namespace manuka.
