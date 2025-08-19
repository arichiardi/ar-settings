# Hub OAuth Token Setup Guide

This guide explains how to create and configure OAuth tokens for the GitHub Hub CLI tool.

## What is Hub?

[Hub](https://github.com/github/hub) is a command-line wrapper for git that makes it easier to work with GitHub. It extends git with additional commands for GitHub-specific operations like creating pull requests, managing issues, and more.

## Creating a GitHub OAuth Token

### Method 1: Using GitHub Web Interface (Recommended)

1. **Navigate to GitHub Settings**:
   - Go to [GitHub.com](https://github.com)
   - Click your profile picture in the top right
   - Select "Settings"

2. **Access Developer Settings**:
   - Scroll down in the left sidebar
   - Click "Developer settings"
   - Click "Personal access tokens"
   - Click "Tokens (classic)" or "Fine-grained tokens" (recommended for newer GitHub features)

3. **Create New Token**:
   - Click "Generate new token" → "Generate new token (classic)" or "Generate new token" for fine-grained
   - Add a descriptive note (e.g., "Hub CLI for ar-settings")
   - Set expiration (consider 90 days or 1 year for development use)

4. **Set Required Permissions**:
   For hub CLI, you typically need these scopes:
   - `repo` - Full control of private repositories
   - `public_repo` - Access to public repositories  
   - `gist` - Create and edit gists
   - `user:email` - Access user email addresses
   - `read:org` - Read org and team membership
   - `workflow` - Update GitHub Action workflows (if needed)

5. **Copy the Token**:
   - Click "Generate token"
   - **IMPORTANT**: Copy the token immediately - you won't be able to see it again!

### Method 2: Using Hub CLI Interactive Setup

Hub can also create tokens interactively:

```bash
# This will prompt for GitHub credentials and create a token automatically
hub api user
```

## Configuring Hub with Your Token

### Option 1: Environment Variable

```bash
export GITHUB_TOKEN=your_token_here
```

Add this to your shell profile (`.bashrc`, `.zshrc`, etc.) for persistence.

### Option 2: Hub Configuration File

Create a hub configuration file:

```bash
# Create the config directory if it doesn't exist
mkdir -p ~/.config

# Create hub config file
cat > ~/.config/hub << EOF
github.com:
- user: your_github_username
  oauth_token: your_token_here
  protocol: https
EOF
```

### Option 3: Using Git Configuration

```bash
git config --global hub.protocol https
git config --global github.user your_github_username
git config --global github.token your_token_here
```

## Encrypting Hub Configuration (ar-settings specific)

This repository includes a `secret` script for encrypting sensitive configuration files. Here's how to securely store your hub configuration:

### 1. Create Your Hub Configuration

First, create your hub configuration file with your OAuth token:

```bash
cat > /tmp/hub_config << EOF
github.com:
- user: your_github_username
  oauth_token: your_actual_token_here
  protocol: https
EOF
```

### 2. Encrypt the Configuration

Use the `secret` script to encrypt your hub configuration:

```bash
# From the ar-settings repository root
./home/.local/bin/secret --backup --src /tmp/hub_config --dest ./home/.config/hub.enc
```

This will:
- Encrypt your hub configuration using AES-256-CBC
- Store it as `home/.config/hub.enc`
- Securely delete the original temporary file

### 3. Restore When Needed

To restore your hub configuration on a new machine:

```bash
# Decrypt the configuration to your home directory
./home/.local/bin/secret --restore --src ./home/.config/hub.enc --dest ~/.config/hub
```

## Testing Your Hub Setup

After configuration, test hub functionality:

```bash
# Test basic GitHub API access
hub api user

# Test repository operations
cd your_git_repo
hub browse  # Should open the repo in your browser

# Create a pull request (if you have changes)
hub pull-request -m "Test PR"
```

## Common Issues and Troubleshooting

### Token Permissions
If you get permission errors, ensure your token has the required scopes:
- Check token permissions in GitHub Settings → Developer settings → Personal access tokens
- Regenerate token with additional scopes if needed

### Configuration Location
Hub looks for configuration in this order:
1. `$HUB_CONFIG` environment variable
2. `~/.config/hub`
3. `~/.hub`

### Network Issues
If you're behind a corporate firewall:
- Use HTTPS protocol instead of SSH
- Configure git/hub to use your corporate proxy

## Security Best Practices

1. **Use Fine-grained Tokens**: Prefer fine-grained personal access tokens over classic tokens
2. **Minimal Permissions**: Only grant the permissions hub actually needs
3. **Regular Rotation**: Rotate tokens every 90 days or when team members leave
4. **Secure Storage**: Always encrypt tokens when storing in configuration repositories
5. **Environment Separation**: Use different tokens for different environments (dev/staging/prod)

## Additional Resources

- [Hub CLI Documentation](https://hub.github.com/)
- [GitHub Personal Access Tokens Documentation](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token)
- [GitHub Fine-grained Tokens](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token#creating-a-fine-grained-personal-access-token)