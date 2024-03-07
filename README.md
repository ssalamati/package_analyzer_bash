# Package Statistics Analyzer (Bash Version)

## Overview
This Bash script is designed to analyze Debian package repositories, specifically targeting the "Contents" index files. It downloads the compressed Contents file for a specified architecture from a Debian mirror, parses it, and outputs statistics about the top 10 packages containing the most files.

## Usage
1. **Provide execution permissions**:
   ```bash
   chmod +x package_statistics_analyzer.sh
   ```
2. **Run the script**:
   ```bash
    ./package_statistics_analyzer.sh <architecture>
   ```
