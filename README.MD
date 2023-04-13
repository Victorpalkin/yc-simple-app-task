This is a demo application to show the work of Yandex.Cloud application load balancer together with Managed Kubernetes Engine
It works through the Application Load Balancer and Kubernetes Ingress Controller and serves static web pages with demo content.
- https://palkin.nl/app1 is routed to one app, 
- https://palkin.nl/app2 is routed to another
- https://palkin.nl/ is also working 


### Deployment steps:

1. Install yc CLI
2. Install Docker
2. Install kubectl
3. Install terraform
4. Install helm (required to install Ingress controller)
5. Create the certificate in Yandex cloud certificate manager for the required domain. Provide it as a variable in the root module
5. Authorize yandex.cloud CLI with `yc init --federation-id=<federation_id>`
6. Run Windows:`$Env:YC_TOKEN=$(yc iam create-token)`, Linux - `export YC_TOKEN=$(yc iam create-token)` to get the authorization token for terraform
7. Deploy common services (Cloud DNS zone and Container Registry) 
    
    7.1 `cd terraform/common-services`

    7.2 Maintain local variables in `main.tf`
    
    7.3 `terraform apply`
    
    7.4 Write down the container "registry_id" and "dns_zone_id" from the terraform output
    
    7.5 Configure Docker to use `docker-credential-yc` via `yc container registry configure-docker`
8. Build the container images and push them to container registry
    
    8.1 `cd ../../` to return to the root
    
    8.2 `docker build -t cr.yandex/<registry_id>/demo-app-1:v1 apps/demo-app-1` 
    
    8.3 `docker push cr.yandex/<registry_id>/demo-app-1:v1`
    
    8.4 `docker build -t cr.yandex/<registry_id>/demo-app-2:v1 apps/demo-app-2`
    
    8.5 `docker push cr.yandex/<registry_id>/demo-app-2:v1`
9. Deploy the application via terraform
    
    9.1 cd `terraform/demo-app/sandbox`
    
    9.2 Maintain local variables in `main.tf`
    
    9.3 `terraform apply`


### Steps to test
1. Open https://palkin.nl/app1
2. Open https://palkin.nl/app2

### Next steps
1. Separate of setting the landing zone resources and app resources into two different terraform templates

    1.1 Landing Zone resources - k8s cluster, databased cluster, DNS zone, container registry, IAM roles, VPC, security groups
2. Implement the storage of the state file on Object storage with state lock
2. Implement the usage of container registry
3. Implement the application to write to MySQL database (currently commented out)
4. Implement the sink of application load balancer logs to the MySQL database
