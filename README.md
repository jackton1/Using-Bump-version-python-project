# Using [bumpversion](https://pypi.python.org/pypi/bumpversion) in python project
A Shell script to use python package bumpversion to modify version of setup.py and create a commit  


### Changes the version with the part(major|minor|patch)
#### patch 
```1.1.1. -> 1.1.2```
#### minor
```1.1.1. -> 1.2.0```
#### major 
```1.1.1. -> 2.0.0```


## Usage

### Optional ```~/path/to/project```
#### Test run
```./upgrade-version.sh test-project minor -t ~/path/to/project```
#### Main run
```./upgrade-version.sh test-project minor -m ~/path/to/project```




## Boiler Plate config template

```cfg
[bumpversion]
current_version = VERSION
commit = True
tag = False
message = "Increased version: {current_version} to {new_version}"

[bumpversion:file:WORKSPACE/setup.py]
```
