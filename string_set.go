package collections

import "reflect"

// StringSet provides a set-like structure for string keys.
// Adapted from https://play.golang.org/p/tDdutH672-
type StringSet struct {
	set map[string]bool
}

// NewStringSet will initialize a new, empty StringSet.
func NewStringSet() *StringSet {
	return &StringSet{make(map[string]bool)}
}

// NewStringSetFromArray will initialize a new StringSet, and populate it from the given array.
func NewStringSetFromArray(members []string) *StringSet {
	set := NewStringSet()
	for _, val := range members {
		set.Add(val)
	}
	return set
}

// Add will add the specified string to the set, if it hasn't already been added.
func (set *StringSet) Add(i string) bool {
	_, found := set.set[i]
	set.set[i] = true
	return !found
}

// Contains will determine whether or not the specified string is contained in the set.
func (set *StringSet) Contains(i string) bool {
	_, found := set.set[i]
	return found
}

// Remove will remove the specified string from the set.
func (set *StringSet) Remove(i string) {
	delete(set.set, i)
}

// Size will tell you how many values are in the set.
func (set *StringSet) Size() int {
	return len(set.set)
}

// Members will return the list of set members, as an array of strings.
func (set *StringSet) Members() []string {
	keys := reflect.ValueOf(set.set).MapKeys()
	strkeys := make([]string, len(keys))
	for i := 0; i < len(keys); i++ {
		strkeys[i] = keys[i].String()
	}
	return strkeys
}
