# Using [bumpversion](https://pypi.python.org/pypi/bumpversion) in your python project
A Shell script to use python package [bumpversion](https://pypi.python.org/pypi/bumpversion) to modify project version.
 This changes the setup.py file and creates a commit on the current VCS (ie. Mecurail/Git).

The script provides a detailed output of the files changed
and the expected commit message which can be modified by changing the
`.bumpversiontemplate.cfg` file.


### Increases the project version according to the part(major|minor|patch)
#### patch
```1.1.1. --> 1.1.2```
#### minor
```1.1.1. --> 1.2.0```
#### major
```1.1.1. --> 2.0.0```


## Installation:

#### Download or clone the repository.
##### Run

```alias increase_version=/path/to/increase-version.sh```

#### OR

 ```source /path/to/increase-version.sh```

## Usage:
#### View Help Text
```increase_version -h```

#### Optionally argument project workspace path
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
