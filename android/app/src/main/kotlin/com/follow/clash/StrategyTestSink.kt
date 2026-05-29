package com.follow.clash

// Progress callback handed to the bydpi-only StrategyTester via reflection;
// each call carries one JSON progress object.
fun interface StrategyTestSink {
    fun onProgress(json: String)
}
