pipeline {
    agent any

    environment {
        AZURE_CREDENTIALS_ID = 'azure-service-principal-01'
        RESOURCE_GROUP = 'rg-jenkins'
        APP_SERVICE_NAME = 'webapijenkinssinghal22025'
        GIT_REPO_URL = 'https://github.com/aditya-blanko/Terraform-Jenkins.git'
        GIT_BRANCH = 'main'
    }

    stages {
        stage('Checkout Code') {
            steps {
                git branch: GIT_BRANCH, url: GIT_REPO_URL
            }
        }

        stage('Azure Login') {
            steps {
                withCredentials([azureServicePrincipal(credentialsId: AZURE_CREDENTIALS_ID)]) {
                    bat '''
                        az login --service-principal -u "%AZURE_CLIENT_ID%" -p "%AZURE_CLIENT_SECRET%" --tenant "%AZURE_TENANT_ID%"
                        az account set --subscription "%AZURE_SUBSCRIPTION_ID%"
                    '''
                }
            }
        }

        stage('Terraform Init') {
            steps {
                dir('terraform') {
                    bat '''
                        terraform init
                        terraform workspace new dev || terraform workspace select dev
                    '''
                }
            }
        }

        stage('Terraform Plan & Apply') {
            steps {
                dir('terraform') {
                    bat '''
                        terraform plan
                        terraform apply -auto-approve
                    '''
                }
            }
        }

        stage('Publish .NET 8 Web API') {
            steps {
                dir('Webapi') {
                    bat '''
                        dotnet publish -c Release -o out
                        powershell Compress-Archive -Path "out\\*" -DestinationPath "webapi.zip" -Force
                    '''
                }
            }
        }

        stage('Deploy to Azure App Service') {
            steps {
                withCredentials([azureServicePrincipal(credentialsId: AZURE_CREDENTIALS_ID)]) {
                    bat '''
                        az webapp deploy --resource-group %RESOURCE_GROUP% --name %APP_SERVICE_NAME% --src-path "%WORKSPACE%\\Webapi\\webapi.zip" --type zip
                    '''
                }
            }
        }
    }

    post {
        success {
            echo '''
                =========================================
                Deployment Successful!
                Your application is available at:
                https://%APP_SERVICE_NAME%.azurewebsites.net
                =========================================
            '''
        }
        failure {
            echo '''
                =========================================
                Deployment Failed!
                Please check the logs for details.
                =========================================
            '''
        }
        
    }
}
