#!/bin/sh

yc managed-kubernetes cluster get-credentials ${cluster_name} --external --force
yc iam key create --service-account-name &{ingress_sa} --output sa-key.json
cat sa-key.json | helm registry login cr.yandex --username 'json_key' --password-stdin && \
helm pull oci://cr.yandex/yc-marketplace/yandex-cloud/yc-alb-ingress/yc-alb-ingress-controller-chart \
  --version=v0.1.13 \
  --untar && \
helm install \
  --namespace default \
  --set folderId=${folder_id} \
  --set clusterId=${cluster_id} \
  --set-file saKeySecretKey=sa-key.json \
  yc-alb-ingress-controller ./yc-alb-ingress-controller-chart/