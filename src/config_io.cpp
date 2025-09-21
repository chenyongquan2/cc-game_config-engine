#include "config_io.h"
#include <fstream>
#include <spdlog/spdlog.h>
#include <nlohmann/json.hpp>
#include <filesystem>

using json = nlohmann::json;

bool ConfigIO::SaveProtobuf(const game::LevelTable& table, const std::string& path)
{
    namespace fs = std::filesystem;
    try {
        fs::path p(path);
        if (p.has_parent_path()) {
            fs::create_directories(p.parent_path());
        }
    } catch (const std::exception& e) {
        SPDLOG_ERROR("Failed to create directories for {}: {}", path, e.what());
        return false;
    }

    std::ofstream ofs(path, std::ios::out | std::ios::binary);
    if (!ofs.is_open()) {
        SPDLOG_ERROR("Cannot open file for writing: {}", path);
        return false;
    }
    if (!table.SerializeToOstream(&ofs)) {
        SPDLOG_ERROR("Failed to serialize protobuf to file: {}", path);
        return false;
    }
    SPDLOG_INFO("Saved protobuf config: {}", path);
    return true;
}

bool ConfigIO::SaveJSON(const game::LevelTable& table, const std::string& path)
{
    namespace fs = std::filesystem;
    try {
        fs::path p(path);
        if (p.has_parent_path()) {
            fs::create_directories(p.parent_path());
        }
    } catch (const std::exception& e) {
        SPDLOG_ERROR("Failed to create directories for {}: {}", path, e.what());
        return false;
    }

    json j;
    for (const auto& level : table.levels()) {
        j["levels"].push_back({ { "id", level.id() }, { "name", level.name() }, { "difficulty", level.difficulty() },
            { "monster_count", level.monster_count() } });
    }
    std::ofstream ofs(path);
    if (!ofs.is_open()) {
        SPDLOG_ERROR("Cannot open file for writing: {}", path);
        return false;
    }
    ofs << j.dump(4);
    SPDLOG_INFO("Saved JSON config: {}", path);
    return true;
}

bool ConfigIO::LoadProtobuf(game::LevelTable& table, const std::string& path)
{
    std::ifstream ifs(path, std::ios::in | std::ios::binary);
    if (!table.ParseFromIstream(&ifs)) {
        SPDLOG_ERROR("Failed to load protobuf: {}", path);
        return false;
    }
    SPDLOG_INFO("Loaded protobuf config: {}", path);
    return true;
}

bool ConfigIO::LoadJSON(game::LevelTable& table, const std::string& path)
{
    std::ifstream ifs(path);
    if (!ifs) {
        SPDLOG_ERROR("JSON file not found: {}", path);
        return false;
    }
    json j;
    ifs >> j;

    if (!j.contains("levels") || !j["levels"].is_array()) {
        SPDLOG_ERROR("Invalid JSON format: no 'levels' array in {}", path);
        return false;
    }

    for (const auto& lvl : j["levels"]) {
        auto* l = table.add_levels();

        if (lvl.contains("id")) {
            l->set_id(lvl["id"].get<int>());
        }
        if (lvl.contains("name")) {
            l->set_name(lvl["name"].get<std::string>()); // ✅ 显式转成 std::string
        }
        if (lvl.contains("difficulty")) {
            l->set_difficulty(lvl["difficulty"].get<int>());
        }
        if (lvl.contains("monster_count")) {
            l->set_monster_count(lvl["monster_count"].get<int>());
        }
    }
    SPDLOG_INFO("Loaded JSON config: {}", path);
    return true;
}