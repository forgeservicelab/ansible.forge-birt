FORGE BIRT master playbook
====================

Ansible playbook using roles birt-viewer, birt-reports, forge_ssl, ansible-postgresql and resource-usage-reporting

birt-viewer
------------

birt-viewer role deploys Tomcat, SQL connectors and birt runtime webapp as a user (Ubuntu) that has ssh and sudo access to the target machine. This role also creates a birt user with authorized keys (auth_key.pub for user access and auth_jenkins.pub for allowing Jenkins access).

birt-reports
------------

birt-reports role deploys report-designs for birt-viewer runtime. Reports are fetched from git as a birt user. Therefore the birt user has to have a correct private git_access_key in the target:~birt/.ssh/git_access_key and that the corresponding public key must have been set as a deployment key for the report-designs repository. You either transfer this file manually to the target machine or let the role transfer it by having it available in local:./files/git_access_key file and by uncommenting relevant lines in local:./roles/birt-reports/tasks/main.yml

forge_ssl
------------

forge_ssl role uploads FORGE server certificates and keys and looks the key from the master playbooks root directory. Therefore you must have the key stored in to local:./forgeservicelab.fi.key file.

ansible-postgresql
------------------

ansible-postgresql role contains helpers for making postgres database and user access easy. The role is used by postgres.yml playbook which sets up the db for resource usage reporting. This playbook is commented out in site.yml playbook because assumption is that the db exists in the remote db server.

resource-usage-reporting
------------------------

resource-usage-reporting role installs and configures an application that fetches iaas statistics and populates defined db with the data every day by cronjob as birt user.

Inventories and group_vars
--------------------------

You should check and have your desired variables defined in the targets you are planning to use.

	./development - defines a development target
	./testing - defines FORGE testing target
	./production - defines FORGE production target

	./group_vars/development.yml - settingss for the development target
	./group_vars/testing.yml - settingss for the FORGE testing target. Password protected.
	./group_vars/production.yml - settings for the FORGE production target. Password protected.

Examples
========

Install everything to the development target

	$ ansible-playbook -i development site.yml - installs everything except db creation is commented out by default

Install parts

	$ ansible-playbook -i development birt-reports.yml - installs report designs only
	$ ansible-playbook -i development birt-viewer.yml - installs birt-viewer runtimes only
	$ ansible-playbook -i development reporting.yml - installs iaas statistics data fetching application

Note! Some inventories and roles might have FORGE specific secrets to be deployed and therefore the vault password might be needed.

	$ ansible-playbook -i testing birt-viewer.yml --ask-vault-pass


Example - Run master playbook to setup a development machine
------------------------------------------------------------

Note! Development target is supposed to setup and use local postgres db instead of external db server used by testing and production targets. That's why step 1 is needed.

	1. Configure local postgresql db usage

	  Uncomment include: postgresql.yml in the site.yml so that you'll get the local postgresql db set up

	2. Install dependent roles

	  Install dependent roles prior to running any of the playbooks

	  $./ansible-galaxy install -r requirements.yml

	3. Create the VM instance and configure firewall

	  Create the virtual machine from Ubuntu 14.04 server image.
	  Set the firewall rules so that you have ssh, https and PostgreSQL access into it.
	  You might need to run apt-get update and apt-get upgrade.

	4. Check the inventory, settings and keys

	  ./development - Inventory
	  ./group_vars/development.yml - Development machine settings. Check all settings that are capitalized ie. all usernames and passwords and openstack settings
	  ./files/auth_key.pub - Have the authorized key for the birt user SSH access and for birt users's postgres access
	  ./files/auth_jenkins.pub - Have the authorized key of Jenkins to access target machine with ssh as birt user. Not needed by development target
	  ./forgeservicelab.fi.key - Have the FORGE server key used by fore_ssl role used by birt-viewer.yml playbook
	  ./files/git_access_key - Have the key you can use to access forge-birt-reportdesigns.git repository

	5. Run the playbook

	  $ ansible-playbook -i development site.yml --ask-vault-pass

	6. Verify

	  Use your web browser to check the birt is available in your VM
	  Check that birt user can access nova by issuing nova list
	  Check the birt user has cronjob enabled and after few days, check that cronjob run.
	  Check that resource_usage_reporting application is able to populate db


Notes! 
------

If you want to install git_access_key manually the, you should commented out the git_acess_key deployment tasks and copy the key manually to target:~/birt/.ssh/git_acess_key. If you let the Jenkins to run the playbook and use git, then make sure that Jenkins has the git_access_key too.
	
After running the playbook
--------------------

The newly deployed BIRT reports are available at the target machine as follows.

	https://{{ target_ip }}/birt-viewer/run?__report={{ reports_dir }}/{{ report_name }}&sample=my+parameter

	e.g.
	https://analytics.forgeservicelab.fi/birt-viewer/run?__report=forge_birt_reports/forge_status.rptdesign&sample=my+parameter
   

License
========================================

MIT

Author
========================================

Pasi Kivikangas, DIGILE LTd.
