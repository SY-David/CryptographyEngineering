#!/bin/bash

TEST_DIRS="shake256"
FAILED=0

for dir in $TEST_DIRS; do
    echo "Testing $dir..."
    cd $dir
    make clean > /dev/null
    
    if CFLAGS=-Werror make run-qemu PLATFORM=qemu | grep -q "ALL GOOD"; then
        echo "$dir: PASSED"
    else
        echo "$dir: FAILED"
        FAILED=1
    fi
    
    cd ..
done

if [ $FAILED -eq 1 ]; then
    echo "Some tests failed"
    exit 1
else
    echo "All tests passed"
    exit 0
fi