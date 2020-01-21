# xtsmooth - panel version of Stata's smooth command


## Installation

```stata
cap ado uninstall xtsmooth
net install xtsmooth, from("https://github.com/sergiocorreia/xtsmooth/raw/master/src")
```


## Local installation

```stata
cap ado uninstall xtsmooth
net install xtsmooth, from("C:\Git\xtsmooth\src")
```


## Differences with `smooth`

1. Slightly different results with the `S` smoother if there are two flat regions in a row (peaks/troughs).
2. Even-number smoothers (2, 4, 6, 8) are not implemented.
3. Data must have been `tsset` or `xtset` (to compare it with `smooth` you can always do `gen t = _n`; `tsset t`).
4. Missing values in the middle of a series will not raise an error but the data will be treated as two separate series.
3. The syntax is a bit more modern: `xtsmooth var, smoother(..) ..` instead of `xtsmooth smoother var, ...`.

