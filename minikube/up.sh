#!/usr/bin/env bash
set -e

minikube start --memory=10240 --cpus=4
minikube addons enable ingress
kubectl wait --namespace ingress-nginx --for=condition=ready pod --selector=app.kubernetes.io/component=controller --timeout=180s
kubectl create namespace monitoring 
for i in {1..20}; do
  kubectl apply -f ../minikube/ && break
  echo "webhook ещё не готов, повтор $i..."
  sleep 5
done

kubectl apply -f ../minikube/

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add elastic https://helm.elastic.co
helm repo add open-telemetry https://open-telemetry.github.io/opentelemetry-helm-charts

helm repo update
helm upgrade --install mon prometheus-community/kube-prometheus-stack -n monitoring -f monitoring/values.yaml
# Install an eck-managed Elasticsearch, Kibana, and standalone APM Server using custom values.

helm upgrade --install elastic-operator elastic/eck-operator -n monitoring 

helm upgrade --install eck-stack elastic/eck-stack -n monitoring \
    --values https://raw.githubusercontent.com/elastic/cloud-on-k8s/3.5/deploy/eck-stack/examples/apm-server/basic.yaml \
    --values monitoring/eck-values.yaml


helm upgrade --install my-opentelemetry-collector open-telemetry/opentelemetry-collector -n monitoring  \
   --set image.repository="otel/opentelemetry-collector-contrib" \
   --set mode=deployment \
   --set fullnameOverride=otel-collector -f monitoring/otel-values.yaml

sudo -v
sudo pkill -f "minikube tunnel" 2>/dev/null || true
sleep 1
minikube tunnel --cleanup >/dev/null 2>&1 || true
sudo -b minikube tunnel > /tmp/minikube-tunnel.log 2>&1