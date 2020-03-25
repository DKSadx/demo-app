#!/bin/bash

cd helm-charts/

echo "Installing demo-app..."
helm install -f demo-app/values.yaml ./demo-app --name demo-app --namespace demo-app

read -p "Do you want to install Jenkins (y/n): " input_jen
if [ $input_jen == "y" ]
then
  echo "Installing and setting up Jenkins..."

  echo "Pulling build image..."
  docker pull dkabh/build:v1

  # Change the read and write permissions for docker.sock (required if using Docker with Jenkins)
  chmod 666 /var/run/docker.sock

  # Set hosts $HOME path as an environment variable inside Jenkins slave container (required for .m2 caching)
  sed -i 's@<HOST_HOME_PATH>@'"$HOME"'@' ./jenkins/values.yaml

  # Create ClusterRoleBinding for Jenkins (required if using kubectl/helm with Jenkins)
  kubectl create clusterrolebinding permissive-binding --clusterrole=cluster-admin --user=admin --user=kubelet --group=system:serviceaccounts:jenkins

  # Install Jenkins with custom values
  helm install -f jenkins/values.yaml stable/jenkins --name jenkins --namespace jenkins

  # Save Jenkins nodePort
  JENKINS_NODE_PORT=$(kubectl get --namespace jenkins -o jsonpath="{.spec.ports[0].nodePort}" services jenkins)
fi

read -p "Do you want to install SonarQube (y/n): " input_sq
if [ $input_sq == "y" ]
then
  echo "Installing and setting up SonarQube..."

  echo "Pulling SonarQube build(test) image..."
  docker pull dkabh/sq:v1

  # Add SonarQube repository (stable/sonarqube is deprecated)
  helm repo add oteemocharts https://oteemo.github.io/charts

  # Install SonarQube with custom values
  helm install -f sonarqube/values.yaml oteemocharts/sonarqube --name sonarqube --namespace sonarqube

  # Save SonarQube nodePort
  SQ_NODE_PORT=$(kubectl get --namespace sonarqube -o jsonpath="{.spec.ports[0].nodePort}" services sonarqube-sonarqube)
fi

read -p "Do you want to set up monitoring (ELK) (y/n): " input_elk
if [ $input_elk == "y" ]
then
  echo "Installing and setting up ElasticSearch..."
  helm install -f elasticsearch/values.yaml elastic/elasticsearch --name elasticsearch --namespace monitoring

  echo "Installing and setting up Filebeat..."
  helm install -f filebeat/values.yaml elastic/filebeat --name filebeat --namespace monitoring

  echo "Installing and setting up Kibana..."
  helm install -f kibana/values.yaml elastic/kibana --name kibana --namespace monitoring

  # Save Kibana nodePort
  KIBANA_NODE_PORT=$(kubectl get --namespace monitoring -o jsonpath="{.spec.ports[0].nodePort}" services kibana-kibana)
fi

# Gets the external ip
ip=$(curl -s ipinfo.io/ip)

echo "You can access the demo-app website on $ip/ui"

[ $input_jen == "y" ] &&
  echo "You can access Jenkins on $ip:$JENKINS_NODE_PORT"
[ $input_sq == "y" ] &&
  echo "You can access SonarQube on $ip:$SQ_NODE_PORT"
[ $input_elk == "y" ] &&
  echo "You can access Kibana on $ip:$KIBANA_NODE_PORT"
