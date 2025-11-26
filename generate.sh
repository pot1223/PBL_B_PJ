#!/bin/bash

echo "🔨 Generating Hive TypeAdapters..."
flutter pub run build_runner build --delete-conflicting-outputs

echo "✅ Code generation completed!"