pipeline {
    agent any

    environment {
        AZURE_CREDENTIALS_ID = 'azure-service-principal-01'
        RESOURCE_GROUP = 'rg-04082003'
        APP_SERVICE_NAME = 'webapijenkins-04082003'
        GIT_REPO_URL = 'https://github.com/aditya-blanko/Terraform-Jenkins.git'
        GIT_BRANCH = 'main'
        TERRAFORM_VERSION = '1.7.5'
        DEPLOYMENT_TIMEOUT = '1800'
    }

    stages {
        stage('Checkout Code') {
            steps {
                git branch: GIT_BRANCH, url: GIT_REPO_URL
            }
        }

        stage('Install Terraform') {
            steps {
                bat '''
                    echo Installing Terraform...
                    powershell -Command "Invoke-WebRequest -Uri 'https://releases.hashicorp.com/terraform/%TERRAFORM_VERSION%/terraform_%TERRAFORM_VERSION%_windows_amd64.zip' -OutFile 'terraform.zip'"
                    powershell -Command "Expand-Archive -Path 'terraform.zip' -DestinationPath 'C:\\terraform' -Force"
                    setx PATH "%PATH%;C:\\terraform" /M
                    echo Terraform installation completed
                '''
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
                        C:\\terraform\\terraform.exe init
                        C:\\terraform\\terraform.exe workspace new dev || C:\\terraform\\terraform.exe workspace select dev
                    '''
                }
            }
        }

        stage('Terraform Plan & Apply') {
            steps {
                dir('terraform') {
                    bat '''
                        C:\\terraform\\terraform.exe plan
                        C:\\terraform\\terraform.exe apply -auto-approve
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
                         az webapp cors add --resource-group %RESOURCE_GROUP% --name %APP_SERVICE_NAME% --allowed-origins "*"
                        az webapp config set --resource-group %RESOURCE_GROUP% --name %APP_SERVICE_NAME% --startup-file "dotnet Webapi.dll"
                        az webapp config appsettings set --resource-group %RESOURCE_GROUP% --name %APP_SERVICE_NAME% --settings ASPNETCORE_ENVIRONMENT=Production
                        az webapp config appsettings set --resource-group %RESOURCE_GROUP% --name %APP_SERVICE_NAME% --settings WEBSITE_RUN_FROM_PACKAGE=1
                        
                        az webapp deploy --resource-group %RESOURCE_GROUP% --name %APP_SERVICE_NAME% --src-path "%WORKSPACE%\\Webapi\\webapi.zip" --type zip --timeout %DEPLOYMENT_TIMEOUT%
                        az webapp restart --name %APP_SERVICE_NAME% --resource-group %RESOURCE_GROUP%
                        
                        
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
                Swagger UI is available at:
                https://%APP_SERVICE_NAME%.azurewebsites.net/swagger
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
