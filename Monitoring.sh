#!/bin/bash

# Defaults value for Diskthreshold & report_file name
current_date=$(date '+%Y-%m-%d %H:%M:%S')
Diskthreshold=80
file_name=""
# ----------------------------------- Help Fucntion -------------------------------------------
function help {
  echo "Usage: $0 [-t threshold] [-f filename]"
  echo
  echo "Options:"
  echo "  -t threshold    Set the disk usage threshold for the monitoring (default: $Diskthreshold)"
  echo "  -f filename     Set the filename for the generated report (default: monitoring_report_$(date '+%Y%m%d_%H%M%S').txt)"
  echo "  -h              Display this help message"
  echo
  echo "This script monitors disk usage, CPU usage, and memory usage, and generates a system report."
  exit 1
}
# ----------------------------------- Disk Usage Function -------------------------------------
function check_disk_usage {
  # Get the disk usage and sort by usage percentage
  read disk_mount disk_usage <<< $(df -h --output=source,pcent | sort -k2 -n -r | head -n -1 | awk -v threshold=$Diskthreshold '$2+0 > threshold {print $1, $2}')
  
  # Check if any disk exceeds the threshold
  if [ -z "$disk_mount" ]; then
    disk_results="No disk usage is greater than $Diskthreshold%\nNo warning"
  else
    disk_results=$(df -h | sort -k5 -n | head -n 1 && df -h | sort -k5 -n -r | head -n 1)
    disk_results="$disk_results\nWARNING !!!"
  fi
}
# ----------------------------------- CPU Usage Function --------------------------------------
function check_cpu_usage {
  # Get the current CPU usage percentage
  CPU_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2 + $4}')
}
# ----------------------------------- Memory Usage Function -----------------------------------
function check_memory_usage {
  # Get memory usage stats
  read no mem_total no2 mem_used n3 mem_free <<< $(free -h | awk '/^Mem:/ {print "Total: " $2 ", Used: " $3 ", Free: " $4}')
}
# ----------------------------------- Get Top Processes Function ------------------------------
function get_top_processes {
  local n=$1     
  local order_by=$2  
  
  # Display top n processes ordered by the specified metric
  if [ "$order_by" == "cpu" ]; then
    ps -eo pid,user,comm,%cpu --sort=-%cpu | head -n $((n + 1)) 
  elif [ "$order_by" == "mem" ]; then
    ps -eo pid,user,comm,%mem --sort=-%mem | head -n $((n + 1)) 
  fi
}
# ----------------------------------- Handle Flags --------------------------------------------
while getopts "t:f:h" opt; do
  case $opt in
    t)
      Diskthreshold=$OPTARG
      ;;
    f)
      file_name=$OPTARG
      ;;
    h)
      help
      ;;
    *)
      echo "Usage: $0 [-t threshold] [-f filename] [-h]"
      exit 1
      ;;
  esac
done

if [ -z "$file_name" ]; then
  report_file="monitoring_report_$current_date.txt"
else
  # Append date to filename if user specifies one
  report_file="${file_name}_$current_date"
fi

# ----------------------------------- Extract System Information -----------------------------------
check_disk_usage
check_cpu_usage
check_memory_usage

# ----------------------------------- Create the Report -----------------------------------
{
  echo "System Monitoring Report"
  echo "Generated at: $current_date"
  echo "----------------------------------------"
  echo "Disk Usage:"
  echo -e "$disk_results"
  echo

  echo "Current CPU Usage: $CPU_usage%"
  echo "----------------------------------------"
  echo "Top 5 CPU-Consuming Processes:"
  get_top_processes 5 "cpu"
  echo

  echo "Memory Usage:"
  echo "Memory Total: $mem_total"
  echo "Memory Used: $mem_used"
  echo "Memory Free: $mem_free"
  echo "----------------------------------------"
  echo "Top 5 Memory-Consuming Processes:"
  get_top_processes 5 "mem"
  echo "----------------------------------------"
  echo "End of Report"
} > "$report_file"
