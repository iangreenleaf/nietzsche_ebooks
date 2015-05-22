# Totally real Nietzsche quotes #

## Updating ##

```
rake fetch
ebooks consume-all nietzsche texts/converted/*.txt
```

## Deployment ##

```
heroku create
heroku config:push
git push heroku master
heroku ps:scale worker=1
```
