//go:build linux

package platform

import (
	"github.com/metacubex/mihomo/log"
	"syscall"
)

// fdSafetyDenom defines the soft reserve: blocked above 3/4 of process RLIMIT_NOFILE.
const fdSafetyDenom = 4
const fdRlimitFallback = 1024

var (
	nullFd     = -1
	maxFdCount int
)

func init() {
	fd, err := syscall.Open("/dev/null", syscall.O_WRONLY, 0644)
	if err != nil {
		// Degrade instead of crashing: as a library we cannot panic at load.
		log.Warnln("platform.limit: cannot open /dev/null (%v); FD-pressure guard disabled", err)
		return
	}
	nullFd = fd

	var limit syscall.Rlimit
	if err := syscall.Getrlimit(syscall.RLIMIT_NOFILE, &limit); err != nil {
		maxFdCount = fdRlimitFallback
	} else {
		maxFdCount = int(limit.Cur)
	}

	maxFdCount = maxFdCount * (fdSafetyDenom - 1) / fdSafetyDenom
}

func ShouldBlockConnection() bool {
	if nullFd < 0 {
		return false
	}
	fd, err := syscall.Dup(nullFd)
	if err != nil {
		return true
	}

	_ = syscall.Close(fd)

	return fd > maxFdCount
}
