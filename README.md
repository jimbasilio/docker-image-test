# Introduction

Run `runtest.sh` in bash (git bash works fine on windows) in order to test to prove out that docker base layers that are tagged with consistent tags (i.e. latest, base, v1, v2) but are UPDATED, will cause those that use those tags as base images in their Dockerfiles will pull in updates if they are also rebuilt.

The question is:
* if we create a base image with tags like the jvm (i.e. `jdk8`)
* and we build containers FROM that tag (i.e. `FROM myorg:jdk8`)
* and we then update `myorg:jdk8` with a tweak, like adjusting HEAP size or something perhaps that could ripple poorly like a new jvm patch version

Will we then get the new updated patched `myorg:jdk8` or will we get the original, unpatched version on a downstream build of that tagged image.

# Files

## Dockerfile.base
Base image which contains simple node hello world program.
Runs on port 3000
Runs app.base.js
Returns Hello World!
TAGGED jim:base

## Dockerfile.base.bugfix
Inherits from base
Runs app.first.js
Returns Hello World! FIXED!
TAGGED jim:base

## Dockerfile.first
Inherits from base
Runs app.first.js
Returns Hello World AGAIN!
TAGGED jim:first

## Dockerfile.first.bugfix
Inherits from base
Has no override of CMD, therefore will pickup whatever CMD is in the parent (this should be built after Dockerfile.base.bugfix is run and will serve as the FROM base layer)
TAGGED jim:first

# runtest.sh
This shell script will build the base image `jim:base`, then build a consumer of this base image `jim:first`. The script will then rebuild the base image with a new CMD that will execute and return a new hello world string (still tagged `jim:base`). It will finally rebuild the downstream `jim:first` image but this time leaving out the CMD so that the parents CMD will execute.

The result if we somehow didn't re-use the parent's original base image would be `Hello World!`. But I expect that instead the last result will be `Hello World! FIXED!` because the upstream FROM base image has changed, and when docker runs to build the image it'll pull in the newest tag.

# Conclusion
My conclusion is that if you want to create tags, you must build in versioning for the tags where YOUR `Dockerfile` is unique. i.e. If you use `jdk8` in your tagging, but in your `Dockerfile` you also make unique adjustments (ex. Heap size), you will need to also add some significant piece of information to your tag, perhaps a version. `jdk8.1`, `jdk8.2` or something similar would work fine for this. `jdk8.1` may have original HEAP settings, but `jdk8.2` would have different HEAP settings. Anyone that uses these base images will have to adjust their `FROM` line in their `Dockerfile` to be the right upstream tag.