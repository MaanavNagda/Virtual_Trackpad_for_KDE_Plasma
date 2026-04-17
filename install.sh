#!/bin/bash

# Virtual Trackpad Automated Installation Script
# This script completely sets up the Virtual Trackpad for KDE Plasma Wayland

set -e

echo "Virtual Trackpad Automated Installation"
echo "===================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_step() {
    echo -e "${BLUE}[STEP]${NC} $1"
}

# Check if running with appropriate permissions
if [ "$EUID" -eq 0 ]; then
    print_error "This script should not be run as root"
    print_error "Run it as a regular user - it will ask for sudo when needed"
    exit 1
fi

# Auto-detect and navigate to project directory
print_status "Current directory: $(pwd)"
print_status "Looking for CMakeLists.txt: $(test -f CMakeLists.txt && echo "FOUND" || echo "NOT FOUND")"

if [ ! -f "CMakeLists.txt" ]; then
    print_status "Not in project directory, searching for Virtual Trackpad..."
    
    # Check if we're in the cloned repo directory
    if [ -d "Virtual_Trackpad_for_KDE_Plasma" ]; then
        print_status "Found Virtual Trackpad directory, navigating..."
        cd Virtual_Trackpad_for_KDE_Plasma
    # Check if we're one level up from the project
    elif [ -f "Virtual_Trackpad_for_KDE_Plasma/CMakeLists.txt" ]; then
        print_status "Found Virtual Trackpad directory, navigating..."
        cd Virtual_Trackpad_for_KDE_Plasma
    # Check if we're in a subdirectory of the project
    elif [ -f "../CMakeLists.txt" ] && [ -d "../working_build" ]; then
        print_status "Found parent Virtual Trackpad directory, navigating..."
        cd ..
    else
        print_error "Could not find Virtual Trackpad project directory"
        print_error "Please run this script from the Virtual Trackpad directory"
        exit 1
    fi
    
    # Verify we're now in the correct directory
    if [ ! -f "CMakeLists.txt" ]; then
        print_error "Failed to locate Virtual Trackpad project files"
        print_error "Please run this script from the Virtual Trackpad directory"
        exit 1
    fi
    
    print_status "Successfully located Virtual Trackpad project directory"
else
    print_status "Already in Virtual Trackpad project directory"
fi

# Create working_build directory if it doesn't exist
if [ ! -d "working_build" ]; then
    print_status "Creating working_build directory..."
    mkdir -p working_build
fi

print_step "Step 1: Checking system requirements"

# Check if running on KDE Plasma
if [ -z "$KDE_SESSION_VERSION" ]; then
    print_warning "This script is optimized for KDE Plasma"
    print_warning "Other desktop environments may require manual adjustments"
fi

# Check for required packages
print_status "Checking for required packages..."

MISSING_PACKAGES=""

# Check for cmake
if ! command -v cmake &> /dev/null; then
    MISSING_PACKAGES="$MISSING_PACKAGES cmake"
fi

# Check for Qt6 development packages
if ! pkg-config --exists Qt6Core 2>/dev/null; then
    MISSING_PACKAGES="$MISSING_PACKAGES qt6-base-devel"
fi

if ! pkg-config --exists Qt6Qml 2>/dev/null; then
    MISSING_PACKAGES="$MISSING_PACKAGES qt6-declarative-devel"
fi

if [ -n "$MISSING_PACKAGES" ]; then
    print_error "Missing required packages: $MISSING_PACKAGES"
    echo ""
    echo "For openSUSE, run:"
    echo "  sudo zypper install $MISSING_PACKAGES"
    echo ""
    echo "For Ubuntu/Debian, run:"
    echo "  sudo apt install $MISSING_PACKAGES"
    echo ""
    echo "For Fedora, run:"
    echo "  sudo dnf install $MISSING_PACKAGES"
    exit 1
fi

print_step "Step 2: Setting up user permissions"

# Check if user is in input group
if groups $USER | grep -q "input"; then
    print_status "User is already in input group"
else
    print_status "Adding user to input group..."
    sudo usermod -a -G input $USER
    print_warning "You will need to log out and log back in for group changes to take effect"
    print_warning "After logging back in, run this script again"
    exit 0
fi

print_step "Step 3: Setting up uinput device permissions"

# Setup uinput permissions
print_status "Setting up uinput device permissions..."

if [ -e "/dev/uinput" ]; then
    sudo chmod 660 /dev/uinput
    sudo chown root:input /dev/uinput
    print_status "uinput device permissions set"
else
    print_warning "uinput device not found - will be created on reboot"
    print_warning "If permissions don't work after reboot, run:"
    echo "  sudo chmod 660 /dev/uinput && sudo chown root:input /dev/uinput"
fi

print_step "Step 4: Building the Virtual Trackpad"

cd working_build

# Copy necessary source files to working_build
print_status "Copying source files..."
cp ../CMakeLists.txt .
cp ../main.cpp .
cp ../uinput_cursor_controller.* . 2>/dev/null || cp ../cursor_controller.* . 2>/dev/null || echo "Using existing cursor controller files"
cp ../virtual_trackpad_app.qml .

# Verify files were copied
if [ ! -f "uinput_cursor_controller.cpp" ] && [ ! -f "cursor_controller.cpp" ]; then
    print_error "Failed to copy cursor controller files"
    exit 1
fi

print_status "Configuring build system..."
cmake .

print_status "Compiling Virtual Trackpad..."
make

if [ -f "VirtualTrackpad" ]; then
    print_status "Build successful!"
else
    print_error "Build failed - please check the error messages above"
    exit 1
fi

cd ..

print_step "Step 5: Setting up KWin rules for always-on-top behavior"

print_status "Installing KWin rules..."

# Generate a unique ID for this rule
RULE_ID="virtual-trackpad-keep-above"

# Set the window matching (Match by Desktop File Name)
kwriteconfig6 --file kwinrulesrc --group "$RULE_ID" --key description "Virtual Trackpad - Keep Above"
kwriteconfig6 --file kwinrulesrc --group "$RULE_ID" --key desktopfile "virtual-trackpad"
kwriteconfig6 --file kwinrulesrc --group "$RULE_ID" --key desktopfilerule 1

# Set "Keep Above" to True and "Force" it (rule=2 means Force)
kwriteconfig6 --file kwinrulesrc --group "$RULE_ID" --key above true
kwriteconfig6 --file kwinrulesrc --group "$RULE_ID" --key aboverule 2

# Also set focus stealing prevention (optional but recommended)
kwriteconfig6 --file kwinrulesrc --group "$RULE_ID" --key focusstealingprevention true
kwriteconfig6 --file kwinrulesrc --group "$RULE_ID" --key focusstealingpreventionrule 2

# Tell KWin to reload the configuration immediately
print_status "Reloading KWin configuration..."
qdbus6 org.kde.KWin /KWin reconfigure

print_step "Step 6: Creating desktop entry"

# Set project directory variable
PROJECT_DIR=$(pwd)

# Create launcher script
LAUNCHER_SCRIPT="$PROJECT_DIR/working_build/launch_virtual_trackpad.sh"
cat > "$LAUNCHER_SCRIPT" << EOF
#!/bin/bash
cd "$(dirname "$0")"
echo "Starting Virtual Trackpad..."
echo "Current directory: $(pwd)"
echo "Executable: $(pwd)/VirtualTrackpad"
if [ -f "./VirtualTrackpad" ]; then
    echo "Executable found, launching..."
    ./VirtualTrackpad
else
    echo "Error: VirtualTrackpad executable not found!"
    echo "Files in directory:"
    ls -la
    read -p "Press Enter to exit..."
fi
EOF

chmod +x "$LAUNCHER_SCRIPT"

# Create a desktop entry for easy launching
DESKTOP_FILE="$HOME/.local/share/applications/virtual-trackpad.desktop"
cat > "$DESKTOP_FILE" << EOF
[Desktop Entry]
Name=Virtual Trackpad
Comment=A KDE Plasma virtual trackpad widget with real cursor control on Wayland
Exec=sh -c "cd $PROJECT_DIR/working_build && ./VirtualTrackpad"
Icon=input-touchpad
Terminal=false
Type=Application
Categories=Utility;System;
StartupWMClass=virtual-trackpad
EOF

chmod +x "$DESKTOP_FILE"
print_status "Desktop entry created"

print_step "Step 7: Creating uninstall script"

# Create a removal script for cleanup
cat > remove_virtual_trackpad.sh << 'EOF'
#!/bin/bash

echo "Virtual Trackpad Uninstallation"
echo "=============================="

# Remove desktop entry
echo "Removing desktop entry..."
if [ -f "$HOME/.local/share/applications/virtual-trackpad.desktop" ]; then
    rm "$HOME/.local/share/applications/virtual-trackpad.desktop"
    echo "Desktop entry removed."
fi

# Remove KWin rules
echo "Removing KWin rules..."
if [ -f "$HOME/.config/kwinrulesrc" ]; then
    kwriteconfig6 --file kwinrulesrc --group "virtual-trackpad-keep-above" --key delete true
    qdbus6 org.kde.KWin /KWin reconfigure
    echo "KWin rules removed."
fi

# Get the current directory to delete it
PROJECT_DIR=$(pwd)
cd ..

# Remove the entire project directory
echo "Removing project directory..."
if [ -d "$PROJECT_DIR" ]; then
    rm -rf "$PROJECT_DIR"
    echo "Project directory removed: $PROJECT_DIR"
fi

echo ""
echo "Virtual Trackpad has been completely uninstalled."
echo "All files and folders have been removed."
EOF

chmod +x remove_virtual_trackpad.sh
print_status "Uninstall script created: remove_virtual_trackpad.sh"

print_step "Installation Complete!"

echo ""
echo -e "${GREEN}Virtual Trackpad has been successfully installed!${NC}"
echo ""
echo "To start the Virtual Trackpad:"
echo "  1. Run: cd ~/Virtual_Trackpad_for_KDE_Plasma/working_build && ./VirtualTrackpad"
echo "  2. Or launch from your application menu as 'Virtual Trackpad'"
echo "  3. To keep above other windows: right-click on the window, select 'More Actions', then 'Keep Above Others'"
echo ""
echo "Features:"
echo "  - Real cursor control using uinput"
echo "  - Touch-sensitive trackpad interface"
echo "  - Mouse click buttons (L, M, R)"
echo "  - Always stays above other applications"
echo "  - Doesn't steal focus from other windows"
echo ""
echo "To uninstall, run: cd ~/Virtual_Trackpad_for_KDE_Plasma && ./remove_virtual_trackpad.sh"
echo ""
echo -e "${YELLOW}Important:${NC} If you were just added to the input group,"
echo "you may need to log out and log back in for cursor control to work."
echo ""
echo -e "${GREEN}Enjoy your Virtual Trackpad!${NC}"
