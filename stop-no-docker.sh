#!/bin/bash
set -e

echo "Stopping all services..."

if [ -f ".pids/frontend.pid" ]; then
  kill $(cat .pids/frontend.pid)
  rm .pids/frontend.pid
  echo "Frontend stopped."
fi

if [ -f ".pids/backend.pid" ]; then
  kill $(cat .pids/backend.pid)
  rm .pids/backend.pid
  echo "Backend stopped."
fi

if [ -f ".pids/hypervisor.pid" ]; then
  kill $(cat .pids/hypervisor.pid)
  rm .pids/hypervisor.pid
  echo "Hypervisor stopped."
fi

echo "All services stopped successfully!"
