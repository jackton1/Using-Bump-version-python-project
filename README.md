# Using-Bump-version-python-project
A Shell script to use python package bumpversion to modify version of setup.py and create a commit  


## Changes the version with the part(major|minor|patch)


# Boiler Plate config template

```cfg
[bumpversion]
current_version = VERSION
commit = True
tag = False
message = "Increased version: {current_version} to {new_version}"

[bumpversion:file:WORKSPACE/setup.py]
```
