count_lines:
	wc -l ./data_files/nation2.dat
	wc -l ./data_files/states.dat
	wc -l ./data_files/county.dat
	wc -l ./data_files/city.dat
	wc -l ./data_files/customer2.dat

views.hpp: views.sql count_lines
	dbtoaster views.sql -l cpp -o views.hpp

mixed_view.hpp: mixed_view.sql count_lines
	dbtoaster mixed_view.sql -l cpp -o mixed_view.hpp

./build/views: main.cpp views.hpp
	cd build && cmake .. && make views

./build/mixed_view: main.cpp mixed_view.hpp
	cd build && cmake .. && make mixed_view

run: ./build/views
	./build/views

experiment:
	$(MAKE) run
	ulimit -v 2800000 && $(MAKE) run
	ulimit -v 2400000 && $(MAKE) run
	ulimit -v 2000000 && $(MAKE) run
	ulimit -v 1600000 && $(MAKE) run