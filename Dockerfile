FROM ubuntu:18.04

RUN apt-get update && apt-get install -y maven git

COPY build.sh .

RUN chmod +x build.sh

CMD ["./build.sh"]
