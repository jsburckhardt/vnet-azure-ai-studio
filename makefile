PREFIX ?= mvaip
deployment:
	az deployment group create --name secureaistudio --resource-group rg-mais-01 --template-file infra/main.bicep --parameters infra/main.bicepparam --parameters prefix=$(PREFIX)

project:
	az deployment group create --name secureaistudioproject --resource-group rg-mais-01 --template-file infra/project.main.bicep
