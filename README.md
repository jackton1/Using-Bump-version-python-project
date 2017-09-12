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

## Usage:
### View Help Text using the ``-h`` option.
```upgrade-version.sh -h```

#### also pass an optional argument using the ``-w`` option and ```~/path/to/project```
```upgrade-version.sh -p minor -t -w /path/to/project```

#### Perform a test run
```upgrade-version.sh -p minor -t /path/to/project```
#### Perform an actual version change run
```upgrade-version.sh -p minor -m /path/to/project```




## Generated config file.

```cfg
[bumpversion]
current_version = 1.1.1
commit = True
tag = False
message = "Increased version: {current_version} to {new_version}"

[bumpversion:file:/path/to/project/setup.py]
```
