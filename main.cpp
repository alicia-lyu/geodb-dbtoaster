#include "join_view.hpp"
#include <chrono>
#include <iostream>

long get_memory_usage_linux() {
  long resident_set_size = 0;
  std::ifstream ifs("/proc/self/status");
  std::string line;
  while (std::getline(ifs, line)) {
    if (line.rfind("VmRSS:", 0) == 0) { // Check if line starts with "VmRSS:"
      size_t pos = line.find_first_of("0123456789");
      if (pos != std::string::npos) {
        resident_set_size = std::stol(line.substr(pos));
      }
      break;
    }
  }
  return resident_set_size; // Returns in KB
}

namespace dbtoaster {
class CustomProgram : public Program {
  long customer_seen = 0;
  std::chrono::high_resolution_clock::time_point start_time = {};
  std::chrono::high_resolution_clock::time_point epoch_time = {};
  const long WARMUP_COUNT = 450000;
  long memory_usage_kb = 0;

public:
  CustomProgram(int argc = 0, char *argv[] = 0) : Program(argc, argv) {
    epoch_time = std::chrono::high_resolution_clock::now();
  }
  void final_stats() {
    if (customer_seen <= WARMUP_COUNT) {
      std::cout << "\nNot enough updates to measure maintenance time."
                << std::endl;
      return;
    }
    std::chrono::high_resolution_clock::time_point end_time =
        std::chrono::high_resolution_clock::now();
    std::chrono::duration<double> diff = end_time - start_time;
    double elapsed_seconds = diff.count();
    double update_time = elapsed_seconds * 1e6 / (customer_seen - WARMUP_COUNT);
    std::cout << "\n--- Maintenance Benchmark Results ---" << std::endl;
    std::cout << "Memory usage after warmup: " << memory_usage_kb << " KB."
              << std::endl;
    std::cout << "Total customers processed: " << customer_seen << std::endl;
    std::cout << "Maintenance measured for: "
              << (customer_seen > WARMUP_COUNT ? customer_seen - WARMUP_COUNT
                                               : 0)
              << " customers." << std::endl;
    std::cout << "Maintenance time: " << elapsed_seconds << " seconds."
              << std::endl;
    if (customer_seen > WARMUP_COUNT) {
      std::cout << "Average time per update: " << update_time << " us."
                << std::endl;
    }
  }

  void process_stream_event(const event_t &ev) override {
    customer_seen++;
    if (customer_seen == WARMUP_COUNT + 1) {
      std::cout << "\nWarmup complete (" << WARMUP_COUNT << " customers)."
                << std::endl;
      std::cout << "Starting maintenance timer..." << std::endl;
      start_time = std::chrono::high_resolution_clock::now();
      memory_usage_kb = get_memory_usage_linux();
    }
    Program::process_stream_event(ev);
    [[maybe_unused]] dbtoaster::Program::snapshot_t snap =
        Program::take_snapshot(); // force sync
    if (customer_seen == WARMUP_COUNT + 1) {
      auto count_map = snap->get_COUNT();
      std::cout << "COUNT after warmup: " << count_map.count() << std::endl;
    }
    if (customer_seen % 1000 == 0) {
      memory_usage_kb = get_memory_usage_linux();
      auto current_time = std::chrono::high_resolution_clock::now();
      std::chrono::duration<double> epoch_diff = current_time - epoch_time;
      double epoch_seconds = epoch_diff.count();
      double update_time = epoch_seconds * 1e6 / 1000;
      epoch_time = current_time;
      std::cout << "\rProcessed " << customer_seen
                << " customers, memory usage: " << memory_usage_kb
                << " KB, update time (last 1000): " << update_time << " us."
                << std::flush;
    }
  }
};
} // namespace dbtoaster

int main(int argc, char *argv[]) {
  dbtoaster::CustomProgram p(argc, argv);
  std::cout << "Loading static tables (NATION, STATES, COUNTIES, CITIES)..."
            << std::endl;
  p.init();
  dbtoaster::Program::snapshot_t snap = p.take_snapshot();
  auto count_map = snap->get_COUNT();
  std::cout << "Initial COUNT: " << count_map.count() << std::endl;
  std::cout << "Static tables loaded and initial view computed." << std::endl;
  p.run();
  snap = p.take_snapshot();
  count_map = snap->get_COUNT();
  std::cout << "Final COUNT: " << count_map.count() << std::endl;
  p.final_stats();
}