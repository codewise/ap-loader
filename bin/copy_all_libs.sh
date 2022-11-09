#! /bin/sh
# ./copy_all_libs.sh <base_dir> <artifact version, like 2.8.3-all>

set -e

OWN_DIR=$(dirname "$0")

# extract the version without the platform suffix
version=$(echo "$2" | cut -d '-' -f 1)
echo "version: $version"
cd "$1" || exit 1
rm -fr target/classes/libs
mkdir -p target/classes/libs
for f in ap-releases/async-profiler-$version-*; do
  if (echo "$f" | grep 'code' || echo "$f" | grep ".tar.gz" || echo "$f" | grep ".zip"); then
    continue
  fi
  # extract the platform suffix
  platform=$(echo "$f" | cut -d '-' -f 5-10)
  # copy the library
  echo "Copying $f/build/libasyncProfiler.so for platform $platform"
  cp "$f/build/libasyncProfiler.so" "target/classes/libs/libasyncProfiler-$version-$platform.so"
  echo "Copying $f/build/jattach for platform $platform"
  cp "$f/build/jattach" "target/classes/libs/jattach-$version-$platform"
done
first_folder=$(echo ap-releases/async-profiler-$version-linux* | cut -d " " -f 1)
# copy the converter and profile.sh
echo "Copy $first_folder/build/converter.jar"
cp "$first_folder/build/converter.jar" "target/classes/libs/converter-$version.jar"
echo "Copy $first_folder/profiler.sh"
cp "$first_folder/profiler.sh" "target/classes/libs/profiler-$version.sh"
python3 "$OWN_DIR/profile_processor.py" "target/classes/libs/profiler-$version.sh"
# extract the async-profiler JAR
echo "Extracting $first_folder/build/async-profiler.jar"
python3 "$OWN_DIR/timestamp.py" > "target/classes/libs/ap-timestamp-$version"
echo "$version" > target/classes/libs/ap-version
unzip -o "$first_folder/build/async-profiler*" "*.class" -d "target/classes"
cp ap-releases/async-profiler-$version-code/src/api/one/profiler/*.java src/main/java/one/profiler