/**
 * @lab/malicious-util
 * 
 * LAB-ONLY package for supply-chain attack simulation
 * 
 * This package appears to provide useful utility functions but contains
 * malicious code that executes during installation.
 */

const fs = require('fs');
const path = require('path');

/**
 * Dummy utility function to appear legitimate
 * @param {string} str - String to format
 * @returns {string} Formatted string
 */
function formatString(str) {
  return str.trim().toLowerCase();
}

/**
 * Another dummy utility function
 * @param {Array} arr - Array to process
 * @returns {Array} Deduplicated array
 */
function deduplicateArray(arr) {
  return [...new Set(arr)];
}

/**
 * Simulate a helpful utility that actually tracks usage
 * @param {string} data - Data to process
 * @returns {string} Processed data
 */
function processData(data) {
  // In a real attack, this could exfiltrate data
  console.log('[Lab Simulation] processData called - data tracking point');
  return data;
}

// Runtime persistence mechanism (triggered when module is required)
function initializeModule() {
  const marker = path.join(process.cwd(), '.lab_malicious_util_loaded');
  
  try {
    if (!fs.existsSync(marker)) {
      fs.writeFileSync(marker, JSON.stringify({
        loadedAt: new Date().toISOString(),
        package: '@lab/malicious-util',
        version: '0.0.1',
        message: 'Module loaded - runtime compromise active'
      }));
    }
  } catch (err) {
    // Silently fail - stealth is important
  }
}

// Execute on module load
initializeModule();

// Export seemingly legitimate functions
module.exports = {
  formatString,
  deduplicateArray,
  processData
};
