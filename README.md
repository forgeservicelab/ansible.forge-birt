FORGE BIRT master playbook
====================

Ansible playbook using roles birt-viewer, birt-reports, forge_ssl, ansible-postgresql and resource-usage-reporting

birt-viewer role deploys Tomcat, SQL connectors and birt runtime webapp as a user (Ubuntu) that has ssh and sudo access to the target machine. This role also creates a birt user with authorized keys (birt.pub for user access and jenkins.pub for allowing Jenkins access).

birt-reports role deploys report-designs for birt-viewer runtime. Reports are fetched from git as a birt user. Therefore the birt user has to have a correct private git_access_key in the target:~birt/.ssh/git_access_key and that the corresponding public key must have been set as a deployment key for the report-designs repository. You either transfer this file manually to the target machine or let the role transfer it by having it in local:./files/git_access_key file and by uncommenting relevant lines in local:./roles/birt-reports/tasks/main.yml

forge_ssl role uploads FORGE server certificates and keys and therefore you must have a key nstored in to local:./forgeservicelab.fi.key file.

ansible-postgresql role contains helpers for making postgres database and user access easy in local:./tasks/postgres.yml and sets up the db for resource usage reporting in case not using external db server. This role is commented out in the site.yml since FORGE is using external db server.

resource-usage-reporting role installs and configures an application that fetches iaas statistics and populates the postgres db with the data every day by cronjob of the birt user.

These roles are invoked accordingly by the following playbooks using the syntax

	$ ansible-playbook -i development site.yml

Playbooks

	./site.yml - installs everything except setting up postgres db is commented out
	./birt-reports.yml - installs report designs only
	./birt-viewer.yml - installs birt-viewer runtimes only
	./reporting.yml - installs iaas statistics data fetching application

Check these
--------------------

Settings for the targets overrides roles' defaults.

	./group_vars/development.yml - settingss for the development target
	./group_vars/testing.yml - settingss for the testing target
	./group_vars/production.yml - settings for the production target

Inventory files

	./development - an inventory file for the development target
	./testing - an inventory file for the testing target
	./production - an inventory file for the production target

Keys and other files

	./files/auth_key.pub - authorized key of postgresql user
	./files/birt.pub - authorized key of yours to access target machine with ssh as birt user
	./files/jenkins.pub - authorized key of Jenkins to access target machine with ssh as birt user
	./forgeservicelab.fi.key - FORGE server key used by fore_ssl role


Before running the playbook(s)
--------------------

You should install dependent roles prior to running the playbooks.

	$ ansible-galaxy install -r requirements.yml

After running the playbook for the first time
--------------------

If you want to install git_access_key manually the, you should commented out the git_acess_key deployment tasks and copy the key manually to target:~/birt/.ssh/git_acess_key. If you let the Jenkins to run the playbook and use git, then make sure that Jenkins has the git_access_key counterpart.

The inventory files
--------------------

This playbook targets any target that is defined in inventory. To deploy everything to the development target machine

    $ ansible-playbook -i development site.yml

To deploy underlying birt-viewer web app only

	$ ansible-playbook -i development birt-viewer.yml

To deploy birt-report files only to the target that already has birt-viewer web app deployed

	$ ansible-playbook -i develompent birt-reports.yml

Note! Some roles might have some FORGE speficic secrets to be deployed too and therefore the vault password might be needed.

	$ ansible-playbook -i development birt-viewer.yml --ask-vault-pass
	
After running the playbook
--------------------

The newly deployed BIRT reports are available at the target machine as follows.

   https://{{ target_ip }}/birt-viewer/run?__report={{ reports_dir }}/{{ report_name }}&sample=my+parameter   

   e.g.
   https://analytics.forgeservicelab.fi/birt-viewer/run?__report=forge_birt_reports/forge_status.rptdesign&sample=my+parameter
