# Proxy Tool

A lightweight bash script for managing proxy settings in your terminal environment. Easily toggle HTTP/HTTPS/SOCKS5 proxies with automatic connection testing and configuration persistence.

## Overview

`proxy_tool.sh` (alias `px`) is a simple command-line utility that allows you to quickly enable and disable proxy settings for your shell session. It automatically tests connectivity, saves successful proxy configurations, and provides intuitive commands for managing your proxy environment.

## Features

- **One-command proxy management**: Turn proxy on/off with simple `px on` and `px off` commands
- **Automatic configuration saving**: Successfully tested proxy addresses are automatically saved for future use
- **Connection testing**: Verifies proxy connectivity by testing access to Google
- **Multiple proxy support**: Sets `http_proxy`, `https_proxy`, and `all_proxy` (SOCKS5) environment variables
- **Custom proxy addresses**: Specify any proxy address when enabling
- **Persistent default**: Stores your preferred proxy in `~/.proxy_config`
- **Fallback default**: Uses `127.0.0.1:7890` if no configuration exists

## Installation

### Option 1: Direct usage
Simply download the script and make it executable:
```bash
curl -O https://raw.githubusercontent.com/yourusername/proxy_tools/main/proxy_tool.sh
chmod +x proxy_tool.sh
```

### Option 2: System-wide installation
```bash
# Copy to a directory in your PATH
sudo cp proxy_tool.sh /usr/local/bin/px
sudo chmod +x /usr/local/bin/px
```

### Option 3: User-local installation
```bash
# Add to your ~/bin directory
mkdir -p ~/bin
cp proxy_tool.sh ~/bin/px
chmod +x ~/bin/px

# Ensure ~/bin is in your PATH (add to ~/.bashrc or ~/.zshrc)
echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

### Option 4: Alias setup (recommended)
Add an alias to your shell configuration file (`~/.bashrc`, `~/.zshrc`, or `~/.bash_profile`):
```bash
alias px='source /path/to/proxy_tool.sh'
```

**Note**: Using `source` is important because the script modifies environment variables that need to persist in your current shell session.

## Usage

### Basic commands

```bash
# Enable proxy using saved/default address
px on

# Enable proxy with a specific address
px on 192.168.1.100:8080

# Disable proxy
px off

# Show usage help and current proxy status
px
```

### Examples

1. **First-time setup with default proxy**:
   ```bash
   $ px on
   🌐 Proxying through: 127.0.0.1:7890
   🔍 Testing Google connection...
   ✅ Success! Google is reachable.
   💾 Default proxy updated to: 127.0.0.1:7890
   ```

2. **Using a custom proxy address**:
   ```bash
   $ px on 192.168.1.100:8888
   🌐 Proxying through: 192.168.1.100:8888
   🔍 Testing Google connection...
   ✅ Success! Google is reachable.
   💾 Default proxy updated to: 192.168.1.100:8888
   ```

3. **Disabling the proxy**:
   ```bash
   $ px off
   ⚠️ Proxy closed.
   ```

4. **Checking current status**:
   ```bash
   $ px
   Usage:
     px on           - Start with saved proxy (192.168.1.100:8888)
     px on [addr]    - Start with new addr and save it
     px off          - Stop proxy
   ---
   Current http_proxy: 
   ```

## Configuration

### Configuration file
The tool stores your preferred proxy address in `~/.proxy_config`. This is a plain text file containing only the proxy address (e.g., `192.168.1.100:8888`).

### Default behavior
- If `~/.proxy_config` exists, its content is used as the default proxy address
- If the file doesn't exist, `127.0.0.1:7890` is used as the fallback default
- When you successfully connect through a new proxy address, it automatically overwrites the configuration file

### Manual configuration
You can manually edit the configuration file:
```bash
echo "your-proxy-address:port" > ~/.proxy_config
```

## How It Works

### Environment variables
When you enable the proxy, the script sets these environment variables:
- `http_proxy="http://[proxy_address]"`
- `https_proxy="http://[proxy_address]"`
- `all_proxy="socks5://[proxy_address]"` (for SOCKS5 proxy)

These variables are recognized by many command-line tools including `curl`, `wget`, `git`, and various package managers.

### Connection testing
The script tests connectivity by attempting to reach `https://www.google.com` through the proxy with a 10-second timeout. If successful, the proxy address is saved; if not, an error message is displayed.

### Persistence mechanism
The script uses `source` (or `.`) to execute in the current shell context, allowing environment variable changes to persist. This is why the alias setup uses `source /path/to/proxy_tool.sh`.

## Troubleshooting

### "Command not found" error
Ensure the script is executable and in your PATH, or use the full path:
```bash
/path/to/proxy_tool.sh on
```

### Proxy changes don't persist in shell
Make sure you're using `source` or `.` to execute the script:
```bash
source /path/to/proxy_tool.sh on
```

Or set up the alias as recommended in the Installation section.

### Connection test fails
1. Verify your proxy server is running and accessible
2. Check if the proxy address and port are correct
3. Ensure you have network connectivity to the proxy server
4. Some networks may block access to Google - the script will still save the proxy if you manually verify it works

### Environment variables not recognized
Some applications may use different environment variable names. Common alternatives include:
- `HTTP_PROXY` and `HTTPS_PROXY` (uppercase)
- `ALL_PROXY` (uppercase)

You can manually set these if needed:
```bash
export HTTP_PROXY="$http_proxy"
export HTTPS_PROXY="$https_proxy"
export ALL_PROXY="$all_proxy"
```

## Compatibility

### Supported shells
- Bash
- Zsh
- Other POSIX-compliant shells

### Tested tools
The proxy variables work with:
- `curl`, `wget`
- `git`
- `apt`, `apt-get` (via `Acquire::http::Proxy` configuration)
- `npm`, `pip`, `gem` (varies by tool)
- Many other command-line utilities

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Inspired by the need for quick proxy toggling in development environments
- Thanks to all contributors who have helped improve this tool

---

**Note**: This tool only affects the current shell session and its child processes. To make proxy settings permanent across all terminals, add the appropriate `export` commands to your shell configuration file.