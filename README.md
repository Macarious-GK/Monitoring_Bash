# System Resource Monitoring Script

## Description
- The System Resource Monitoring Script is a powerful and customizable tool for tracking the health of a Linux system. It collects critical system metrics, generates detailed reports, and alerts administrators when resource usage surpasses predefined thresholds.
- It aims to assist system administrators in ensuring the smooth operation of servers by tracking disk usage, CPU load, memory consumption, and running processes.

## Packages 
```bash 

sudo apt install stress-ng

```
## Features

- **Disk Usage Monitoring**: Monitors disk usage and alerts if the disk usage exceeds a defined threshold.
- **CPU Usage Monitoring**: Reports current CPU usage percentage.
- **Memory Usage Monitoring**: Displays memory usage statistics, including total, used, and free memory.
- **Top Processes Monitoring**: Displays the top `n` processes sorted by CPU or memory usage.

## Requirements

This script is intended to run on Unix-based systems like Linux. The following commands are required:

- `df` (for disk usage)
- `top` (for CPU usage)
- `free` (for memory usage)
- `ps` (for process information)

## Usage
### Options
```bash
# For normal use or CronJob
./script_name
```
- `./script_name.sh -t 50` <threshold>: Set the disk usage threshold for monitoring (default: 80%).
- `./script_name.sh -f mylogfile` <filename>: Set the filename for the generated report (default: monitoring_report_<current_date>.txt).
- `./script_name.sh -h` or --help: Show help message.

### For testing
``` bash
stress-ng --cpu 4 --cpu-load 80 --timeout 30
stress-ng --vm 2 --vm-bytes 75% --timeout 30
```