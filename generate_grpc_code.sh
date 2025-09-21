#!/usr/bin/env bash
set -euo pipefail

# 定义路径（确保都是绝对路径）
PROTOC_PATH="/c/Users/cyq/.conan2/p/b/proto7b791aebaa927/p/bin/protoc.exe"
GRPC_CPP_PLUGIN_PATH="/c/Users/cyq/.conan2/p/b/grpcc3eec4d2ed6e8/p/bin/grpc_cpp_plugin.exe"

OUT_DIR="src/generated"
mkdir -p "$OUT_DIR"

PROTO_DIR="src/proto"

#等同于 "/c/Users/cyq/.conan2/p/b/proto7b791aebaa927/p/bin/protoc.exe" -I="src/proto" \
  # --cpp_out="src/generated" \
  # --grpc_out="src/generated" \
  # --plugin=protoc-gen-grpc="/c/Users/cyq/.conan2/p/b/grpcc3eec4d2ed6e8/p/bin/grpc_cpp_plugin.exe" \
  # "src/proto/order.proto"

# "$PROTOC_PATH" -I="$PROTO_DIR" \
#   --cpp_out="$OUT_DIR" \
#   --grpc_out="$OUT_DIR" \
#   --plugin=protoc-gen-grpc="$GRPC_CPP_PLUGIN_PATH" \
#   "$PROTO_DIR/level_config.proto"

#Note:We dont need to generate the grpc service code, so we mush delete
# --grpc_out="$OUT_DIR" --plugin=protoc-gen-grpc="$GRPC_CPP_PLUGIN_PATH"

"$PROTOC_PATH" -I="$PROTO_DIR" \
  --cpp_out="$OUT_DIR" \
  "$PROTO_DIR/level_config.proto"
