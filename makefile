PREFIX ?= mvaip
deployment:
	az deployment sub create --name aistudio-managed-vnet \
		--location eastus2 \
		--template-file infra/main.bicep \
		--parameters infra/main.bicepparam \
		--parameters prefix=$(PREFIX) \
		--parameters location=eastus2 \
		--parameters ciConfig=@infra/computeInstances.json


project:
	az deployment group create --name newproject \
		--resource-group rg-jb36cbk4 \
		--template-file infra/project.main.bicep \
		--parameters projectConfig=@infra/aiStudioProjects.json
