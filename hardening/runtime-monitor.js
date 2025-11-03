#!/usr/bin/env node

/**
 * Runtime Integrity Monitoring
 * 
 * Detects suspicious file system operations and module loading at runtime.
 * This can be integrated into the application to detect active supply-chain attacks.
 */

const fs = require('fs');
const path = require('path');
const crypto = require('crypto');

// Configuration
const CONFIG = {
  suspicious_patterns: [
    /LAB_COMPROMISED/i,
    /\.lab_malicious/i,
    /@lab\//i,
    /preinstall\.js/i,
    /backdoor/i,
    /exfiltrate/i
  ],
  monitored_dirs: [
    process.cwd(),
    path.join(process.cwd(), 'node_modules')
  ],
  alert_file: path.join(process.cwd(), 'evidence', 'runtime-alerts.log'),
  check_interval: 5000 // ms
};

// Alert log
const alerts = [];

/**
 * Log an alert to file and console
 */
function logAlert(severity, message, details = {}) {
  const alert = {
    timestamp: new Date().toISOString(),
    severity,
    message,
    details,
    pid: process.pid,
    cwd: process.cwd()
  };
  
  alerts.push(alert);
  
  // Console output with colors
  const color = severity === 'CRITICAL' ? '\x1b[31m' : '\x1b[33m';
  const reset = '\x1b[0m';
  console.log(`${color}[${severity}] ${message}${reset}`);
  if (Object.keys(details).length > 0) {
    console.log(`${color}Details: ${JSON.stringify(details, null, 2)}${reset}`);
  }
  
  // Write to file
  try {
    const logDir = path.dirname(CONFIG.alert_file);
    if (!fs.existsSync(logDir)) {
      fs.mkdirSync(logDir, { recursive: true });
    }
    fs.appendFileSync(
      CONFIG.alert_file,
      JSON.stringify(alert) + '\n'
    );
  } catch (err) {
    console.error('Failed to write alert log:', err.message);
  }
}

/**
 * Check for suspicious files in monitored directories
 */
function scanForSuspiciousFiles() {
  CONFIG.monitored_dirs.forEach(dir => {
    if (!fs.existsSync(dir)) return;
    
    try {
      const files = fs.readdirSync(dir);
      
      files.forEach(file => {
        // Check against suspicious patterns
        CONFIG.suspicious_patterns.forEach(pattern => {
          if (pattern.test(file)) {
            logAlert('CRITICAL', 'Suspicious file detected', {
              file: path.join(dir, file),
              pattern: pattern.toString()
            });
          }
        });
      });
    } catch (err) {
      // Permission denied or other error - not critical
    }
  });
}

/**
 * Monitor require() calls for suspicious modules
 */
function monitorModuleLoading() {
  const Module = require('module');
  const originalRequire = Module.prototype.require;
  
  Module.prototype.require = function(id) {
    // Check if module matches suspicious patterns
    CONFIG.suspicious_patterns.forEach(pattern => {
      if (pattern.test(id)) {
        logAlert('WARNING', 'Suspicious module required', {
          module: id,
          caller: module.parent ? module.parent.filename : 'unknown'
        });
      }
    });
    
    // Call original require
    return originalRequire.apply(this, arguments);
  };
  
  console.log('[Monitor] Module loading hooks installed');
}

/**
 * Monitor file system writes
 */
function monitorFileWrites() {
  const originalWriteFileSync = fs.writeFileSync;
  const originalWriteFile = fs.writeFile;
  
  fs.writeFileSync = function(file, data, options) {
    // Check if writing suspicious files
    CONFIG.suspicious_patterns.forEach(pattern => {
      if (pattern.test(file)) {
        logAlert('CRITICAL', 'Suspicious file write detected', {
          file: file,
          size: data.length
        });
      }
    });
    
    return originalWriteFileSync.apply(this, arguments);
  };
  
  fs.writeFile = function(file, data, options, callback) {
    // Handle optional options parameter
    if (typeof options === 'function') {
      callback = options;
      options = {};
    }
    
    // Check if writing suspicious files
    CONFIG.suspicious_patterns.forEach(pattern => {
      if (pattern.test(file)) {
        logAlert('CRITICAL', 'Suspicious file write detected (async)', {
          file: file,
          size: data.length
        });
      }
    });
    
    return originalWriteFile.apply(this, arguments);
  };
  
  console.log('[Monitor] File system hooks installed');
}

/**
 * Check integrity of critical files (package.json, package-lock.json)
 */
function checkFileIntegrity() {
  const criticalFiles = [
    path.join(process.cwd(), 'package.json'),
    path.join(process.cwd(), 'package-lock.json')
  ];
  
  criticalFiles.forEach(file => {
    if (fs.existsSync(file)) {
      const content = fs.readFileSync(file, 'utf8');
      const hash = crypto.createHash('sha256').update(content).digest('hex');
      
      // Store hash on first run
      const hashKey = `hash_${path.basename(file)}`;
      if (!global[hashKey]) {
        global[hashKey] = hash;
        console.log(`[Monitor] Baseline hash for ${path.basename(file)}: ${hash.substring(0, 16)}...`);
      } else if (global[hashKey] !== hash) {
        logAlert('CRITICAL', 'Critical file modified', {
          file: path.basename(file),
          expected_hash: global[hashKey].substring(0, 16),
          actual_hash: hash.substring(0, 16)
        });
      }
    }
  });
}

/**
 * Main monitoring function
 */
function startMonitoring() {
  console.log('═══════════════════════════════════════════════════════');
  console.log('  Runtime Integrity Monitor');
  console.log('  LAB: Supply-Chain Attack Detection');
  console.log('═══════════════════════════════════════════════════════');
  console.log('');
  
  // Install hooks
  monitorModuleLoading();
  monitorFileWrites();
  
  // Initial scan
  console.log('[Monitor] Performing initial security scan...');
  scanForSuspiciousFiles();
  checkFileIntegrity();
  
  // Periodic checks
  console.log(`[Monitor] Starting periodic checks (every ${CONFIG.check_interval}ms)...`);
  setInterval(() => {
    scanForSuspiciousFiles();
    checkFileIntegrity();
  }, CONFIG.check_interval);
  
  console.log('[Monitor] Runtime monitoring active');
  console.log('');
}

/**
 * Generate summary report
 */
function generateReport() {
  console.log('');
  console.log('═══════════════════════════════════════════════════════');
  console.log('  Runtime Monitoring Report');
  console.log('═══════════════════════════════════════════════════════');
  console.log(`Total alerts: ${alerts.length}`);
  
  const critical = alerts.filter(a => a.severity === 'CRITICAL').length;
  const warnings = alerts.filter(a => a.severity === 'WARNING').length;
  
  console.log(`  - Critical: ${critical}`);
  console.log(`  - Warnings: ${warnings}`);
  console.log('');
  console.log(`Full log: ${CONFIG.alert_file}`);
  console.log('═══════════════════════════════════════════════════════');
}

// Handle process termination
process.on('SIGINT', () => {
  console.log('\n[Monitor] Shutting down...');
  generateReport();
  process.exit(0);
});

process.on('SIGTERM', () => {
  console.log('\n[Monitor] Shutting down...');
  generateReport();
  process.exit(0);
});

// Start monitoring if run directly
if (require.main === module) {
  startMonitoring();
  
  // Keep process alive
  setInterval(() => {}, 1000);
}

// Export for use as module
module.exports = {
  startMonitoring,
  logAlert,
  alerts
};
