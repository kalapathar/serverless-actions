# serverless-actions

`terraform` folder contains the terraform code to create a S3 bucket and a AWS lambda along with roles and policies and also sets up S3 based trigger to invoke the Lambda

`test-lambda` is the lambda function that we want to deploy to AWS 

`.github` folder contains the `deployment.yaml` which contains the code for github actions. Github Actions deploys the lambda to AWS
