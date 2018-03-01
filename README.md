# Using [bumpversion](https://pypi.python.org/pypi/bumpversion) in your python project to modify project version.

### Generating `.bumpversion.cfg` file for each project can be a repetitive task that this project aims to simplify.

[bumpversion](https://pypi.python.org/pypi/bumpversion) changes the `setup.py` file and creates a commit on the current VCS (ie. Mecurail/Git)

> With a few commands your project configuration should be dynamically created.
- creating sample `.bumpversion.cfg` template in the project folder
- Added support for runing bumpversion with the new configuration directly 
- Supports using the bumversion dry-run.


The script provides a detailed output of the files changed and the expected commit message which can be modified by changing the `.bumpversiontemplate.cfg` file. 

All new templates are created using the `.bumpversiontemplate.cfg` so changes made to the file will reflect in all projects you use the script.


## Install:

#### Download or clone the repository.

```
$ git clone https://github.com/jackton1/bumpversion-template.git
```

##### Add execute permission if required. 
```
$ chmod +x /path/to/increase-version.sh
```

##### Add line to ``~/.bashrc`` or ``~/.zshrc`` depending on the shell startup script used.
```alias increase_version=/path/to/increase-version.sh```

#### OR 
 ```
 $ source /path/to/increase-version.sh
 ```
 

### Increases the project version according to the part(major|minor|patch)
#### patch
```1.1.1. --> 1.1.2```
#### minor
```1.1.1. --> 1.2.0```
#### major
```1.1.1. --> 2.0.0```


## Usage:
#### View Help Text
```increase_version -h```

#### Optional argument specify the project workspace path
using the ``-w`` option and ```~/path/to/project```.

```increase_version -p minor -t -w /path/to/project```

#### Perform a test run with the project name.
```increase_version -p minor -t project_name```
#### Perform an actual version change run
```increase_version -p minor -m project_name```

#### Delete the generated config template after run using the ``-r`` option.
```increase_version -p minor -r -m project_name```


## Generated sample config file.

```cfg
[bumpversion]
current_version = 1.1.1
commit = True
tag = False
message = "Increased version: {current_version} to {new_version}"

[bumpversion:file:test_project/setup.py]
```
