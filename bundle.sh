

TARGET="script.lua"
BUILD_DIRECTORY="build"
ENTRY_POINT="./main.lua"

BUILD_PATH="$BUILD_DIRECTORY/$TARGET"

mkdir -p "$BUILD_DIRECTORY"
cp "$ENTRY_POINT" "$BUILD_PATH"

replace_import() {
    local import_line=$1

    local path="${line#*<}"
    path="${path%>}"
    local file_contents=$(cat "$path")

    # Replace the import line with the file contents
    sed -e "/$import_line/r $import_path" -e "/$import_line/d"
    echo "$file_contents"
}

grep -oE -- "-- @import[[:space:]]+<([^>]+)>" "$BUILD_PATH" | while read -r line; do
    path="${line#*<}"
    path="${path%>}"

    if [[ -f "$path" ]]; then
        replaced_contents=$(replace_import "$line")
        echo "$replaced_contents"
        echo "111111111111\n\\n\n\n\n\n"
        
        ##replacement=$(sed -e 's/`/\\`/g' -e 's/\$/\\\$/g' -e 's/&/\\&/g' -e 's/"/\\"/g' -e 's/\\/\\\\/g' -e 's/#/\\#/g' <<< "$(cat "$path")")
        ## replacement=$(sed -e 's/[\/&]/\\&/g' -e 's/"/\\"/g' -e 's/[$`!#]/\\&/g' -e 's/@/\\@/g' <<< "$(cat "$path")")
        ##echo ${replacement} > log

        ##sed -i "s|${line}|{$replacement}|" "$BUILD_PATH"
        # cat "$path" "$BUILD_PATH" > temp && mv temp "$BUILD_PATH"
    else
        echo "Module: '$path' does not exist"
    fi
done
