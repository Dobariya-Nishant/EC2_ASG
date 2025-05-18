#!/bin/bash
set -e

echo 'ECS_CLUSTER=${ecs_cluster_name}' | sudo tee -a /etc/ecs/ecs.config > /dev/null
sudo systemctl enable --now ecs