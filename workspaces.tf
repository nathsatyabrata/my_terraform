# Module is re-usable
# When we use module for diffrent envirment then our state file will be overridden. then the state file will try to delete previous infrastructure.
# So if we use workspaces, it will create diffrent statefile for diffrent environment(dev, prod, DR) in diffrent folder.
# So we need to write only one terraform project. 

#Pratical
