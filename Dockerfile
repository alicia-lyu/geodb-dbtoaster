# Stage 1 — builder
FROM ubuntu:22.04 AS builder

RUN apt-get update && apt-get install -y \
    openjdk-11-jre-headless \
    g++ \
    cmake \
    wget \
    tar \
    libboost-dev \
    && rm -rf /var/lib/apt/lists/*

# 1. Download and install DBToaster from official source
WORKDIR /opt
RUN wget https://dbtoaster.github.io/dist/dbtoaster_linux_64.tar.gz \
    && tar -xvf dbtoaster_linux_64.tar.gz \
    && rm dbtoaster_linux_64.tar.gz
ENV PATH="/opt/dbtoaster/bin:${PATH}"

# 2. Only copy the geodb folder (ensure you run build from the parent dir)
WORKDIR /geodb
COPY ./geodb/views.sql ./views.sql
COPY ./geodb/main.cpp ./main.cpp
COPY ./geodb/CMakeLists.txt ./CMakeLists.txt

# 3. Generate and build views
RUN dbtoaster views.sql -l cpp -o views.hpp \
    && mkdir -p build && cd build \
    && cmake .. -DCMAKE_BUILD_TYPE=Release \
    && make views

# Stage 2 — runner
FROM ubuntu:22.04 AS runner

RUN apt-get update && apt-get install -y \
    libstdc++6 \
    && rm -rf /var/lib/apt/lists/*

# Copy the binary from builder
COPY ./geodb/entrypoint.sh /app/entrypoint.sh

# 4. Copy data files directly into the image (adjust the source path as needed)
# Assumes your data is in a local 'data' folder next to geodb
RUN mkdir -p /mnt/ssd/geo_btree/build/15
COPY ./data/*.dat /mnt/ssd/geo_btree/build/15/

RUN chmod +x /app/entrypoint.sh
WORKDIR /results
ENTRYPOINT ["/app/entrypoint.sh"]