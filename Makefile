join_view.hpp: join_view.sql
	dbtoaster join_view.sql -l cpp -o join_view.hpp

./build/geodb: main.cpp join_view.hpp
	cd build && cmake .. && make

run: ./build/geodb
	./build/geodb
