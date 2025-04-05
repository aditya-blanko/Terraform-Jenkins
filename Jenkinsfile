    pipeline {
        agent any

        environment {
            AZURE_CREDENTIALS_ID = 'azure-service-principal-01'
            RESOURCE_GROUP = 'rg-0401425'
            APP_SERVICE_NAME = 'webapijenkins-04000425'
            AZURE_CLI_PATH = "${env.AZPATH}"
            SYSTEM_PATH = "${env.CMDPATH}"
            TERRAFORM_PATH = "${env.PATH}"
        }

        stages {
            stage('Check Environment') {
                steps {
                    bat '''
                        echo Setting up environment paths...
                        set PATH=%AZURE_CLI_PATH%;%SYSTEM_PATH%;%TERRAFORM_PATH%;%PATH%
                        
                        echo Checking Azure CLI...
                        where az
                        echo.
                        echo Checking Terraform...
                        where terraform
                        echo.
                        echo Current PATH:
                        echo %PATH%
                    '''
                }
            }

            stage('Azure Login') {
                steps {
                    withCredentials([azureServicePrincipal(credentialsId: AZURE_CREDENTIALS_ID)]) {
                        bat '''
                            set PATH=%AZURE_CLI_PATH%;%SYSTEM_PATH%;%TERRAFORM_PATH%;%PATH%
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
                            set PATH=%AZURE_CLI_PATH%;%SYSTEM_PATH%;%TERRAFORM_PATH%;%PATH%
                            terraform init
                        '''
                    }
                }
            }

            stage('Terraform Plan & Apply') {
                steps {
                    dir('terraform') {
                        bat '''
                            set PATH=%AZURE_CLI_PATH%;%SYSTEM_PATH%;%TERRAFORM_PATH%;%PATH%
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
                            powershell Compress-Archive -Path "out\\*" -DestinationPath "Webapi.zip" -Force
                        '''
                    }
                }
            }

            stage('Deploy to Azure App Service') {
                steps {
                    withCredentials([azureServicePrincipal(credentialsId: AZURE_CREDENTIALS_ID)]) {
                        bat '''
                            set PATH=%AZURE_CLI_PATH%;%SYSTEM_PATH%;%TERRAFORM_PATH%;%PATH%
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
