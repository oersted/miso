FROM accross/simd_merge:latest

VOLUME /results
COPY experiment-1.sh /root/experiment-1.sh
WORKDIR /root/
RUN chmod +x experiment-1.sh

ENTRYPOINT ["/bin/bash", "/root/experiment-1.sh"]
