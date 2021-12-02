package collections

import (
	"sort"
	"testing"

	. "github.com/smartystreets/goconvey/convey"
	"go.uber.org/goleak"
)

func TestStringSet(t *testing.T) {
	goleak.VerifyNone(t)

	Convey("NewStringSet(...)", t, func() {
		stringSet := NewStringSet()

		Convey("Should not be nil", func() {
			So(stringSet, ShouldNotBeNil)
		})
	})

	Convey("NewStringSetFromArray(...)", t, func() {
		stringSet := NewStringSetFromArray([]string{
			"oneThing",
			"twoThing",
			"redThing",
			"blueThing",
		})

		Convey("Should not be nil", func() {
			So(stringSet, ShouldNotBeNil)
		})

		Convey("Should have 4 members", func() {
			So(stringSet.Size(), ShouldEqual, 4)
		})

		Convey("Should have the expected members", func() {
			So(stringSet.Contains("oneThing"), ShouldBeTrue)
			So(stringSet.Contains("twoThing"), ShouldBeTrue)
			So(stringSet.Contains("redThing"), ShouldBeTrue)
			So(stringSet.Contains("blueThing"), ShouldBeTrue)
		})
	})

	Convey("StringSet.Size()", t, func() {
		stringSet := NewStringSetFromArray([]string{"1", "2"})

		Convey("Should return 2", func() {
			So(stringSet.Size(), ShouldEqual, 2)
		})
	})

	Convey("StringSet.Contains(...)", t, func() {
		stringSet := NewStringSetFromArray([]string{"1", "2"})

		Convey("Should return true when given an element in the set", func() {
			So(stringSet.Contains("1"), ShouldBeTrue)
			So(stringSet.Contains("2"), ShouldBeTrue)
		})

		Convey("Should return false when given an element not in the set", func() {
			So(stringSet.Contains("3"), ShouldBeFalse)
		})
	})

	Convey("StringSet.Add(...)", t, func() {
		stringSet := NewStringSet()
		stringSet.Add("x")
		stringSet.Add("y")

		Convey("Should have added the specified elements", func() {
			So(stringSet.Size(), ShouldEqual, 2)
		})
	})

	Convey("StringSet.Remove(...)", t, func() {
		stringSet := NewStringSetFromArray([]string{"1", "2"})
		stringSet.Remove("1")

		Convey("Should have removed the specified element", func() {
			So(stringSet.Contains("1"), ShouldBeFalse)
		})

		Convey("Should not have removed other elements", func() {
			So(stringSet.Contains("2"), ShouldBeTrue)
		})
	})

	Convey("StringSet.Members()", t, func() {
		stringSet := NewStringSetFromArray([]string{"1", "2"})
		members := stringSet.Members()
		sort.Strings(members)

		Convey("Should return an array of the members of the set", func() {
			So(len(members), ShouldEqual, 2)
			So(members[0], ShouldEqual, "1")
			So(members[1], ShouldEqual, "2")
		})
	})
}
