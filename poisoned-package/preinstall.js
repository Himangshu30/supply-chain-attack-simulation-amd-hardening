#!/usr/bin/env node

/**
 * LAB-ONLY MALICIOUS PREINSTALL SCRIPT
 * 
 * This script runs automatically during 'npm install' and demonstrates
 * how a compromised dependency can execute arbitrary code.
 * 
 * BENIGN PAYLOAD: Only creates a test file to demonstrate compromise.
 * DO NOT MODIFY to add harmful actions.
 */

const fs = require('fs');
const path = require('path');
const os = require('os');

// ANSI color codes for terminal output
const RED = '\x1b[31m';
const YELLOW = '\x1b[33m';
const RESET = '\x1b[0m';

console.log(`${RED}[!] LAB SUPPLY-CHAIN COMPROMISE DETECTED${RESET}`);
console.log(`${YELLOW}[*] Running malicious preinstall script from @lab/malicious-util${RESET}`);

// Determine the target directory (parent project's root)
const targetDir = path.resolve(__dirname, '../../..');
const compromiseFile = path.join(targetDir, 'LAB_COMPROMISED.txt');

// Create the compromise evidence file
const compromiseData = {
  timestamp: new Date().toISOString(),
  package: '@lab/malicious-util',
  version: '0.0.1',
  message: 'LAB-ONLY: Supply-chain compromise simulation',
  system: {
    platform: os.platform(),
    hostname: os.hostname(),
    username: os.userInfo().username,
    cwd: process.cwd(),
    nodeVersion: process.version
  },
  environment: {
    PATH: process.env.PATH || 'N/A',
    HOME: process.env.HOME || 'N/A',
    npm_config_registry: process.env.npm_config_registry || 'N/A'
  },
  attack_vector: 'npm preinstall script',
  impact: 'Code execution during dependency installation',
  recommendation: 'Implement SBOM generation, dependency scanning, and CI policy gates'
};

try {
  // Write the compromise evidence file
  fs.writeFileSync(
    compromiseFile,
    JSON.stringify(compromiseData, null, 2)
  );
  
  console.log(`${RED}[✓] Created compromise evidence: ${compromiseFile}${RESET}`);
  console.log(`${YELLOW}[*] In a real attack, this could:${RESET}`);
  console.log('    - Exfiltrate environment variables (API keys, secrets)');
  console.log('    - Modify source code or configuration files');
  console.log('    - Install backdoors or persistence mechanisms');
  console.log('    - Steal credentials or sensitive data');
  console.log('    - Pivot to other systems on the network');
  console.log('');
  console.log(`${YELLOW}[*] Simulation completed successfully${RESET}`);
  
  // Also create a log file for evidence collection
  const logDir = path.join(targetDir, 'evidence');
  if (fs.existsSync(logDir)) {
    const logFile = path.join(logDir, 'compromise-log.json');
    const logEntry = {
      ...compromiseData,
      logType: 'preinstall_execution',
      loggedAt: new Date().toISOString()
    };
    fs.writeFileSync(logFile, JSON.stringify(logEntry, null, 2));
    console.log(`${RED}[✓] Evidence logged to: ${logFile}${RESET}`);
  }
  
} catch (error) {
  console.error(`${RED}[!] Failed to create compromise evidence:${RESET}`, error.message);
  // Don't fail the install - stealth is key in real attacks
}

console.log('');
