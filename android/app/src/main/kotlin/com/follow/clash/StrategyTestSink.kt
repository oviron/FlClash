package com.follow.clash

// Progress callback for the ByeDPI strategy test. Defined in the shared source
// set so ServicePlugin (src/main) can hand it to the bydpi-only StrategyTester
// via reflection. Each call carries one JSON progress object (per finished
// strategy, or {"error":...}).
fun interface StrategyTestSink {
    fun onProgress(json: String)
}
