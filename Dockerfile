FROM accross/simd_merge:latest

VOLUME /results
WORKDIR /root/

COPY experiment-1.sh .
RUN chmod +x experiment-1.sh

COPY experiment-2.sh .
RUN chmod +x experiment-2.sh

COPY experiment-3.sh .
RUN chmod +x experiment-3.sh
COPY generateMergeDists.py cd basicProblemExplore/SetOperation/

ENTRYPOINT ["/bin/bash", "/root/experiment-3.sh"]
