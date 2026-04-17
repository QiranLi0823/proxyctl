#!/bin/bash

CONFIG_FILE="$HOME/.proxy_config"
DEFAULT_IF_NONE="127.0.0.1:7890"

# Load saved configuration
SAVED_PROXY=$(cat "$CONFIG_FILE" 2>/dev/null || echo "$DEFAULT_IF_NONE")

case "$1" in
    on)
        # Determine target address: use second argument if provided, otherwise use saved
        TARGET_PROXY=${2:-$SAVED_PROXY}
        
        export http_proxy="http://$TARGET_PROXY"
        export https_proxy="http://$TARGET_PROXY"
        export all_proxy="socks5://$TARGET_PROXY"
        
        echo "🌐 Proxying through: $TARGET_PROXY"
        echo "🔍 Testing Google connection..."

        if curl -Is --connect-timeout 10 https://www.google.com > /dev/null; then
            echo "✅ Success! Google is reachable."
            # If new address and successful, save it
            if [ "$TARGET_PROXY" != "$SAVED_PROXY" ]; then
                echo "$TARGET_PROXY" > "$CONFIG_FILE"
                echo "💾 Default proxy updated to: $TARGET_PROXY"
            fi
        else
            echo "⚠️  Failed: Connection timed out. (Check if your proxy server is running)"
        fi
        ;;

    off)
        unset http_proxy https_proxy all_proxy HTTP_PROXY HTTPS_PROXY ALL_PROXY
        echo "⚠️ Proxy closed."
        ;;

    *)
        echo "Usage:"
        echo "  px on           - Start with saved proxy ($SAVED_PROXY)"
        echo "  px on [addr]    - Start with new addr and save it"
        echo "  px off          - Stop proxy"
        echo "---"
        echo "Current http_proxy: $http_proxy"
        ;;
esac
