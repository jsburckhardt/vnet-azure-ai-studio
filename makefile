PREFIX ?= mvaip
deployment:
	az deployment group create --name secureaistudio --resource-group secure-ai-studio --template-file infra/main.bicep --parameters infra/main.bicepparam --parameters prefix=$(PREFIX)

project:
	az deployment group create --name secureaistudioproject --resource-group secure-ai-studio --template-file infra/project.main.bicep

newdeployment:
	az deployment sub create --name newdeployment \
		--location eastus2 \
		--template-file infra/main.bicep \
		--parameters infra/main.bicepparam \
		--parameters prefix=$(PREFIX) \
		--parameters location=eastus2 \
		--parameters computeInstanceName=jb1

newproject:
	az deployment sub create --name newproject \
		--location eastus2 \
		--template-file infra/project.main.bicep \
		--parameters projectname=jb1 \
		--parameters location=eastus2 \
		--parameters computeInstanceName=jb1
