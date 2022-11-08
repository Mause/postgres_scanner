.PHONY: all clean format debug release duckdb_debug duckdb_release update
all: release
GEN=ninja

OSX_BUILD_UNIVERSAL_FLAG=
ifeq (${OSX_BUILD_UNIVERSAL}, 1)
	OSX_BUILD_UNIVERSAL_FLAG=-DOSX_BUILD_UNIVERSAL=1
endif
GENERATOR=
ifeq ($(GEN),ninja)
	GENERATOR=-G "Ninja"
endif
# BUILD_OUT_OF_TREE_EXTENSION
POSTGRES_SCANNER_PATH=${PWD}

clean:
	rm -rf build
	rm -rf postgres

pull:
	git submodule init
	git submodule update --recursive --remote


debug: pull
	mkdir -p build/debug && \
	cd build/debug && \
	cmake $(GENERATOR) -DCMAKE_BUILD_TYPE=Debug ${OSX_BUILD_UNIVERSAL_FLAG} ../../duckdb/CMakeLists.txt -DEXTERNAL_EXTENSION_DIRECTORIES=${POSTGRES_SCANNER_PATH} -B. -S ../../duckdb && \
	cmake --build . --parallel


release: pull
	mkdir -p build/release && \
	cd build/release && \
	cmake $(GENERATOR) -DCMAKE_BUILD_TYPE=RelWithDebInfo ${OSX_BUILD_UNIVERSAL_FLAG} ../../duckdb/CMakeLists.txt -DEXTERNAL_EXTENSION_DIRECTORIES=${POSTGRES_SCANNER_PATH} -B. -S ../../duckdb && \
	cmake --build . --parallel


test: release
	./build/release/test/unittest --test-dir . "[postgres_scanner]"

format: pull
	cp duckdb/.clang-format .
	clang-format --sort-includes=0 -style=file -i postgres_scanner.cpp
	clang-format --sort-includes=0 -style=file -i concurrency_test.cpp
	cmake-format -i CMakeLists.txt
