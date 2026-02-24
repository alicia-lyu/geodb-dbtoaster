# Stage 1 — builder
FROM ubuntu:22.04 AS builder

RUN apt-get update && apt-get install -y \
    openjdk-11-jre-headless \
    g++ \
    cmake \
    libboost-dev \
    && rm -rf /var/lib/apt/lists/*

COPY . /dbtoaster/
ENV PATH="/dbtoaster/bin:${PATH}"

WORKDIR /dbtoaster/geodb
RUN dbtoaster views.sql -l cpp -o views.hpp
RUN rm -rf build && mkdir build && cd build && cmake .. -DCMAKE_BUILD_TYPE=Release && make views

# Stage 2 — runner
FROM ubuntu:22.04 AS runner

RUN apt-get update && apt-get install -y \
    libstdc++6 \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /mnt/ssd/geo_btree/build/15

COPY --from=builder /dbtoaster/geodb/build/views /app/views
COPY geodb/entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh

WORKDIR /results
ENTRYPOINT ["/app/entrypoint.sh"]
