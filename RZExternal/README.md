## Description

This library contains the snapshots of external library used by the apps in the roznet account.

It is added in the other project via a subtree approach

```
git remote add rzexternal https://github.com/roznet/rzexternal.git
git subtree add --prefix=RZExternal rzexternal master --squash
```

the other projects are then updated with latest version with

```
git subtree pull --prefix=RZExternal rzexternal master --squash
```

and can be pushed back with

```
git subtree push --prefix=RZExternal rzexternal master
```


