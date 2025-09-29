join_view.hpp: join_view.sql
	dbtoaster join_view.sql -l cpp -o join_view.hpp
	wc -l /mnt/ssd/geo_btree/build/15/nation2.dat
	wc -l /mnt/ssd/geo_btree/build/15/states.dat
	wc -l /mnt/ssd/geo_btree/build/15/county.dat
	wc -l /mnt/ssd/geo_btree/build/15/city.dat
	wc -l /mnt/ssd/geo_btree/build/15/customer2.dat

./build/geodb: main.cpp join_view.hpp
	cd build && cmake .. && make

run: ./build/geodb
	./build/geodb
