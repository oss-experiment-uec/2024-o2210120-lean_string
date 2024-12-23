FROM rust:latest

RUN rustup install nightly && \
    rustup default nightly && \
    rustup +nightly component add miri rust-src

WORKDIR /workspace

COPY run_tests.sh /workspace/run_tests.sh
RUN chmod +x /workspace/run_tests.sh

RUN git clone https://github.com/ryota2357/lean_string.git before && \
    cd before && \
    git checkout f31f6709bbe6cf76699dd510a1a1d5e5b0c2b9fa && \
    cd .. && \
    git clone https://github.com/oss-experiment-uec/2024-o2210120-lean_string.git after

CMD ["./run_tests.sh"]
