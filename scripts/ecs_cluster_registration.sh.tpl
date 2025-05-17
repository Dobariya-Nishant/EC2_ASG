#!/bin/bash
# sudo dnf update -y

# sudo dnf install -y docker

# sudo systemctl start docker
# sudo systemctl enable docker
# sudo usermod -aG docker ec2-user

# # Create ECS config folder
# sudo mkdir -p /etc/ecs

# Create ECS config
echo "ECS_CLUSTER=${ecs_cluster_name}" | sudo tee /etc/ecs/ecs.config
sudo systemctl restart ecs
# Run ECS agent
# sudo docker run \
#   --name ecs-agent \
#   --detach=true \
#   --restart=on-failure:10 \
#   --volume=/var/run/docker.sock:/var/run/docker.sock \
#   --volume=/var/log/ecs/:/log \
#   --volume=/var/lib/ecs/data:/data \
#   --net=host \
#   --env-file /etc/ecs/ecs.config \
#   public.ecr.aws/ecs/amazon-ecs-agent:latest
