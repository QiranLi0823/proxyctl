#!/bin/bash

CONFIG_FILE="$HOME/.proxy_config"
DEFAULT_IF_NONE="127.0.0.1:7890"

# 加载保存的配置
if [ -f "$CONFIG_FILE" ]; then
    SAVED_PROXY=$(cat "$CONFIG_FILE")
else
    SAVED_PROXY=$DEFAULT_IF_NONE
fi

case "$1" in
    on)
        # 确定目标地址：如果有第二个参数就用第二个，没有就用保存的
        TARGET_PROXY=${2:-$SAVED_PROXY}
        
        export http_proxy="http://$TARGET_PROXY"
        export https_proxy="http://$TARGET_PROXY"
        export all_proxy="socks5://$TARGET_PROXY"
        
        echo "🌐 Proxying through: $TARGET_PROXY"
        echo "🔍 Testing Google connection..."

        if curl -Is --connect-timeout 10 https://www.google.com > /dev/null; then
            echo "✅ Success! Google is reachable."
            # 如果是新地址且成功了，保存下来
            if [ "$TARGET_PROXY" != "$SAVED_PROXY" ]; then
                echo "$TARGET_PROXY" > "$CONFIG_FILE"
                echo "💾 Default proxy updated to: $TARGET_PROXY"
            fi
        else
            echo "⚠️  Failed: Connection timed out. (Check if your proxy server is running)"
        fi
        ;;

    off)
        unset http_proxy https_proxy all_proxy
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
