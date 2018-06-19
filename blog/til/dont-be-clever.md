# Don't be clever

An example with too clever code.

github.com/mattes/migrate/driver

```go
// New returns Driver and calls Initialize on it
func New(url string) (Driver, error) {
	u, err := neturl.Parse(url)
	if err != nil {
		return nil, err
	}

	d := GetDriver(u.Scheme)
	if d == nil {
		return nil, fmt.Errorf("Driver '%s' not found.", u.Scheme)
	}
	verifyFilenameExtension(u.Scheme, d)
	if err := d.Initialize(url); err != nil {
		return nil, err
	}

	return d, nil
}
```

Incompatible with cloudsql.



[Why most “clever” code ain’t so clever after all](https://drive.google.com/file/d/0B59Tysg-nEQZOGhsU0U5QXo0Sjg/view)

https://news.ycombinator.com/item?id=12081960