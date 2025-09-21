#pragma once
#include <string>
#include "generated/level_config.pb.h"

class ConfigIO {
public:
    // 保存
    static bool SaveProtobuf(const game::LevelTable& table, const std::string& path);
    static bool SaveJSON(const game::LevelTable& table, const std::string& path);

    // 加载
    static bool LoadProtobuf(game::LevelTable& table, const std::string& path);
    static bool LoadJSON(game::LevelTable& table, const std::string& path);
};