BUILD_DIRECTORY="build"
BUILD_PATH="$BUILD_DIRECTORY/smoothie.lua"

build() {
    mkdir -p "$BUILD_DIRECTORY"
    squish
}

if [[ $# -eq 0 ]]; then
    echo "No arguments provided. Use `help` for usage information."
    exit 1
fi

while [[ $# -gt 0 ]]; do
    case $1 in
        help)
            echo "The Goofy aah bundler🤪 gives you these options:"
            echo "  help          🧙 Display this help message"
            echo "  build:release 👷 Build the project in release mode"
            echo "  build:debug   🐞 Build the project in debug mode"
            echo "  clean         🧹 Clean your build directory"
            exit 0
            ;;
        build:release)
            build
            luajit -b "./${BUILD_PATH}" "./${BUILD_PATH}"
            exit 0
            ;;
        build:debug)
            build
            exit 0
            ;;
        clean)
            rm -rf "$BUILD_DIRECTORY"
            exit 0
            ;;
        *)
            echo "Invalid option: $1. Use `help` for usage information."
            exit 1
            ;;
    esac
done
