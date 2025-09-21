#include "config_io.h"
#include <spdlog/spdlog.h>

int main()
{
    GOOGLE_PROTOBUF_VERIFY_VERSION;

    game::LevelTable table;
    for (int i = 0; i < 1000; i++) {
        auto* l = table.add_levels();
        l->set_id(i);
        l->set_name("Level_" + std::to_string(i));
        l->set_difficulty(i % 10);
        l->set_monster_count(i * 2);
    }

    ConfigIO::SaveProtobuf(table, "data/level_table.bin");
    ConfigIO::SaveJSON(table, "data/level_table.json");

    google::protobuf::ShutdownProtobufLibrary();
    return 0;
}