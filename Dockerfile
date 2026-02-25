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
RUN wget https://dbtoaster.github.io/dist/dbtoaster_2.3_linux.tgz \
    && tar -xvf dbtoaster_2.3_linux.tgz \
    && rm dbtoaster_2.3_linux.tgz
ENV PATH="/opt/dbtoaster/bin:${PATH}"

# 2. Only copy the geodb folder (ensure you run build from the parent dir)
WORKDIR /geodb
COPY ./views.sql ./views.sql
COPY ./main.cpp ./main.cpp
COPY ./CMakeLists.txt ./CMakeLists.txt

# 3. Generate and build views
RUN dbtoaster views.sql -l cpp -o views.hpp \
    && mkdir -p build && cd build \
    && cmake .. -DCMAKE_BUILD_TYPE=Release \
    && make views

# Stage 2 — runner
FROM ubuntu:22.04 AS runner

RUN apt-get update && apt-get install -y \
    libstdc++6 \
    libboost-serialization-dev \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /geodb/build/views /app/views
COPY ./entrypoint.sh /app/entrypoint.sh

# FIX: Create an absolute path for data
RUN mkdir -p /app/data_files
COPY ./data_files/*.dat /app/data_files/

RUN chmod +x /app/entrypoint.sh

# Set the workdir where the binary will run
WORKDIR /app
ENTRYPOINT ["/app/entrypoint.sh"]