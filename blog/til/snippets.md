# Snippets

### Sync States

```go
type SyncState struct {
    Since time.Time
    Page  int
}

type advanceArgs struct {
	Done  bool
	Size  int
	Start time.Time
	End   time.Time
}

func advanceState(s SyncState, args advanceArgs) SyncState {
	done, size, start, end := args.Done, args.Size, args.Start, args.End
	since, page := s.Since, s.Page
	advanceTime := s.Since.Add(time.Millisecond)

	switch {
	case done && size == 0 && page == 1:
		return s
	case done && size == 0 && page > 1:
		return SyncState{advanceTime, 1}
	case done && size > 0:
		return SyncState{advanceTime, 1}
	case !done && start.Equal(end) && !end.IsZero():
		return SyncState{s.Since, page + 1}
	case !done && start.Before(end) && !end.IsZero():
		return SyncState{end, 1}
	}
    panic("unexpected")
}
```

