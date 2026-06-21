struct MemoryMonitoringData: Sendable {
  /// Total number of memory warnings sent by the system.
  var warningsCount: Int = .zero

  /// Snapshot of the memory usage taken while the last memory warning occurred.
  var lastMemoryUsageSnapshot: MemoryUsageSnapshot? = nil
}

@AppMetricsActor
final class MemoryMonitoring: MetricReporter, Sendable {
  var data = MemoryMonitoringData()

  nonisolated func receivedMemoryWarning() {
    // Get the snapshot before asynchronously jumping to app metrics' isolation. This operation might be a bit expensive,
    // but we want the snapshot to be taken as early as possible, before other observers free up some memory.
    let snapshot = MemoryUsageSnapshot.getCurrent()

    AppMetricsActor.isolated { [self] in
      data = MemoryMonitoringData(
        warningsCount: data.warningsCount + 1,
        lastMemoryUsageSnapshot: snapshot
      )
      reportMetrics(snapshot)
      AppMetrics.mainSession.receiveLog(makeMemoryWarningLogRecord(snapshot: snapshot, warningsCount: data.warningsCount))
    }
  }
}

/// Builds the internal `expo.memory.warning` log event emitted when the system delivers a low-memory
/// warning. The memory usage snapshot taken at warning time rides as `expo.memory.*` attributes,
/// and `expo.memory.warningsCount` carries how many warnings this session has seen so far.
///
/// Emitted via `receiveLog` directly rather than the JS `logEvent` path, so the SDK-reserved `expo.`
/// event name and `expo.memory.*` attribute keys bypass the validation that would otherwise drop them.
func makeMemoryWarningLogRecord(snapshot: MemoryUsageSnapshot, warningsCount: Int) -> LogRecord {
  let attributes: [String: Any] = [
    "expo.memory.allocated": snapshot.memoryFootprint,
    "expo.memory.physical": snapshot.residentSize,
    "expo.memory.available": snapshot.freeMemory,
    "expo.memory.warningsCount": warningsCount,
  ]
  return LogRecord(
    name: "expo.memory.warning",
    attributes: attributes,
    severity: .warn
  )
}
