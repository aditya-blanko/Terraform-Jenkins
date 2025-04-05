pipeline {
    agent any

    environment {
        AZURE_CREDENTIALS_ID = 'azure-service-principal-01'
        RESOURCE_GROUP = 'rg-0401425'
        APP_SERVICE_NAME = 'webapijenkins-04000425'
        TERRAFORM_PATH = 'C:\\Users\\window 10\\Downloads\\terraform_1.11.3_windows_386'
    }

    stages {
        stage('Terraform Init') {
            steps {
                dir('terraform') {
                    bat '%TERRAFORM_PATH%\\terraform init'
                }
            }
        }

        stage('Terraform Plan & Apply') {
            steps {
                dir('terraform') {
                    bat '''
                       %TERRAFORM_PATH%\\ terraform plan
                       %TERRAFORM_PATH%\\ terraform apply -auto-approve
                    '''
                }
            }
        }

        stage('Publish .NET 8 Web API') {
            steps {
                dir('Webapi') {
                    bat '''
                        dotnet publish -c Release -o out
                        powershell Compress-Archive -Path "out\\*" -DestinationPath "Webapi.zip" -Force
                    '''
                }
            }
        }

        stage('Deploy to Azure App Service') {
            steps {
                withCredentials([azureServicePrincipal(credentialsId: AZURE_CREDENTIALS_ID)]) {
                    bat '''
                        az login --service-principal -u "%AZURE_CLIENT_ID%" -p "%AZURE_CLIENT_SECRET%" --tenant "%AZURE_TENANT_ID%"
                        az account set --subscription "%AZURE_SUBSCRIPTION_ID%"
                        az webapp deploy --resource-group %RESOURCE_GROUP% --name %APP_SERVICE_NAME% --src-path %WORKSPACE%\\Webapi\\Webapi.zip --type zip
                    '''
                }
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
