This is a demo application to show the work of Yandex.Cloud application load balancer together with Managed Kubernetes Engine
It works through the Application Load Balancer and Kubernetes Ingress Controller and serves static web pages with demo content.
- https://palkin.nl/app1 is routed to one app, 
- https://palkin.nl/app2 is routed to another
- https://palkin.nl/ is also working 


### Deployment steps:

1. Install yc CLI
2. Install kubectl
3. Install terraform
4. Install helm (required to install Ingress controller)
5. Create the certificate in Yandex cloud certificate manager for the required domain. Provide it as a variable in the root module
5. Authorize yandex.cloud CLI with `yc init --federation-id=bpfn9q9caodsckrtpi05`
6. Run Windows:`$Env:YC_TOKEN=$(yc iam create-token)`, Linux - `export YC_TOKEN=$(yc iam create-token)`
7. Go to directory `cd terraform/environments/sandbox`
7. Run `terraform apply`

### Steps to test
1. Open https://palkin.nl/app1
2. Open https://palkin.nl/app2

### Next steps
1. Separate of setting the landing zone resources and app resources into two different terraform templates
    1.1 Landing Zone resources - k8s cluster, databased cluster, DNS zone, container registry, IAM roles, VPC, security groups
2. Implement the usage of container registry
3. Implement the application to write to MySQL database (currently commented out)
4. Implement the sink of application load balancer logs to the MySQL database