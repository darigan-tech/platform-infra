K3S must be installed first, use defaults unless we run into a problem.

Once K3S is installed, we can then deploy our services.

We have an ngnix website as an example for now. 

Our public ip + node_port for that service is how we access it online. 

What about volumes?
- Some Images, such as filebrowser, have dedicated volumes mount paths that should not change
- The host path version of these files should also require some set of permissions so they could modify and persist the files
- These reasons above are why filebrowser was failing to save any data.