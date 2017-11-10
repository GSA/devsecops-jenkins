# devsecops-jenkins

This project uses terraform and ansible to deploy a GSA DevSecOps environment, specifically the Management VPC and Jenkins instance with RHEL hardening. This repo uses resources from [DevSecOps](https://github.com/GSA/DevSecOps), [Jenkins](https://github.com/GSA/devsecops-jenkins) and [ansible-os-rhel-7](https://github.com/GSA/ansible-os-rhel-7/) to harden the server with GSA baselines.

This repo will deploy:

* A VPC
* A public application subnet
* A Jenkins instance with the GSA.Jenkins Ansible role and baselined image, including a backup job to back itself up
* A private application subnet (with no resources inside of it)
* 2 private RDS subnets and a database subnet group (but does not provision any RDS instances)
* An S3 bucket to store Jenkins backups
* Necessary NAT gateways

This repo can be used against your own environment by setting the variables the way you want them, or left to the defaults. If you are working with GSA, it's preferable that you use the established procedures to get the proper CIDR ranges to use with this repo.

## Products In Use

* [`terraform/`](terraform/) - [Terraform](https://www.terraform.io/) code for setting up the infrastructure at the [Amazon Web Services (AWS)](https://aws.amazon.com/) level
* [`ansible/`](ansible/) - [Ansible](http://www.ansible.com) to deploy the Jenkins software on the instance (and manage future tools).

## Important concepts

### Configuration as code

All configuration is code, and [all setup steps are documented](#setup). New environment(s) can be created from scratch quickly and reliably. The Jenkins deployment is using the baseline [Ansible role created by GSA](https://github.com/GSA/Jenkins-deploy) to deploy Jenkins in a default state.

### DRY

The code follows the [Don’t Repeat Yourself (DRY)](https://en.wikipedia.org/wiki/Don%27t_repeat_yourself) principle. Values that need to be shared are passed around as variables, rather than being hard-coded in multiple places. This ensures configuration stays in sync.

## Setup

If you’ve already deployed the DevSecOps-Infrastructure repo, chances are you’ve already done some of this.

1. Set up the AWS CLI on the workstation that will be used to deploy the code.
    1. [Install](https://docs.aws.amazon.com/cli/latest/userguide/installing.html)
    1. [Configure](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html)
1. Install additional dependencies:
    * [Terraform](https://www.terraform.io/)
    * [Ansible](http://www.ansible.com/)
    * [Terraform-Inventory](https://github.com/adammck/terraform-inventory)

1. Set up the Terraform backend for this deployment. You will need to replace your bucket name with something unique, because bucket names must be unique per-region. If you get an error that the bucket name is not available, then your choice was not unique. Remember this bucket name, you’ll need it later.

    ```sh
    aws s3api create-bucket —bucket <your_unique_bucket_name>
    aws s3api put-bucket-versioning —<your_unique_bucket_name> —versioning-configuration Status=Enabled
    ```

1. Create the Terraform variables file.

    ```sh
    cd terraform
    cp terraform.tfvars.example terraform.tfvars
    cp backend.tfvars.example backend.tfvars
    ```

1. Fill out [`terraform.tfvars`](terraform/terraform.tfvars.example). Mind the variable types and follow the noted rules. Defaults are provided in [`variables.tfvars`](Terraform/variables.tfvars) if you need examples or want to see where values are coming from.

1. Fill out [‘backend.tfvars’](terraform/backend.tfvars.example). The “bucket” parameter *must* match the bucket name you used in the AWS CLI command above, otherwise terraform will throw an error on the init command.

1. Set up an [Ansible Vault](https://docs.ansible.com/ansible/playbooks_vault.html) with values that are secret and should not be stored in plain text on disk. Follow these steps if you wish to keep things as out of the box as possible. If you use different filenames, you will need to modify the Makefile.

* Generate an SSH key.

    ```sh
    ssh-keygen -t rsa -b 4096 -f temp.key -C "group-email+jenkins@some.gov"
    # enter a passphrase - store in Vault as vault_jenkins_ssh_key_passphrase (see below)

    cat temp.key
    # store in Vault as vault_jenkins_ssh_private_key_data (see below)

    cat temp.key.pub
    # store as jenkins_ssh_public_key_data (see below)

    rm temp.key*
    ```

* Generate a self-signed SSL certificate or get one. You will need the private key and the certificate file to paste into the vault.

* Set up the required variables files that are specific to Jenkins/Ansible. Create the following directories:

    ````sh
    /ansible/group_vars
                |
                /all
                |
                /devsecops_mgmt_jenkins_master_eip
    ````

    Note that the directory "devsecops_mgmt_jenkins_master_eip" is set to this name to target the Jenkins master host that will be created. When the Ansible playbook is executed, terraform-inventory is called against the terraform.tfstate backend to obtain information about the host that was deployed. This keyboard is used to identify the instance that was created for Ansible to install Jenkins. You may wish to modify the playbook to meet your requirements.

    Fill out the file with the following data:

    ````sh
    # group_vars/devsecops_mgmt_jenkins_master_eip/vars.yml
    jenkins_external_hostname: <some-fqdn-hostname>
    jenkins_ssh_key_passphrase: "{{ vault_jenkins_ssh_key_passphrase }}"
    jenkins_ssh_private_key_data: "{{ vault_jenkins_ssh_private_key_data }}"
    ssl_certs_local_cert_data: "{{ vault_ssl_certs_local_cert_data }}"
    ssl_certs_local_privkey_data: "{{ vault_ssl_certs_local_privkey_data }}"
    jenkins_admin_username: <username for the admin user in web interface>
    jenkins_admin_password: "{{vault_jenkins_admin_password}}"
    jenkins_ssh_user: <username for ssh user>
    jenkins_ssh_public_key_data: |
    <public-key-data-from-above-steps>
    jenkins_java_options:
    ````

    "jenkins_java_options" overrides the geerlingguy.jenkins role to specify java_opt to pass along to Jenkins when running. Set heapsize or other options here, if they are needed. Note the use of variables preceded by "vault." These variables must be defined in another file in this same directory. Create a new file called "vault.yml" with ansible-vault:

    ````sh
    ansible-vault create vault.yml
    ````

    This command will ask for a password to encrypt the file and launch a text editor (likely vi). Fill out the variables like the example below.

    ````sh
    # group_vars/devsecops_mgmt_jenkins_master_eip/vault.yml (encrypted)
    vault_jenkins_ssh_key_passphrase: ...(if one was used)
    vault_jenkins_ssh_private_key_data: |
      -----BEGIN RSA PRIVATE KEY-----
      ...(key data from above procedures)
      -----END RSA PRIVATE KEY-----
    vault_ssl_certs_local_cert_data: |
      -----BEGIN CERTIFICATE-----
      ...(paste SSL certificate info here)
      -----END CERTIFICATE-----
    vault_ssl_certs_local_privkey_data: |
      -----BEGIN RSA PRIVATE KEY-----
      ...(paste SSL certificate key info here)
      -----END RSA PRIVATE KEY-----
    vault_jenkins_admin_password: <type a password here>
    ````

    Save the file in the text editor and then verify the encryption.

    If you wish, you can create another file called ".vault_pass.txt". Store this file in the /ansible/playbooks directory. This file should contain the vault password on a line by itself. If you do not wish to store the vault password on disk, then you must modify the playbook file /ansible/playbooks/jenkins-master.yml and remove the command reference to the file. You can ask interactively for the password or store the password file elsewhere. For more details, consult the [Ansible Vault](https://docs.ansible.com/ansible/playbooks_vault.html) documentation.

### Hardening

This repo also uses the GSA ansible role to harden the server according to GSA security baselines. The repo for the hardening is located at [this url](https://github.com/GSA/ansible-os-rhel-7/).

Hardening variables can be overridden in the vars.yml file mentioned above. Simply scan the playbooks within the role and set variables in vars.yml according to your specifications if there is a need to override the hardening baselines. This deployment, as configured within source control, should not need to be overriden.

## Deployment

For initial deployment, use the ansible make file to make things easier.

1. Set up environment. For your convenience, terraform commands are provided in the ansible Makefile. If you’re confident in your variable-fu, you can just kick off the “make” command and build the architecture from scratch. This will install all of the necessary roles,

    ```sh
    cd ansible
    make
    ```
This will run all of the commands in order. If you want to break things down into steps, you’re welcome to do them manually:

* make install_roles
* make init
* make plan
* make apply
* make install_jenkins

There is also a “make debug” in the Makefile. This will run all of the steps the same way, except for the last one. It will run “make install_jenkins_debug”, which will run ansible in full debug mode. Most problems will occur in variables, so pay careful attention to the variables and the values they expect.

“make destroy” will destroy the environment should you wish. You will have to confirm before it will actually destroys anything.

## Notes

This deployment will automatically install the GSA.Jenkins role and all dependencies. Those roles will be downloaded during the “make install_roles” phase. The roles will be install in “/ansible/roles/external”.
