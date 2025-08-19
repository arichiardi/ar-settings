# Hub OAuth Quick Reference

## Quick Setup

```bash
# Show how to create GitHub token
./home/.local/bin/setup-hub-oauth --info

# Interactive setup (creates encrypted config)
./home/.local/bin/setup-hub-oauth
```

## Manual Commands

```bash
# Create GitHub token at: https://github.com/settings/tokens
# Required scopes: repo, public_repo, gist, user:email, read:org

# Create hub config manually
mkdir -p ~/.config
cat > ~/.config/hub << EOF
github.com:
- user: your_username
  oauth_token: your_token
  protocol: https
EOF

# Encrypt existing config
./home/.local/bin/secret --backup --src ~/.config/hub --dest ./home/.config/hub.enc

# Restore encrypted config
./home/.local/bin/secret --restore --src ./home/.config/hub.enc --dest ~/.config/hub
```

## Test Hub Setup

```bash
hub api user          # Test API access
hub browse            # Open repo in browser
hub pull-request      # Create PR
```

## Troubleshooting

- **Permission errors**: Check token scopes in GitHub settings
- **Config not found**: Verify `~/.config/hub` exists and has correct format  
- **Network issues**: Use HTTPS protocol, check firewall/proxy settings

For detailed instructions, see [docs/hub-oauth-setup.md](hub-oauth-setup.md)