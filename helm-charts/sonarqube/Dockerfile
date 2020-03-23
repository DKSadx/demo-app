FROM ubuntu:18.04

RUN apt-get update && apt-get install -y maven git

COPY sonar.sh .

RUN chmod +x sonar.sh

CMD ["./sonar.sh"]
