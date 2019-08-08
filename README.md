[![Build Status](https://travis-ci.org/maju6406/snow_record.svg?branch=master)](https://travis-ci.org/maju6406/snow_record)
[![Puppet Forge](https://img.shields.io/puppetforge/v/beersy/snow_record.svg)](https://forge.puppetlabs.com/beersy/snow_record)

# snow_record

This task manage records in ServiceNow.

#### Table of Contents

1. [Description](#description)
2. [Setup - The basics of getting started with snow_record](#setup)
3. [Usage - Configuration options and additional functionality](#usage)
4. [Examples](#examples)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

## Description

snow_record provides a series of tasks to interact with a ServiceNow Instance. The main 3 tasks included with this module:

* create - Create a ServiceNow object
* read - Get a ServiceNow object
* update - Update a ServiceNow object

There are also 2 additional tasks for interacting with Incidents.

* create_incident - Create an Incident
* resolve_incident - Resolve an Incident

Please read the [Limitations](#Limitations) before running these additional tasks.

## Setup

### Requirement for executing task

The [puppetlabs-ruby_task_helper](https://forge.puppet.com/puppetlabs/ruby_task_helper) module should be installed

## Usage

The tasks can be executed from bolt by supplying an basic inventory file:

* `name` ServiceNow Instance [name]..service-now.com
* `config` of which:
  * `transport` Always `remote`
* remote:
  * user: ServiceNow Username
  * password: ServiceNow Password  

For example:

```bash
nodes:
  - name: dev85564
    config:
      transport: remote
      remote:
        user: admin
        password: "XHxH2tmZ69*Vbh"
```

## Examples

### Getting incident INC000701

```bash
bolt task run --nodes dev85564 snow_record::read number=INC000701
```

### Getting incident from sys_id

```bash
bolt task run --nodes dev85564 snow_record::read lookup_field=sys_id number=ff4d21c4735123002728660c4cf6a758
```

### Getting user record from sys_id

```bash
bolt task run --nodes dev85564 snow_record::read table=sys_user lookup_field=sys_id number=fe82abf0371000044e0bfc8bcbe5d34
```

### Creating an user

```bash
bolt task run --nodes dev85564 snow_record::create table=sys_user data='{"first_name":"Frank","last_name":"Sinatra"}'
```

### Updating a user's city (using Update)

```bash
bolt task run --nodes dev85564 snow_record::update table=sys_user sys_id=fe82abf03710400044e0bfc8bcbe5d34 data='{"city":"Pittsburgh"}'
```

### Creating an incident

```bash
bolt task run --nodes dev85564 snow_record::create_incident urgency=1 priority=2 severity=3 additional_data='{"short_description":"This is a test incident opened by Puppet"}'
```

### Resolving an incident

```bash
bolt task run --nodes dev85564 snow_record::resolve_incident sys_id=fa8ecfe6db8363009395af264896199e close_notes="Closing Time1" additional_data='{"close_code":"Solved (Work Around)"}'
```

### A Sample plan
A sample plan is included in the [plans](http://github.com/maju6406/snow_record/plans) folder.
```bash
bolt plan run snow_record::example nodes=dev85564
```

## Limitations

These tasks have been tested with a Madrid developer instance. The task has been tested on macOS and Centos.

ServiceNow is a highly customized environment. `create_incident` and `resolve_incident` assume your incident states are similar to the default developer instance. If the create_incident and resolve_incident don't work for you, use the more generic `create` and `update` tasks.

## Development

TODOS:  

* Add more error handling
* Add more convenience tasks
* Add delete

Feel free to contribute. PRs on github always appreciated!

## Release Notes/Contributors/Etc. **Optional**

0.1 Initial release
