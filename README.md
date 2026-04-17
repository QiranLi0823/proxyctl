<h1 align="center">Proxyctl</h1>

<div align="center">

[![Bash](https://img.shields.io/badge/Bash-5.0+-blue.svg)](https://www.gnu.org/software/bash/)
[![Shell](https://img.shields.io/badge/Shell-POSIX-green.svg)](https://pubs.opengroup.org/onlinepubs/9699919799/utilities/sh.html)
[![Platform](https://img.shields.io/badge/Platform-Linux-lightgrey.svg)](https://www.linux.org/)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

</div>

A lightweight bash script for managing proxy settings in your terminal environment. Easily toggle HTTP/HTTPS/SOCKS5 proxies with automatic connection testing and configuration persistence.

## Overview

`proxyctl.sh` (alias `px`) is a simple command-line utility that allows you to quickly enable and disable proxy settings for your shell session. It automatically tests connectivity, saves successful proxy configurations, and provides intuitive commands for managing your proxy environment.

## Quick Install

```bash
# Install locally (recommended)
curl -sSL https://raw.githubusercontent.com/qiranli0823/proxyctl/master/install.sh | bash

# Uninstall
curl -sSL https://raw.githubusercontent.com/qiranli0823/proxyctl/master/install.sh | bash -s -- --uninstall
```

**Note**: Replace `qiranli0823` with your GitHub username if you've forked this repository.


## Features

- **One-command proxy management**: Turn proxy on/off with simple `px on` and `px off` commands
- **Automatic configuration saving**: Successfully tested proxy addresses are automatically saved for future use
- **Connection testing**: Verifies proxy connectivity by testing access to Google
- **Multiple proxy support**: Sets `http_proxy`, `https_proxy`, and `all_proxy` (SOCKS5) environment variables
- **Custom proxy addresses**: Specify any proxy address when enabling
- **Persistent default**: Stores your preferred proxy in `~/.proxy_config`
- **Fallback default**: Uses `127.0.0.1:7890` if no configuration exists


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
The script uses `source` (or `.`) to execute in the current shell context, allowing environment variable changes to persist. This is why the alias setup uses `source /path/to/proxyctl.sh`.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Inspired by the need for quick proxy toggling in development environments
- Thanks to all contributors who have helped improve this tool

---

**Note**: This tool only affects the current shell session and its child processes. To make proxy settings permanent across all terminals, add the appropriate `export` commands to your shell configuration file.