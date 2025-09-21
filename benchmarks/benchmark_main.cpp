#include "config_io.h"

#include <benchmark/benchmark.h>

static void BM_LoadProtobuf(benchmark::State& state)
{
    for (auto _ : state) {
        game::LevelTable table;
        ConfigIO::LoadProtobuf(table, "data/level_table.bin");
        benchmark::DoNotOptimize(table);
    }
}
BENCHMARK(BM_LoadProtobuf);

static void BM_LoadJSON(benchmark::State& state)
{
    for (auto _ : state) {
        game::LevelTable table;
        ConfigIO::LoadJSON(table, "data/level_table.json");
        benchmark::DoNotOptimize(table);
    }
}
BENCHMARK(BM_LoadJSON);

BENCHMARK_MAIN();