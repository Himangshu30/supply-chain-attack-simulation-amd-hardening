# Private NPM Registry (Verdaccio)

⚠️ **LAB-ONLY** - Private registry for supply-chain attack simulation.

## Overview

This directory contains the configuration for a private npm registry using Verdaccio. This registry hosts the malicious `@lab/malicious-util` package in an isolated environment.

## Quick Start

### Start the Registry

```bash
./start-registry.sh
```

The registry will be available at:
- API: http://localhost:4873
- Web UI: http://localhost:4873

### Configure npm Client

Point your npm client to the private registry:

```bash
# Set registry for @lab scoped packages only (recommended)
npm config set @lab:registry http://localhost:4873

# Or set as default registry for all packages (use with caution)
npm set registry http://localhost:4873
```

### Create User (Optional)

```bash
npm adduser --registry http://localhost:4873
```

Default credentials (if needed):
- Username: `lab-admin`
- Password: `lab-password`
- Email: `lab@example.com`

### Publish Packages

```bash
cd ../poisoned-package
npm publish --registry http://localhost:4873
```

### Stop the Registry

```bash
./stop-registry.sh
```

### Clean Up Everything

```bash
docker-compose down -v
rm -rf storage/*
```

## Directory Structure

```
registry/
├── docker-compose.yml      # Docker Compose configuration
├── config/
│   └── config.yaml         # Verdaccio configuration
├── storage/                # Package storage (created automatically)
│   ├── data/              # npm packages
│   └── htpasswd           # User credentials
├── plugins/                # Verdaccio plugins (if needed)
├── start-registry.sh       # Start script
├── stop-registry.sh        # Stop script
└── README.md              # This file
```

## Configuration

The `config/config.yaml` file contains:

- Package access rules (all users can read/write `@lab/*` packages)
- Uplink to official npm registry (for legitimate dependencies)
- Authentication settings
- Logging configuration

## Security Notes

- This registry is **NOT SECURE** and should only be used in isolated lab environments
- Do not expose port 4873 to public networks
- Do not use production credentials
- All `@lab/*` packages are lab-only and should never be published to public registries

## Troubleshooting

### Registry won't start

```bash
# Check logs
docker-compose logs

# Restart with clean state
docker-compose down -v
./start-registry.sh
```

### Cannot publish packages

```bash
# Ensure you're authenticated
npm adduser --registry http://localhost:4873

# Check permissions
ls -la storage/
```

### Packages not installing from private registry

```bash
# Verify registry is running
curl http://localhost:4873

# Check npm configuration
npm config get registry
npm config get @lab:registry

# Clear npm cache
npm cache clean --force
```

## References

- [Verdaccio Documentation](https://verdaccio.org/docs/what-is-verdaccio)
- [npm Registry Configuration](https://docs.npmjs.com/cli/v9/using-npm/registry)
