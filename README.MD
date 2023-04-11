Deployment steps:

1. Install yc CLI
2. Install kubectl
3. Install terraform
4. Install helm
5. `yc init --federation-id=bpfn9q9caodsckrtpi05`
6. Run Windows:`$Env:YC_TOKEN=$(yc iam create-token)`, Linux - `export YC_TOKEN=$(yc iam create-token)`
7. Run `terraform apply`
8. terraform output k8s_rendered_yaml > k8s.yml
