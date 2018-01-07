## Description

This library contains shared components between the differnet apps in the roznet account.

It is added in the other project via a subtree approach

```
git remote add rzutils https://github.com/roznet/rzutils.git
git subtree add --prefix=RZUtils rzutils master --squash
```

the other projects are then updated with latest version with

```
git subtree pull --prefix=RZUtils rzutils master --squash
```

and can be pushed back with

```
git subtree push --prefix=RZUtils rzutils master
```
