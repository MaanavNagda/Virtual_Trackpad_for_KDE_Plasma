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

### Automated Installation (Recommended)

The Virtual Trackpad includes an automated installation script that handles everything:

```bash
# Clone and install
git clone https://github.com/KrivYaejerit/Virtual_Trackpad_for_KDE_Plasma.git
cd Virtual_Trackpad_for_KDE_Plasma
./install.sh
```

The installation script will:
- Check and install required dependencies
- Setup uinput device permissions
- Build the application
- Configure KWin rules for always-on-top behavior
- Create desktop entry for app menu launch
- Generate uninstall script

### Manual Installation

If you prefer manual installation:

1. **Add user to input group:**
   ```bash
   sudo usermod -a -G input $USER
   # Log out and log back in for changes to take effect
   ```

2. **Clone the repository:**
   ```bash
   git clone https://github.com/KrivYaejerit/Virtual_Trackpad_for_KDE_Plasma.git
   cd Virtual_Trackpad_for_KDE_Plasma
   ```

3. **Build the application:**
   ```bash
   cd working_build
   cmake ..
   make
   ```

4. **Setup KWin rules for always-on-top behavior:**
   ```bash
   qdbus6 org.kde.KWin /KWin reconfigure
   ```

## Usage

### Launch Options

1. **From Application Menu:**
   - Search for "Virtual Trackpad" in your application launcher
   - Launches with terminal window (required for proper environment)

2. **From Terminal:**
   ```bash
   cd ~/Virtual_Trackpad_for_KDE_Plasma/working_build
   ./VirtualTrackpad
   ```

### Using the Trackpad

1. **Basic Controls:**
   - **Drag in the touch area** to move your cursor
   - **Click L, M, R buttons** for mouse clicks
   - **Drag the title bar** to reposition the window

2. **Window Management:**
   - Right-click on the window
   - Select "More Actions" > "Keep Above Others" for persistent behavior

3. **Features:**
   - Optimized cursor sensitivity (30% of original)
   - Stays above all applications automatically
   - Doesn't steal focus from other windows
   - Works perfectly on Wayland

### Uninstallation

To completely remove the Virtual Trackpad:

```bash
cd ~/Virtual_Trackpad_for_KDE_Plasma
./remove_virtual_trackpad.sh
```

This will remove:
- Desktop entry from application menu
- KWin rules
- All project files and directories

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
Virtual_Trackpad_for_KDE_Plasma/
|-- working_build/                 # Build directory
|   |-- VirtualTrackpad            # Executable
|   |-- launch_virtual_trackpad.sh # Launcher script
|   |-- CMakeLists.txt             # Build configuration
|   |-- main.cpp                   # Application entry point
|   |-- uinput_cursor_controller.* # Cursor control backend
|   `-- virtual_trackpad_app.qml  # QML user interface
|-- install.sh                    # Automated installation script
|-- remove_virtual_trackpad.sh    # Uninstallation script
|-- CMakeLists.txt                # Main build configuration
|-- README.md                      # This file
`-- LICENSE                       # Apache 2.0 License
```

## Troubleshooting

### Common Issues

**"Failed to open uinput device"**
- Ensure user is in the input group
- Check uinput permissions: `ls -la /dev/uinput`
- Restart session after adding to input group

**"Cursor doesn't move"**
- Verify uinput device is accessible
- Check if user is in input group: `groups $USER`
- Restart session after adding to input group
- Test with terminal launch first

**"Window gets hidden behind other apps"**
- Right-click window > "More Actions" > "Keep Above Others"
- Verify KWin rules are configured
- Restart KWin: `qdbus6 org.kde.KWin /KWin reconfigure`

**"App menu launch fails"**
- Terminal window is required for proper environment
- Try launching from terminal first to test functionality
- Check desktop entry: `~/.local/share/applications/virtual-trackpad.desktop`

### Debug Mode

For debugging, run with verbose output:
```bash
cd ~/Virtual_Trackpad_for_KDE_Plasma/working_build
./VirtualTrackpad 2>&1 | grep -E "(UInput|Moved cursor|Left click)"
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

### v1.0.0 (2025-04-17)
- Initial release
- uinput-based cursor control for Wayland
- Automated installation script with dependency checking
- Optimized cursor sensitivity (30% of original)
- KWin rules for always-on-top behavior
- Touch-sensitive trackpad interface
- Mouse click functionality (L, M, R)
- Focus-friendly window management
- Complete uninstallation script
- App menu integration with terminal launcher
- Universal path compatibility for any user

## Support

- **Issues:** [GitHub Issues](https://github.com/KrivYaejerit/Virtual_Trackpad_for_KDE_Plasma/issues)
- **Discussions:** [GitHub Discussions](https://github.com/KrivYaejerit/Virtual_Trackpad_for_KDE_Plasma/discussions)

---

**Made with love for the KDE Plasma community!** <3
