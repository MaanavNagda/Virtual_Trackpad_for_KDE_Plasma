#!/bin/bash

# Virtual Trackpad KWin Rules Installation Script
# This script sets up automatic "Keep Above Others" behavior for Virtual Trackpad

set -e

echo "Virtual Trackpad KWin Rules Setup"
echo "================================="

# Generate a unique ID for this rule
RULE_ID="virtual-trackpad-keep-above"

echo "Setting up KWin rule for Virtual Trackpad..."

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
echo "Reloading KWin configuration..."
qdbus6 org.kde.KWin /KWin reconfigure

echo ""
echo "KWin rule setup complete!"
echo "Virtual Trackpad will now automatically stay above other windows."
echo ""
echo "To verify: Go to System Settings > Window Management > Window Rules"
echo "To remove: Run ./remove_kwin_rules.sh"

# Create a removal script for cleanup
cat > remove_kwin_rules.sh << 'EOF'
#!/bin/bash

# Virtual Trackpad KWin Rules Removal Script

RULE_ID="virtual-trackpad-keep-above"

echo "Removing Virtual Trackpad KWin rules..."

# Remove the rule group from kwinrulesrc
kwriteconfig6 --file kwinrulesrc --group "$RULE_ID" --key description --delete
kwriteconfig6 --file kwinrulesrc --group "$RULE_ID" --key desktopfile --delete
kwriteconfig6 --file kwinrulesrc --group "$RULE_ID" --key desktopfilerule --delete
kwriteconfig6 --file kwinrulesrc --group "$RULE_ID" --key above --delete
kwriteconfig6 --file kwinrulesrc --group "$RULE_ID" --key aboverule --delete
kwriteconfig6 --file kwinrulesrc --group "$RULE_ID" --key focusstealingprevention --delete
kwriteconfig6 --file kwinrulesrc --group "$RULE_ID" --key focusstealingpreventionrule --delete

# Reload KWin configuration
qdbus6 org.kde.KWin /KWin reconfigure

echo "Virtual Trackpad KWin rules removed."
EOF

chmod +x remove_kwin_rules.sh
echo "Created remove_kwin_rules.sh for cleanup purposes."
