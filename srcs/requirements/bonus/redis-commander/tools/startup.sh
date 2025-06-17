#!/bin/bash
sleep 8  # Wait for Redis to be ready
# Start Redis Commander with environment variables
exec redis-commander \
  --redis-host "redis" \
  --redis-port "6379" \