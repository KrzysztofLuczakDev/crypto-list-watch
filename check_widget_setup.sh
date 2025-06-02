#!/bin/bash

echo "🔍 Crypto List Widget Setup Checker"
echo "===================================="
echo ""

# Check if we're in the right directory
if [ ! -f "crypto-list.xcodeproj/project.pbxproj" ]; then
    echo "❌ Error: crypto-list.xcodeproj not found in current directory"
    echo "Please run this script from your project root directory"
    exit 1
fi

echo "✅ Found Xcode project file"

# Check for widget extension files
echo ""
echo "📁 Checking Widget Extension Files:"

if [ -d "crypto-list Widget Extension" ]; then
    echo "✅ Widget Extension folder exists"
    
    if [ -f "crypto-list Widget Extension/CryptoWidgetBundle.swift" ]; then
        echo "✅ CryptoWidgetBundle.swift found"
    else
        echo "❌ CryptoWidgetBundle.swift missing"
    fi
    
    if [ -f "crypto-list Widget Extension/CryptoWidget.swift" ]; then
        echo "✅ CryptoWidget.swift found"
    else
        echo "❌ CryptoWidget.swift missing"
    fi
    
    if [ -f "crypto-list Widget Extension/CryptoWidgetViews.swift" ]; then
        echo "✅ CryptoWidgetViews.swift found"
    else
        echo "❌ CryptoWidgetViews.swift missing"
    fi
    
    if [ -f "crypto-list Widget Extension/Info.plist" ]; then
        echo "✅ Info.plist found"
    else
        echo "❌ Info.plist missing"
    fi
else
    echo "❌ Widget Extension folder not found"
    echo "   You need to create the widget extension target in Xcode"
fi

# Check for shared files
echo ""
echo "📁 Checking Shared Files:"

if [ -d "Shared" ]; then
    echo "✅ Shared folder exists"
    
    if [ -f "Shared/Cryptocurrency.swift" ]; then
        echo "✅ Cryptocurrency.swift found"
    else
        echo "❌ Cryptocurrency.swift missing"
    fi
    
    if [ -f "Shared/CoinLoreService.swift" ]; then
        echo "✅ CoinLoreService.swift found"
    else
        echo "❌ CoinLoreService.swift missing"
    fi
    
    if [ -f "Shared/FavoritesManager.swift" ]; then
        echo "✅ FavoritesManager.swift found"
    else
        echo "❌ FavoritesManager.swift missing"
    fi
else
    echo "❌ Shared folder not found"
fi

# Check for required service files
echo "📋 Checking service files..."
if [ -f "crypto-list Watch App/Services/CoinLoreService.swift" ]; then
    echo "✅ CoinLoreService.swift found"
else
    echo "❌ CoinLoreService.swift missing"
fi

# Check Xcode project for widget extension target
echo ""
echo "🎯 Checking Xcode Project Configuration:"

if grep -q "crypto-list Widget Extension" crypto-list.xcodeproj/project.pbxproj; then
    echo "✅ Widget Extension target found in project"
else
    echo "❌ Widget Extension target NOT found in project"
    echo "   This is likely the main issue!"
fi

if grep -q "com.apple.widgetkit-extension" crypto-list.xcodeproj/project.pbxproj; then
    echo "✅ WidgetKit extension point configured"
else
    echo "❌ WidgetKit extension point not configured"
fi

# Check for App Groups
if grep -q "group.krzysztof-luczak.crypto-list" crypto-list.xcodeproj/project.pbxproj; then
    echo "✅ App Groups configuration found"
else
    echo "⚠️  App Groups configuration not found (may need manual setup)"
fi

echo ""
echo "📋 Summary & Next Steps:"
echo "========================"

# Count issues
issues=0

if [ ! -d "crypto-list Widget Extension" ]; then
    ((issues++))
fi

if [ ! -f "crypto-list Widget Extension/CryptoWidgetBundle.swift" ]; then
    ((issues++))
fi

if ! grep -q "crypto-list Widget Extension" crypto-list.xcodeproj/project.pbxproj; then
    ((issues++))
fi

if [ $issues -eq 0 ]; then
    echo "🎉 All checks passed! Your widget setup looks good."
    echo ""
    echo "If the widget still doesn't appear:"
    echo "1. Clean build in Xcode (Cmd+Shift+K)"
    echo "2. Build and run the widget extension scheme"
    echo "3. Check the Apple Watch simulator widget gallery"
    echo "4. See WIDGET_TROUBLESHOOTING.md for more help"
else
    echo "❌ Found $issues issue(s) that need to be fixed."
    echo ""
    echo "Most likely fixes:"
    echo "1. Add Widget Extension target in Xcode (see WIDGET_TROUBLESHOOTING.md)"
    echo "2. Add widget files to the extension target"
    echo "3. Configure App Groups for both targets"
    echo ""
    echo "📖 See WIDGET_TROUBLESHOOTING.md for detailed instructions"
fi

echo ""
echo "🔧 For detailed troubleshooting, see: WIDGET_TROUBLESHOOTING.md" 