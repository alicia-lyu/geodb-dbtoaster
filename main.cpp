#include "join_view.hpp"
#include <chrono>
#include <iostream>

namespace dbtoaster {
class CustomProgram : public Program {
  long customer_seen = 0;
  std::chrono::high_resolution_clock::time_point start_time;
  const long WARMUP_COUNT = 450000;

public:
  CustomProgram(int argc = 0, char *argv[] = 0) : Program(argc, argv) {}
  virtual ~CustomProgram() {
    std::chrono::high_resolution_clock::time_point end_time =
        std::chrono::high_resolution_clock::now();
    std::chrono::duration<double> diff = end_time - start_time;
    double elapsed_seconds = diff.count();
    double update_time = elapsed_seconds * 1e6 / (customer_seen - WARMUP_COUNT);
    std::cout << "\n--- Maintenance Benchmark Results ---" << std::endl;
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
  void process_stream_event(event_t &ev) {
    customer_seen++;
    if (customer_seen == WARMUP_COUNT + 1) {
      std::cout << "\nWarmup complete (" << WARMUP_COUNT << " customers)."
                << std::endl;
      std::cout << "Starting maintenance timer..." << std::endl;
      start_time = std::chrono::high_resolution_clock::now();
    }
    Program::process_stream_event(ev);
    [[maybe_unused]] dbtoaster::Program::snapshot_t snap =
        Program::take_snapshot(); // force sync
  }
};
} // namespace dbtoaster

int main(int argc, char *argv[]) {
  dbtoaster::CustomProgram p(argc, argv);
  std::cout << "Loading static tables (NATION, STATES, COUNTIES, CITIES)..."
            << std::endl;
  p.init();
  std::cout << "Static tables loaded and initial view computed." << std::endl;
  p.run();
}