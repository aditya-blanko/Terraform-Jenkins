pipeline {
    agent any

    environment {
        AZURE_CREDENTIALS_ID = 'azure-service-principal-01'
        RESOURCE_GROUP = 'rg-jenkins'
        APP_SERVICE_NAME = 'webapijenkin022025'
        TERRAFORM_VERSION = '1.11.3'
        TERRAFORM_DIR = '%WORKSPACE%\\terraform'
        TERRAFORM_PATH = '%WORKSPACE%\\terraform\\terraform.exe'
    }

    stages {
        stage('Setup Terraform') {
            steps {
                    bat '''
                            powershell -Command "& {Invoke-WebRequest -Uri 'https://releases.hashicorp.com/terraform/%TERRAFORM_VERSION%/terraform_%TERRAFORM_VERSION%_windows_amd64.zip' -OutFile '%TERRAFORM_DIR%\\terraform.zip'}"
                            powershell -Command "& {Expand-Archive -Path '%TERRAFORM_DIR%\\terraform.zip' -DestinationPath '%TERRAFORM_DIR%' -Force}"
                            del "%TERRAFORM_DIR%\\terraform.zip"
                    '''
                }
            }
        }

        stage('Terraform Init') {
            steps {
                dir('terraform') {
                    bat '"%TERRAFORM_PATH%" init'
                }
            }
        }

        stage('Terraform Plan & Apply') {
            steps {
                dir('terraform') {
                    bat '"%TERRAFORM_PATH%" plan -out=tfplan'
                    bat '"%TERRAFORM_PATH%" apply -auto-approve tfplan'
                }
            }
        }

        stage('Publish .NET 8 Web API') {
            steps {
                dir('Webapi') {
                    bat 'dotnet publish -c Release -o out'
                    bat 'powershell Compress-Archive -Path out\\* -DestinationPath webapi.zip -Force'
                }
            }
        }

        stage('Deploy to Azure App Service') {
            steps {
                withCredentials([azureServicePrincipal(credentialsId: AZURE_CREDENTIALS_ID)]) {
                    bat "az login --service-principal -u $AZURE_CLIENT_ID -p $AZURE_CLIENT_SECRET --tenant $AZURE_TENANT_ID"
                    bat "az account set --subscription $AZURE_SUBSCRIPTION_ID"
                    bat "az webapp deploy --resource-group $RESOURCE_GROUP --name $APP_SERVICE_NAME --src-path %WORKSPACE%\\webapi\\webapi.zip --type zip"
                }
            }
        }
    

    post {
        success {
            echo 'Deployment Successful!'
        }
        failure {
            echo 'Deployment Failed!'
        }
    
    }
} 
