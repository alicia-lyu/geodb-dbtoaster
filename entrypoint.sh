#!/bin/bash

echo "Running experiment: unlimited"
/app/views || echo "WARNING: unlimited run failed (exit $?)"

echo "Running experiment: 2800000 KB virtual memory"
(ulimit -v 2800000 && /app/views) || echo "WARNING: 2800000 KB run failed (exit $?)"

echo "Running experiment: 2400000 KB virtual memory"
(ulimit -v 2400000 && /app/views) || echo "WARNING: 2400000 KB run failed (exit $?)"

echo "Running experiment: 2000000 KB virtual memory"
(ulimit -v 2000000 && /app/views) || echo "WARNING: 2000000 KB run failed (exit $?)"

echo "Running experiment: 1600000 KB virtual memory"
(ulimit -v 1600000 && /app/views) || echo "WARNING: 1600000 KB run failed (exit $?)"

exit 0
