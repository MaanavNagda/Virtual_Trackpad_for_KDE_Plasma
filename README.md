# Virtual Trackpad

A KDE Plasma virtual trackpad widget that provides real cursor control on Wayland systems using uinput.

![Virtual Trackpad](https://img.shields.io/badge/Platform-KDE%20Plasma%206-blue)
![Qt](https://img.shields.io/badge/Framework-Qt6-green)
![License](https://img.shields.io/badge/License-Apache%202.0-blue)

## Features

- **Real Cursor Control** - Uses uinput for actual system cursor movement on Wayland
- **Touch-Sensitive Trackpad** - Smooth cursor control via touch input
- **Mouse Click Buttons** - Left, Middle, and Right mouse click functionality
- **Always on Top** - Stays above all applications using KWin rules
- **Focus-Friendly** - Doesn't steal focus from other applications
- **Draggable Window** - Repositionable via title bar
- **Wayland Compatible** - Works perfectly on KDE Plasma Wayland

## Requirements

- KDE Plasma 6.0 or later
- Qt6 (Core, Gui, Qml, Quick)
- Linux kernel with uinput support
- User permissions for uinput device access

## Installation

### Prerequisites

1. **Add user to input group:**
   ```bash
   sudo usermod -a -G input $USER
   # Log out and log back in for changes to take effect
   ```

2. **Setup uinput permissions:**
   ```bash
   sudo chmod 660 /dev/uinput && sudo chown root:input /dev/uinput
   ```

### Build from Source

```bash
# Clone the repository
git clone https://github.com/yourusername/virtual-trackpad.git
cd virtual-trackpad

# Build the application
cd working_build
cmake ..
make

# Setup KWin rules for always-on-top behavior
chmod +x ../setup_kwin_rules.sh
../setup_kwin_rules.sh

# Run the Virtual Trackpad
./VirtualTrackpadApp
```

## Usage

### Basic Usage

1. **Launch the application:**
   ```bash
   cd working_build
   ./VirtualTrackpadApp
   ```

2. **Use the trackpad:**
   - **Drag in the touch area** to move your cursor
   - **Click L, M, R buttons** for mouse clicks
   - **Drag the title bar** to reposition the window

3. **The trackpad will:**
   - Stay above all other applications automatically
   - Not steal focus from other windows
   - Provide smooth cursor control

### Advanced Configuration

#### Sensitivity Adjustment
The cursor sensitivity can be adjusted in the source code by modifying the `m_sensitivity` value in `uinput_cursor_controller.cpp`.

#### KWin Rules
The setup script automatically configures KWin rules for:
- Forced "Keep Above" behavior
- Focus stealing prevention
- Automatic application on startup

To remove the rules:
```bash
./remove_kwin_rules.sh
```

## Technical Details

### Architecture

- **Frontend:** QML/QtQuick for the user interface
- **Backend:** C++ with uinput for system-level cursor control
- **Window Management:** KWin rules for always-on-top behavior
- **Input System:** Linux uinput for Wayland compatibility

### How It Works

1. **Touch Input:** QML MouseArea captures touch gestures
2. **Cursor Movement:** uinput sends relative mouse movements to the kernel
3. **Mouse Clicks:** uinput simulates mouse button presses/releases
4. **Window Management:** KWin compositor enforces window stacking

### File Structure

```
virtual-trackpad/
|-- working_build/                 # Build directory
|   |-- VirtualTrackpadApp         # Executable
|   |-- CMakeLists.txt             # Build configuration
|   |-- main.cpp                   # Application entry point
|   |-- uinput_cursor_controller.* # Cursor control backend
|   `-- virtual_trackpad_app.qml  # QML user interface
|-- setup_kwin_rules.sh           # KWin rules installation
|-- remove_kwin_rules.sh          # KWin rules removal
|-- package/                      # Plasma widget files (optional)
`-- README.md                     # This file
```

## Troubleshooting

### Common Issues

**"Failed to open uinput device"**
- Ensure user is in the input group
- Check uinput permissions: `ls -la /dev/uinput`
- Restart session after adding to input group

**"Cursor doesn't move"**
- Verify uinput device is accessible
- Check if ydotoold service is interfering
- Run with `strace` to debug system calls

**"Window gets hidden behind other apps"**
- Run the KWin rules setup script
- Verify rules in System Settings > Window Management > Window Rules
- Restart KWin: `qdbus6 org.kde.KWin /KWin reconfigure`

### Debug Mode

For debugging, run with verbose output:
```bash
./VirtualTrackpadApp 2>&1 | grep -E "(UInput|Moved cursor|Left click)"
```

## Development

### Building from Scratch

```bash
# Install dependencies (openSUSE)
sudo zypper install qt6-base-devel qt6-declarative-devel cmake

# Build
mkdir build && cd build
cmake ..
make
```

### Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly on Wayland
5. Submit a pull request

### Code Style

- Follow Qt coding conventions
- Use meaningful variable names
- Add comments for complex logic
- Include error handling

## License

This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- KDE Plasma community for Wayland support
- Qt developers for the excellent framework
- Linux kernel developers for uinput interface

## Changelog

### v1.0.0 (2024-04-17)
- Initial release
- uinput-based cursor control
- KWin rules for always-on-top behavior
- Touch-sensitive trackpad interface
- Mouse click functionality
- Wayland compatibility

## Support

- **Issues:** [GitHub Issues](https://github.com/yourusername/virtual-trackpad/issues)
- **Discussions:** [GitHub Discussions](https://github.com/yourusername/virtual-trackpad/discussions)

---

**Made with love for the KDE Plasma community!** <3
