#!/bin/env python3

import psutil
from collections import defaultdict
import argparse
import time

def get_memory_usage():
    processes = []
    for proc in psutil.process_iter(['pid', 'name', 'username', 'memory_info']):
        try:
            pinfo = proc.as_dict(attrs=['pid', 'name', 'username', 'memory_info'])
            pinfo['memory_mb'] = pinfo['memory_info'].rss / (1024 * 1024)  # Convert to MB
            uid = psutil.Process(pinfo['pid']).uids().real
            if uid >= 1000:
                pinfo['uid'] = uid
                processes.append(pinfo)
        except (psutil.NoSuchProcess, psutil.AccessDenied, psutil.ZombieProcess):
            pass
    return processes

def accumulate_by_user(processes):
    user_totals = defaultdict(lambda: {'total_memory': 0, 'processes': []})
    for proc in processes:
        user_totals[proc['username']]['total_memory'] += proc['memory_mb']
        user_totals[proc['username']]['processes'].append(proc)
    return user_totals

def kill_top_processes(processes, num_to_kill=3):
    killed_memory = 0
    for proc in sorted(processes, key=lambda x: x['memory_mb'], reverse=True)[:num_to_kill]:
        try:
            p = psutil.Process(proc['pid'])
            p.terminate()
            print(f"    Terminated PID {proc['pid']}: {proc['name']} ({proc['memory_mb']:.2f} MB)")
            killed_memory += proc['memory_mb']
        except psutil.NoSuchProcess:
            print(f"    Process {proc['pid']} no longer exists.")
        except psutil.AccessDenied:
            print(f"    Access denied when trying to terminate PID {proc['pid']}.")
    return killed_memory


def decrease_high_cpu_priority():
    # Get top CPU-consuming processes with UID >= 1000
    top_cpu_processes = sorted(
        [p for p in psutil.process_iter(['pid', 'name', 'cpu_percent', 'username']) 
         if p.uids().real >= 1000],
        key=lambda p: p.cpu_percent(),
        reverse=True
    )[:10]  # Get top 10 CPU-consuming user processes

    for proc in top_cpu_processes:
        try:
            if proc.cpu_percent() > 80:
                current_nice = proc.nice()
                if current_nice < 19:  # Check if we can still increase nice value
                    new_nice = min(current_nice + 5, 19)  # Increase nice by 5, but not above 19
                    proc.nice(new_nice)
                    print(f"Decreased priority of PID {proc.pid}: {proc.name()} (CPU: {proc.cpu_percent():.1f}%, "
                          f"Nice: {current_nice} -> {new_nice})")
        except (psutil.NoSuchProcess, psutil.AccessDenied, psutil.ZombieProcess):
            pass

        
def main(threshold_percent):
    print("\nChecking for high CPU usage processes...")
    decrease_high_cpu_priority()        

    total_memory = psutil.virtual_memory().total / (1024 * 1024)  # Total memory in MB
    threshold_mb = total_memory * (threshold_percent / 100)
    target_free_memory = total_memory * 0.05  # 5% of total memory
    
    print(f"Total system memory: {total_memory:.2f} MB")
    print(f"Threshold set to {threshold_percent}% of total memory: {threshold_mb:.2f} MB")
    print(f"Target free memory: {target_free_memory:.2f} MB")

    while psutil.virtual_memory().available / (1024 * 1024) < target_free_memory:
        processes = get_memory_usage()
        user_totals = accumulate_by_user(processes)

        print(f"\nCurrent free memory: {psutil.virtual_memory().available / (1024 * 1024):.2f} MB")
        print(f"Users consuming more than {threshold_mb:.2f} MB of memory:")
        
        for username, data in sorted(user_totals.items(), key=lambda x: x[1]['total_memory'], reverse=True):
            if data['total_memory'] > threshold_mb:
                print(f"\nUser: {username}, Total Memory: {data['total_memory']:.2f} MB")
                print("Top 3 Processes:")
                top_processes = sorted(data['processes'], key=lambda x: x['memory_mb'], reverse=True)[:3]
                for proc in top_processes:
                    print(f"  PID: {proc['pid']}, Name: {proc['name']}, Memory: {proc['memory_mb']:.2f} MB")
                
                print("\nTerminating the top 3 processes consuming the most memory for this user:")
                #killed_memory = kill_top_processes(data['processes'])
                #print(f"Freed approximately {killed_memory:.2f} MB of memory")

        time.sleep(5)  # Wait for 5 seconds before checking memory again

    print(f"\nFree memory target reached. Current free memory: {psutil.virtual_memory().available / (1024 * 1024):.2f} MB")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Monitor and manage high memory and hig cpu usage processes.")
    parser.add_argument("-t", "--threshold", type=float, default=80.0, 
                        help="Threshold percentage of total system memory (default: 80.0)")
    args = parser.parse_args()

    if args.threshold <= 0 or args.threshold > 100:
        print("Threshold must be a percentage between 0 and 100.")
    else:
        main(args.threshold)
