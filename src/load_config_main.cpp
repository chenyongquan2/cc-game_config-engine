#include "config_io.h"
#include <spdlog/spdlog.h>

int main()
{
    GOOGLE_PROTOBUF_VERIFY_VERSION;

    game::LevelTable table;

    // 加载 Protobuf 配置
    if (ConfigIO::LoadProtobuf(table, "data/level_table.bin")) {
        SPDLOG_INFO("Protobuf Levels Count = {}", table.levels_size());
        SPDLOG_INFO("First Level Name = {}", table.levels(0).name());
    }

    // 加载 JSON 配置
    table.Clear();
    if (ConfigIO::LoadJSON(table, "data/level_table.json")) {
        SPDLOG_INFO("JSON Levels Count = {}", table.levels_size());
        SPDLOG_INFO("First Level Name = {}", table.levels(0).name());
    }

    google::protobuf::ShutdownProtobufLibrary();
    return 0;
}