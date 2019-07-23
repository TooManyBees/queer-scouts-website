# queerscouts.nyc website

Website for www.queerscouts.nyc. The very simple stack is:

* [Ruby](https://ruby-doc.org/)
* [Sinatra](http://sinatrarb.com/intro.html)
* [Thin](https://github.com/macournoyer/thin)
* [Nginx](http://nginx.org/en/docs/)

## Tasks done

1. Pulling events from Google calendar

## Needs review

1. Mission statement and/or short description
2. Contact page contents
3. Code of Conduct

## Unimplemented/ideas

1. an archive of past events/writeups?
2. an archive of den meeting notes?

# Maintenance

## DEPLOY!

```bash
rsync -azk --delete --exclude-from '.rsyncignore' $(pwd)/ "$USER@$HOST:$DESTINATION"
```

## START, STOP, GO AGAIN!

```bash
thin -S tmp/thin.sock --tag queerscouts $([[ "$RACK_ENV" == "production" ]] && "-d") start
```

```bash
thin stop
```

```bash
thin restart
```
