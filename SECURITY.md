# Security Policy

## Supported Versions

| Version | Supported |
|---|---|
| 0.1.x | ✅ |

## Reporting a Vulnerability

Open a GitHub issue with label "security" or contact the maintainer directly.
Do not disclose security vulnerabilities publicly until they are resolved.

## Security Notes

- All services bind to localhost by default
- Portainer generates random admin password on first run
- Open WebUI requires first-user registration
- No external network exposure without explicit firewall rules
- API keys stored in `.env` file (excluded from git via `.gitignore`)
