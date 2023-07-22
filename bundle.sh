SCRIPT_NAME="smoothie"
SCRIPT_AUTHOR="THERION"
SCRIPT_DESCRIPTION="First ever non-cringe smooth aimbot"
SCRIPT_URL="https://gitlab.com/modarnya"

BUILD_DIRECTORY="build"
ENTRY_POINT="modules/init.lua"

BUILD_PATH="$BUILD_DIRECTORY/$SCRIPT_NAME.lua"

compile() {
    if [[ "$OSTYPE" == "linux-gnu" ]]; then
        luajit -b "./${BUILD_PATH}" "./${BUILD_PATH}"
    else
        cd luajit
        ./luajit.exe -b "../${BUILD_PATH}" "../${BUILD_PATH}"
    fi
}

escape() {
    local string="$1"

    string=${string//\\/\\\\} # Escape backslashes
    string=${string//&/\\&} # Escape ampersands
    string=${string//\"/\\\"} # Escape double quotes
    string=${string//$'\n'/\\n} # Escape newlines
    string=${string//$/\\$} # Escape dollar signs
    string=${string//@/\\@} # Escape at symbols

    echo "$string"
}

prepend() {
    path="$1"
    string="$2"

    tmp=$(mktemp)
    echo "$string" > "$tmp"
    cat "$path" >> "$tmp"
    mv "$tmp" "$path"
}

build() {
    mkdir -p "$BUILD_DIRECTORY"
    cp "$ENTRY_POINT" "$BUILD_PATH"

    grep -oE -- "-- @import[[:space:]]+<([^>]+)>" "$BUILD_PATH" | while read -r line; do
        path="${line#*<}"
        path="${path%>}"

        if [[ -f "$path" ]]; then
            replacement=$(escape "$(cat "$path")")
            # echo "$replacement" > "bundle.log"
            sed -z -i "s|${line}|$replacement|" "$BUILD_PATH"
        else
            echo "Module: '$path' does not exist"
        fi
    done
}

display_usage() {
    echo "The Goofy aah bundler🤪 gives you these options:"
    echo "  help          🧙 Display this help message"
    echo "  build:release 👷 Build the project in release mode"
    echo "  build:debug   🐞 Build the project in debug mode"
    echo "  clean         🧹 Clean your build directory"
}

clean() {
    rm -rf "$BUILD_DIRECTORY"
}

build_release() {
    build

    prepend $BUILD_PATH "script_name(\"$SCRIPT_NAME\")"
    prepend $BUILD_PATH "script_author(\"$SCRIPT_AUTHOR\")"
    prepend $BUILD_PATH "script_description(\"$SCRIPT_DESCRIPTION\")"
    prepend $BUILD_PATH "script_url(\"$SCRIPT_URL\")"

    compile
}

build_debug() {
    build
}

if [[ $# -eq 0 ]]; then
    echo "No arguments provided. Use --help for usage information."
    exit 1
fi

while [[ $# -gt 0 ]]; do
    case $1 in
        help)
            display_usage
            exit 0
            ;;
        build:release)
            build_release
            exit 0
            ;;
        build:debug)
            build_debug
            exit 0
            ;;
        clean)
            clean
            exit 0
            ;;
        *)
            echo "Invalid option: $1. Use --help for usage information."
            exit 1
            ;;
    esac
done