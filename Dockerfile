FROM accross/simd_merge:latest

VOLUME /results
WORKDIR /root/

COPY experiment-1-4.sh .
RUN chmod +x experiment-1-4.sh

COPY experiment-5.sh .
RUN chmod +x experiment-5.sh

COPY experiment-6.sh .
RUN chmod +x experiment-6.sh
COPY generateMergeDists.py cd basicProblemExplore/SetOperation/

ENTRYPOINT ["/bin/bash", "/root/experiment-6.sh"]
