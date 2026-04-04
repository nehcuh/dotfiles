# Security Measures

This repository implements automated security checks to prevent accidental commits of sensitive information.

## Pre-Commit Hooks

### git-secrets

We use [git-secrets](https://github.com/awslabs/git-secrets) to scan commits for common secret patterns:

- AWS keys (`AKIA...`, `A3T...`)
- API keys (`sk-...`)
- Password assignments
- Credentials in URLs
- Bearer tokens

### Custom Security Hook

Additionally, a custom pre-commit hook (`.git/hooks/pre-commit-security`) provides:

1. **Pattern-based detection** for sensitive information
2. **Template file validation** to ensure example/template files use placeholders
3. **Comprehensive scanning** of all staged files

## Blocked Patterns

The following patterns are automatically blocked:

### API Keys
- `sk-[a-zA-Z0-9]{20,}` (OpenAI-style keys)
- `[a-zA-Z0-9]{32}\.[a-zA-Z0-9]{16}` (ZAI-style keys)
- `API_KEY=`, `apikey=`, `api_key=` with 20+ character values

### Tokens
- `Bearer [a-zA-Z0-9]{20,}`
- `token=`, `TOKEN=` with 20+ character values

### Passwords
- `password=`, `PASSWORD=`, `passwd=` with 8+ character values
- `https://user:pass@host` URLs

### Private Keys
- `-----BEGIN ... PRIVATE KEY-----`
- `-----BEGIN RSA PRIVATE KEY-----`

## Template File Safety

Example and template files must use clear placeholders:
- ✅ `your-key-here`
- ✅ `your-token-here`
- ✅ `placeholder`
- ✅ `[REDACTED]`

Real-looking values in template files will be blocked.

## False Positives

If you encounter false positives, you can:

1. **Add to `.gitallowed`**: Add patterns that should be allowed
2. **Use `--no-verify`**: For one-time skips (use carefully!)
3. **Configure allowed patterns**: `git config --add secrets.allowed '<pattern>'`

## Testing

To verify security measures are working:

```bash
# This should be blocked
echo "export API_KEY=sk-test123456789012345" > test.txt
git add test.txt
git commit -m "test"  # Should fail with security error

# This should be allowed
echo "export API_KEY=your-key-here" > test.txt
git add test.txt
git commit -m "test"  # Should succeed
```

## Configuration Files

Security configuration is stored in:
- `.git/hooks/pre-commit` - Main hook entry point
- `.git/hooks/pre-commit-security` - Custom security checks
- `.git/hooks/commit-msg` - Message validation
- `.gitallowed` - Allowed false positive patterns
- `.gitignore` - Prevents tracking sensitive files

## Regular Scans

To scan existing history for secrets:

```bash
# Scan all commits
git secrets --scan

# Scan specific files
git secrets --scan stow-packs/zsh/.config/zsh/secrets.zsh.template

# Scan entire repo
git secrets --scan -r .
```

## Incident Response

If secrets are accidentally committed:

1. **Immediately revoke** the exposed credentials
2. **Remove from history**: Use `git filter-repo` to completely remove
3. **Force push carefully**: `git push --force` (warn collaborators first)
4. **Rotate credentials**: Generate new keys/tokens
5. **Update monitoring**: Check for unauthorized access

See the [security incident response guide](https://github.com/awslabs/git-secrets#incident-response) for more details.

## Maintenance

To update security patterns:

```bash
# Add new pattern
git secrets --add 'new-pattern-here'

# Add allowed pattern
git config --add secrets.allowed 'allowed-pattern'

# Verify configuration
git config --get-all secrets.patterns
git config --get-all secrets.allowed
```

---

**Remember**: Security hooks are a safety net, not a replacement for careful review. Always verify your changes before committing!
