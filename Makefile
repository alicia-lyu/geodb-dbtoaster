count_lines:
	wc -l /mnt/ssd/geo_btree/build/15/nation2.dat
	wc -l /mnt/ssd/geo_btree/build/15/states.dat
	wc -l /mnt/ssd/geo_btree/build/15/county.dat
	wc -l /mnt/ssd/geo_btree/build/15/city.dat
	wc -l /mnt/ssd/geo_btree/build/15/customer2.dat

join_view.hpp: join_view.sql count_lines
	dbtoaster join_view.sql -l cpp -o join_view.hpp

mixed_view.hpp: mixed_view.sql count_lines
	dbtoaster mixed_view.sql -l cpp -o mixed_view.hpp

./build/join_view: main.cpp join_view.hpp
	cd build && cmake .. && make join_view

./build/mixed_view: main.cpp mixed_view.hpp
	cd build && cmake .. && make mixed_view

run_join: ./build/join_view
	./build/join_view

run_mixed: ./build/mixed_view
	./build/mixed_view
