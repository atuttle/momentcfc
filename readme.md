# Moment.cfc

Inspired by moment.js, but not a strict port. With added Time Zone switchy goodness!

<img src="https://img.shields.io/badge/Lucee-6.2%2B-blue.svg" /> <img src="https://img.shields.io/badge/Adobe%20ColdFusion-2021%2B-blue.svg" /> <img src="https://img.shields.io/badge/awesomeness-11-orange.svg" />

CFML is all about making complex things simple, but date-math seems to have missed this boat.

| Adobe CF                                         | moment.cfc                                 |
|--------------------------------------------------|--------------------------------------------|
| `x = now();`                                     | `x = new moment();`                        |
| `y = createDateTime( 2008, 11, 27, 13, 47, 0 );` | `y = new moment( '2008-11-27 13:47:00' );` |
| `x = dateAdd( 'ww', 1, x );`                     | `x.add( 1, 'week' );`                      |
| `y = dateAdd( 'n', -30, y );`                    | `y.subtract( 30, 'minutes' );`             |
| `diff = dateDiff( 's', x, y );`                  | `diff = x.diff( y, 'seconds' );`           |
| `before = dateCompare( now(), x, 'h' ) == -1;`   | `before = x.isBefore( y, 'hours' );`       |

## Basic Date & Time Methods

#### Init

The constructor takes 0, 1, or 2 arguments.

- `new moment()` Use the current system time and the current system time zone
- `new moment( now() )` Use the specified time and the current system time zone
- `new moment( now(), 'America/Pacific' )` Use the specified time and the specified time zone

The datetime argument accepts a native CFML datetime object (e.g. `now()` or `createDateTime()`) or just a string (e.g. `2008-11-27 13:47`).

The time zone strings that moment expects are the internationalized strings, such as "America/New_York". You can find a full list [here](http://en.wikipedia.org/wiki/List_of_tz_database_time_zones#List), or have moment generate it for you -- but more on that later.

#### Add/Subtract some time

The syntax and format masks for `dateAdd()` aren't that hard to remember, but they also aren't very readable. We can do better...

	new moment().add(1, 'day').subtract(6, 'weeks');

Here's a list of all masks you can use with add/subtract:

- Years: `years`, `year`, `y`
- Quarters: `quarters`, `quarter`, `q`
- Weeks: `weeks`, `week`, `w` *
- Days: `days`, `day`, `d`
- Weekdays: `weekdays`, `weekday`, `wd` *
- Hours: `hours`, `hour`, `h`
- Minutes: `minutes`, `minute`, `n`
- Seconds: `seconds`, `second`, `s`
- Milliseconds: `milliseconds`, `millisecond`, `ms` * *

**\* Deviation from the official dateAdd mask:** Adobe, in their infinite wisdom, decided to use `ww` for weeks and `w` for weekdays. Moment uses the sane alternative defined here.

**\* \* Another deviation from the official dateAdd mask:** `ms` just makes more sense than the `l` (lower case L) that Adobe uses.

#### startOf / endOf

Shifts the date/time to the start or end of the specified date part. For example, the end of the current week*:

	endOfWeek = new moment().endOf('week');

Or the start of the next quarter:

	nextQuarter = new moment().startOf('quarter').add(1, 'quarter');

**\* Weeks are assumed to be Sun-Sat**

#### Clone

Returns a new moment instance with the same datetime and time zone.

	now_ = new moment();
	alsoNow = now_.clone();

#### Min/Max

To find the lower/upper date, use min/max:

	minTime = new moment().min( myMomentA, myMomentB );
	maxTime = new moment().max( myMomentA, myMomentB );

#### Difference

Find the difference between two datetimes in datepart units, considering time zone differences (their UTC times are compared):

	x = new moment();
	y = new moment( '2008-11-27 13:47' );
	diff = y.diff( x, 'hours' );

Returns the number of units that `y` is less than `x`.

The same masking values from `add`/`subtract` work with `diff`.

**NOTE:** Adobe ColdFusion does not support millisecond-level diffing, but it's not hard to add (lazy!)... So I did.

#### Format

Apply a [DateTimeFormat](https://wikidocs.adobe.com/wiki/display/coldfusionen/DateTimeFormat) mask to the current timestamp and return the resulting string.

	x = new moment();
	x.format( 'yyyy-mm-dd hh:nn:ss' );
	//=> "2008-11-27 13:47"

#### From

Fuzzy time difference description between the two moments, **always** phrased in past tense:

	x = new moment( '2008-11-27' );
	y = new moment();

	x.from( y );
	//=> 6 years ago

	y.from( x );
	//=> 6 years ago

#### FromNow

Shorthand for calling `from` when one of the comparators ~= `now()`.

	x = new moment( '2008-11-27' );
	x.fromNow();
	//=> 6 years ago

#### Epoch

Get your moment in its unix epoch format: milliseconds since 1970-01-01.

	x = new moment( '2008-11-27' );
	x.epoch();
	//=> 1227762000000

#### isBefore / isAfter

Compare two dates to determine which one is before/after the other. Default datepart precision is `seconds`.

	x = new moment( '2008-11-27' );
	y = new moment();
	old = x.isBefore( y, 'hours' );
	//=> true

	stillOld = y.isAfter( x, 'days' );
	//=> true

Here's a list of all precisions you can use with isBefore / isAfter:

- Years: `years`, `year`, `y`
- Months: `months`, `month`, `m`
- Days: `days`, `day`, `d`
- Hours: `hours`, `hour`, `h`
- Minutes: `minutes`, `minute`, `n`
- Seconds: `seconds`, `second`, `s`

#### isSame

Just like isBefore / isAfter, except you're testing that the two moments are the same, at least to the specified level of precision. Uses the same precisions as isBefore / isAfter.

	x = new moment( '2008-11-27 13:47' );
	y = new moment( '2008-11-27 6:30' );
	same = x.isSame( y, 'hours' );
	//=> true

#### isBetween

Determines if the current moment is between the two argument moments, at least to the specified level of precision.

	x = new moment( '2008-11-27 06:30' );
	y = new moment( '2008-11-27 13:47' );
	z = new moment( '2011-01-01 06:06' );
	betwixt = y.isBetween( x, z );
	//=> true

#### getDateTime

After all is said and done, sometimes you just need the raw datetime object back. This'll give it to you.

	raw = new moment( '2008-11-27 13:47' ).getDateTime();
	//=> {ts '2008-11-27 13:47:00'}

#### year, month, day, hour, minute, second

Read or write just one portion of the moment. Updates the moment instance in place.

	x = new moment();
	x.year();
	//=> returns the current year (numeric)

	x.year( 2000 );
	//=> updates the moment with the date/time rewound to the same moment in the year 2000 and returns it

The same pattern repeats for each of the following methods: `year()`, `month()`, `day()`, `hour()`, `minute()`, `second()`. Execute it with no arguments to get the current value, or execute it with an appropriate argument value to update the moment instance.

## Time Zones

In addition to all of the great date math you can do (with moment's better syntax), moment also has baked-in support for Time Zone functionality, using the robust underlying `java.util.TimeZone` class.

Create a timestamp in the US-Eastern time zone:

	x = new moment( '2008-11-27 13:47:00', 'America/New_York' );

When you don't pass a time zone argument, the current system time zone is used. When you don't pass a time argument, the current system time is used. `new moment()` and `new moment( '2008-11-27 13:47:00' )` and `new moment( '2008-11-27 13:47:00', 'America/New_York' )` are all equally valid.

#### UTC

Convert a moment's current time to its UTC value (also updates the internal time zone value to "UTC"):

	x.utc();

#### TZ

Instead of UTC, let's see what time that would have been in Phoenix using the `.tz()` method to change our moment to another time zone:

	new moment( '2008-11-27 13:47', 'America/New_York' ).tz( 'America/Phoenix' ).format( 'hh:nn' );
	//=> 03:06

And yes, all of the above methods (constructor as well as `.utc()` and `.tz()`) are chainable.

#### isDST

Curious if your current moment is during Daylight Saving Time?

	dst = new moment( '2008-11-27', 'America/New_York' ).isDST();
	//=> false

#### getZoneCurrentOffset

Return a time zone's current offset in seconds. This _does_ respect Daylight Saving Time:

	offset = new moment().getZoneCurrentOffset( 'Australia/Perth' );
	//=> 28800

#### getOffset

Get the current offset of a moment in seconds, without knowing its time zone:

	offset = myMoment.getOffset();

#### getArbitraryTimeOffset

Get the offset that was in use at the time in question.

	offset = myMoment.getArbitraryTimeOffset( '2015-02-01', 'America/New_York' );
	//=> -18000 because Feb 1 is before DST starts

	offset = myMoment.getArbitraryTimeOffset( '2015-03-20', 'America/New_York' );
	//=> -14400 because Mar 20 is during DST

#### getZone

Get the current time zone from the moment:

	myMoment.getZone();
	//=> "America/New_York"

#### getSystemTZ

Get your system time zone:

	myMoment.getSystemTZ();
	//=> "America/New_York"

#### getZoneTable

Get a list of all world time zones and their displayable offsets. This lists the zone's current offset, respecting their Daylight Saving Time rules:

	tbl = new moment().getZoneTable();
	//=> { "America/New_York": "-4:00", ... }

## Compatibility

Tests are run in these environments:

- Lucee 6 with Java 21
- Adobe ColdFusion 2018 with Java 11
- Adobe ColdFusion 2021 with Java 11
- Adobe ColdFusion 2023 with Java 17
- Adobe ColdFusion 2025 with Java 21

## Testing

Tests are automated via GitHub Actions.

Also see `/tests/run-local-tests.sh` for running locally.

## MIT Licensed

> Copyright (c) 2015 Adam Tuttle and Contributors
>
> Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
>
> The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
>
> THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
