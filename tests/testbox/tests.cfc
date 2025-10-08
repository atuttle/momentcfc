component extends="testbox.system.BaseSpec" {

	function run(){

		//normalize moment instance creation over various environments
		var moment = function(){
			try {
				return new moment(argumentCollection=arguments);
			} catch(any e) {
				try {
					return new momentcfc.moment(argumentCollection=arguments);
				} catch(any e) {
					try {
						return new demo.momentcfc.moment(argumentCollection=arguments);
					} catch(any e) {
						throw(message="can't find moment!");
					}
				}
			}
		};

		describe("CONSTRUCTOR", function(){

			it("uses current time and local tz when no-args", function(){
				var test = moment();
				var compare = now();
				// Use getSystemTZ() to avoid Java 21 module issues
				var localTZ = test.getSystemTZ();
				expect( test.getZone() ).toBe( localTZ );
				expect( test.getDateTime() ).toBe( compare );
			});

			it("uses local tz when 1-arg", function(){
				var test = moment( now() );
				// Use getSystemTZ() to avoid Java 21 module issues
				var compare = test.getSystemTZ();

				expect( test.getZone() ).toBe( compare );
			});

			it("uses args when 2-args", function(){
				var compare = now();
				var test = moment( compare, "UTC" );
				expect( test.getZone() ).toBe( "UTC" );
				expect( test.getDateTime() ).toBe( compare );
			});

			it("accepts a datetime string as the first arg", function(){
				var test = moment( '2008-11-27 6:06' );
				expect( test ).toBeComponent();
			});

		});

		describe("MUTATORS", function(){

			describe("utc()", function(){
				it("correctly calculates the utc value", function(){
					outsideDST = moment('2015-02-01 00:00:00', 'America/New_York').utc();
					insideDST = moment('2015-03-20 00:00:00', 'America/New_York').utc();

					expect( outsideDST.getZone() ).toBe( "UTC" );
					expect( outsideDST.format("HH:nn:ss") ).toBe( '05:00:00' );
					expect( insideDST.format("HH:nn:ss") ).toBe( '04:00:00' );
				});
			});

			describe("tz()", function(){
				it("changes the timezone and the datetime", function(){
					var compare = now();
					var test = moment( compare );
					var utc = moment().utc();
					test.tz( "Pacific/Apia" );

					expect( test.getZone() ).toBe( "Pacific/Apia" );
					expect( test.getDateTime() ).notToBe( compare );
					expect( test.getDateTime() ).notToBe( utc.getDateTime() );
				});
			});

			describe("add()", function(){

				it("supports masks: years, year, and y", function(){
					var compare = now();
					var compare2 = dateAdd('yyyy', 1, compare);
					var test1 = moment( compare );
					var test2 = moment( compare );
					var test3 = moment( compare );

					expect( test1.getDateTime() ).toBe( compare );
					expect( test1.add(1, 'years').getDateTime() ).toBe( compare2 );
					expect( test2.add(1, 'year').getDateTime() ).toBe( compare2 );
					expect( test3.add(1, 'y').getDateTime() ).toBe( compare2 );
				});

				it("supports masks: quarters, quarter, and q", function(){
					var compare = now();
					var compare2 = dateAdd('q', 1, compare);
					var test1 = moment( compare );
					var test2 = moment( compare );
					var test3 = moment( compare );

					expect( test1.getDateTime() ).toBe( compare );
					expect( test1.add(1, 'quarters').getDateTime() ).toBe( compare2 );
					expect( test2.add(1, 'quarter').getDateTime() ).toBe( compare2 );
					expect( test3.add(1, 'q').getDateTime() ).toBe( compare2 );
				});

				it("supports masks: months, month, and m", function(){
					var compare = now();
					var compare2 = dateAdd('m', 1, compare);
					var test1 = moment( compare );
					var test2 = moment( compare );
					var test3 = moment( compare );

					expect( test1.getDateTime() ).toBe( compare );
					expect( test1.add(1, 'months').getDateTime() ).toBe( compare2 );
					expect( test2.add(1, 'month').getDateTime() ).toBe( compare2 );
					expect( test3.add(1, 'm').getDateTime() ).toBe( compare2 );
				});

				it("supports masks: days, day, and d", function(){
					var compare = now();
					var compare2 = dateAdd('d', 1, compare);
					var test1 = moment( compare );
					var test2 = moment( compare );
					var test3 = moment( compare );

					expect( test1.getDateTime() ).toBe( compare );
					expect( test1.add(1, 'days').getDateTime() ).toBe( compare2 );
					expect( test2.add(1, 'day').getDateTime() ).toBe( compare2 );
					expect( test3.add(1, 'd').getDateTime() ).toBe( compare2 );
				});

				it("supports masks: weekdays, weekday, and wd", function(){
					var compare = now();
					var compare2 = dateAdd('w', 1, compare);
					var test1 = moment( compare );
					var test2 = moment( compare );
					var test3 = moment( compare );

					expect( test1.getDateTime() ).toBe( compare );
					expect( test1.add(1, 'weekdays').getDateTime() ).toBe( compare2 );
					expect( test2.add(1, 'weekday').getDateTime() ).toBe( compare2 );
					expect( test3.add(1, 'wd').getDateTime() ).toBe( compare2 );
				});

				it("supports masks: weeks, week, and w", function(){
					var compare = now();
					var compare2 = dateAdd('ww', 1, compare);
					var test1 = moment( compare );
					var test2 = moment( compare );
					var test3 = moment( compare );

					expect( test1.getDateTime() ).toBe( compare );
					expect( test1.add(1, 'weeks').getDateTime() ).toBe( compare2 );
					expect( test2.add(1, 'week').getDateTime() ).toBe( compare2 );
					expect( test3.add(1, 'w').getDateTime() ).toBe( compare2 );
				});

				it("supports masks: hours, hour, and h", function(){
					var compare = now();
					var compare2 = dateAdd('h', 1, compare);
					var test1 = moment( compare );
					var test2 = moment( compare );
					var test3 = moment( compare );

					expect( test1.getDateTime() ).toBe( compare );
					expect( test1.add(1, 'hours').getDateTime() ).toBe( compare2 );
					expect( test2.add(1, 'hour').getDateTime() ).toBe( compare2 );
					expect( test3.add(1, 'h').getDateTime() ).toBe( compare2 );
				});

				it("supports masks: minutes, minute, and n", function(){
					var compare = now();
					var compare2 = dateAdd('n', 1, compare);
					var test1 = moment( compare );
					var test2 = moment( compare );
					var test3 = moment( compare );

					expect( test1.getDateTime() ).toBe( compare );
					expect( test1.add(1, 'minutes').getDateTime() ).toBe( compare2 );
					expect( test2.add(1, 'minute').getDateTime() ).toBe( compare2 );
					expect( test3.add(1, 'n').getDateTime() ).toBe( compare2 );
				});

				it("supports masks: seconds, second, and s", function(){
					var compare = now();
					var compare2 = dateAdd('s', 1, compare);
					var test1 = moment( compare );
					var test2 = moment( compare );
					var test3 = moment( compare );

					expect( test1.getDateTime() ).toBe( compare );
					expect( test1.add(1, 'seconds').getDateTime() ).toBe( compare2 );
					expect( test2.add(1, 'second').getDateTime() ).toBe( compare2 );
					expect( test3.add(1, 's').getDateTime() ).toBe( compare2 );
				});

				it("supports masks: milliseconds, millisecond, and ms", function(){
					var compare = now();
					var compare2 = dateAdd('l', 1, compare);
					var test1 = moment( compare );
					var test2 = moment( compare );
					var test3 = moment( compare );

					expect( test1.getDateTime() ).toBe( compare );
					expect( test1.add(1, 'milliseconds').getDateTime() ).toBe( compare2 );
					expect( test2.add(1, 'millisecond').getDateTime() ).toBe( compare2 );
					expect( test3.add(1, 'ms').getDateTime() ).toBe( compare2 );
				});

			});

			describe("subtract()", function(){

				it("supports masks: years, year, and y", function(){
					var compare = now();
					var compare2 = dateAdd('yyyy', -1, compare);
					var test1 = moment( compare );
					var test2 = moment( compare );
					var test3 = moment( compare );

					expect( test1.getDateTime() ).toBe( compare );
					expect( test1.subtract(1, 'years').getDateTime() ).toBe( compare2 );
					expect( test2.subtract(1, 'year').getDateTime() ).toBe( compare2 );
					expect( test3.subtract(1, 'y').getDateTime() ).toBe( compare2 );
				});

				it("supports masks: quarters, quarter, and q", function(){
					var compare = now();
					var compare2 = dateAdd('q', -1, compare);
					var test1 = moment( compare );
					var test2 = moment( compare );
					var test3 = moment( compare );

					expect( test1.getDateTime() ).toBe( compare );
					expect( test1.subtract(1, 'quarters').getDateTime() ).toBe( compare2 );
					expect( test2.subtract(1, 'quarter').getDateTime() ).toBe( compare2 );
					expect( test3.subtract(1, 'q').getDateTime() ).toBe( compare2 );
				});

				it("supports masks: months, month, and m", function(){
					var compare = now();
					var compare2 = dateAdd('m', -1, compare);
					var test1 = moment( compare );
					var test2 = moment( compare );
					var test3 = moment( compare );

					expect( test1.getDateTime() ).toBe( compare );
					expect( test1.subtract(1, 'months').getDateTime() ).toBe( compare2 );
					expect( test2.subtract(1, 'month').getDateTime() ).toBe( compare2 );
					expect( test3.subtract(1, 'm').getDateTime() ).toBe( compare2 );
				});

				it("supports masks: days, day, and d", function(){
					var compare = now();
					var compare2 = dateAdd('d', -1, compare);
					var test1 = moment( compare );
					var test2 = moment( compare );
					var test3 = moment( compare );

					expect( test1.getDateTime() ).toBe( compare );
					expect( test1.subtract(1, 'days').getDateTime() ).toBe( compare2 );
					expect( test2.subtract(1, 'day').getDateTime() ).toBe( compare2 );
					expect( test3.subtract(1, 'd').getDateTime() ).toBe( compare2 );
				});

				it("supports masks: weekdays, weekday, and wd", function(){
					var compare = now();
					var compare2 = dateAdd('w', -1, compare);
					var test1 = moment( compare );
					var test2 = moment( compare );
					var test3 = moment( compare );

					expect( test1.getDateTime() ).toBe( compare );
					expect( test1.subtract(1, 'weekdays').getDateTime() ).toBe( compare2 );
					expect( test2.subtract(1, 'weekday').getDateTime() ).toBe( compare2 );
					expect( test3.subtract(1, 'wd').getDateTime() ).toBe( compare2 );
				});

				it("supports masks: weeks, week, and w", function(){
					var compare = now();
					var compare2 = dateAdd('ww', -1, compare);
					var test1 = moment( compare );
					var test2 = moment( compare );
					var test3 = moment( compare );

					expect( test1.getDateTime() ).toBe( compare );
					expect( test1.subtract(1, 'weeks').getDateTime() ).toBe( compare2 );
					expect( test2.subtract(1, 'week').getDateTime() ).toBe( compare2 );
					expect( test3.subtract(1, 'w').getDateTime() ).toBe( compare2 );
				});

				it("supports masks: hours, hour, and h", function(){
					var compare = now();
					var compare2 = dateAdd('h', -1, compare);
					var test1 = moment( compare );
					var test2 = moment( compare );
					var test3 = moment( compare );

					expect( test1.getDateTime() ).toBe( compare );
					expect( test1.subtract(1, 'hours').getDateTime() ).toBe( compare2 );
					expect( test2.subtract(1, 'hour').getDateTime() ).toBe( compare2 );
					expect( test3.subtract(1, 'h').getDateTime() ).toBe( compare2 );
				});

				it("supports masks: minutes, minute, and n", function(){
					var compare = now();
					var compare2 = dateAdd('n', -1, compare);
					var test1 = moment( compare );
					var test2 = moment( compare );
					var test3 = moment( compare );

					expect( test1.getDateTime() ).toBe( compare );
					expect( test1.subtract(1, 'minutes').getDateTime() ).toBe( compare2 );
					expect( test2.subtract(1, 'minute').getDateTime() ).toBe( compare2 );
					expect( test3.subtract(1, 'n').getDateTime() ).toBe( compare2 );
				});

				it("supports masks: seconds, second, and s", function(){
					var compare = now();
					var compare2 = dateAdd('s', -1, compare);
					var test1 = moment( compare );
					var test2 = moment( compare );
					var test3 = moment( compare );

					expect( test1.getDateTime() ).toBe( compare );
					expect( test1.subtract(1, 'seconds').getDateTime() ).toBe( compare2 );
					expect( test2.subtract(1, 'second').getDateTime() ).toBe( compare2 );
					expect( test3.subtract(1, 's').getDateTime() ).toBe( compare2 );
				});

				it("supports masks: milliseconds, millisecond, and ms", function(){
					var compare = now();
					var compare2 = dateAdd('l', -1, compare);
					var test1 = moment( compare );
					var test2 = moment( compare );
					var test3 = moment( compare );

					expect( test1.getDateTime() ).toBe( compare );
					expect( test1.subtract(1, 'milliseconds').getDateTime() ).toBe( compare2 );
					expect( test2.subtract(1, 'millisecond').getDateTime() ).toBe( compare2 );
					expect( test3.subtract(1, 'ms').getDateTime() ).toBe( compare2 );
				});

			});

			describe("startOf()", function(){
				it("supports masks: year", function(){
					start = moment('2016-02-05 00:05:00', 'America/New_York');
					expect( start.startOf("year").format("yyyy-mm-dd HH:nn:ss") ).toBe( "2016-01-01 00:00:00" );
				});
				it("supports masks: quarter", function(){
					start = moment('2016-02-05 00:05:00', 'America/New_York');
					expect( start.startOf("quarter").format("yyyy-mm-dd HH:nn:ss") ).toBe( "2016-01-01 00:00:00" );
				});
				it("supports masks: month", function(){
					start = moment('2016-02-05 00:05:00', 'America/New_York');
					expect( start.startOf("month").format("yyyy-mm-dd HH:nn:ss") ).toBe( "2016-02-01 00:00:00" );
				});
				it("supports masks: week", function(){
					start = moment('2016-02-05 00:05:00', 'America/New_York');
					expect( start.startOf("week").format("yyyy-mm-dd HH:nn:ss") ).toBe( "2016-01-31 00:00:00" );
				});
				it("supports masks: day", function(){
					start = moment('2016-02-05 00:05:00', 'America/New_York');
					expect( start.startOf("day").format("yyyy-mm-dd HH:nn:ss") ).toBe( "2016-02-05 00:00:00" );
				});
				it("supports masks: hour", function(){
					start = moment('2016-02-05 03:05:00', 'America/New_York');
					expect( start.startOf("hour").format("yyyy-mm-dd HH:nn:ss") ).toBe( "2016-02-05 03:00:00" );
				});
				it("supports masks: minute", function(){
					start = moment('2016-02-05 00:05:17', 'America/New_York');
					expect( start.startOf("minute").format("yyyy-mm-dd HH:nn:ss") ).toBe( "2016-02-05 00:05:00" );
				});
			});

			describe("endOf()", function(){
				it("supports masks: year", function(){
					start = moment('2016-02-05 00:05:00', 'America/New_York');
					expect( start.endOf("year").format("yyyy-mm-dd HH:nn:ss") ).toBe( "2016-12-31 23:59:59" );
				});
				it("supports masks: quarter", function(){
					start = moment('2016-02-05 00:05:00', 'America/New_York');
					expect( start.endOf("quarter").format("yyyy-mm-dd HH:nn:ss") ).toBe( "2016-03-31 23:59:59" );
				});
				it("supports masks: month", function(){
					start = moment('2016-02-05 00:05:00', 'America/New_York');
					expect( start.endOf("month").format("yyyy-mm-dd HH:nn:ss") ).toBe( "2016-02-29 23:59:59" );
				});
				it("supports masks: week", function(){
					start = moment('2016-02-05 00:05:00', 'America/New_York');
					expect( start.endOf("week").format("yyyy-mm-dd HH:nn:ss") ).toBe( "2016-02-06 23:59:59" );
				});
				it("supports masks: day", function(){
					start = moment('2016-02-05 00:05:00', 'America/New_York');
					expect( start.endOf("day").format("yyyy-mm-dd HH:nn:ss") ).toBe( "2016-02-05 23:59:59" );
				});
				it("supports masks: hour", function(){
					start = moment('2016-02-05 00:05:00', 'America/New_York');
					expect( start.endOf("hour").format("yyyy-mm-dd HH:nn:ss") ).toBe( "2016-02-05 00:59:59" );
				});
				it("supports masks: minute", function(){
					start = moment('2016-02-05 00:05:00', 'America/New_York');
					expect( start.endOf("minute").format("yyyy-mm-dd HH:nn:ss") ).toBe( "2016-02-05 00:05:59" );
				});
			});

		});

		describe("STATICS", function(){

			describe("clone()", function(){
				it("returns a moment", function(){
					var test = moment();
					var clone = test.clone();

					expect( clone ).toBeComponent();
					expect( clone.isSame( test ) ).toBeTrue();
				});
			});

			describe("min()", function(){

				it("works with winner on left", function(){
					var a = moment();
					var b = a.clone().add(1, 'day');

					expect( b.min( a, b ) ).toBe( a );
				});

				it("works with winner on right", function(){
					var a = moment();
					var b = a.clone().add(1, 'day');

					expect( b.min( b, a ) ).toBe( a );
				});

			});

			describe("max()", function(){

				it("works with winner on left", function(){
					var a = moment();
					var b = a.clone().subtract(1, 'day');

					expect( b.max( a, b ) ).toBe( a );
				});

				it("works with winner on right", function(){
					var a = moment();
					var b = a.clone().subtract(1, 'day');

					expect( b.max( b, a ) ).toBe( a );
				});

			});

			describe("diff()", function(){

				it("works for years, year, y", function(){
					var base = now();
					var pushA = dateAdd('yyyy', 20, base );
					var pushB = dateAdd('yyyy', -20, base );
					var test1 = moment( base );
					var test2 = moment( pushA );
					var test3 = moment( pushB );

					expect( test1.diff( moment(base), 'y' ) ).toBe( 0 );
					expect( test1.diff( test2, 'years' ) ).toBe( dateDiff( 'yyyy', base, pushA ) );
					expect( test1.diff( test2, 'year'  ) ).toBe( dateDiff( 'yyyy', base, pushA ) );
					expect( test1.diff( test2, 'y'     ) ).toBe( dateDiff( 'yyyy', base, pushA ) );
					expect( test1.diff( test3, 'years' ) ).toBe( dateDiff( 'yyyy', base, pushB ) );
					expect( test1.diff( test3, 'year'  ) ).toBe( dateDiff( 'yyyy', base, pushB ) );
					expect( test1.diff( test3, 'y'     ) ).toBe( dateDiff( 'yyyy', base, pushB ) );
				});

				it("works for quarters, quarter, q", function(){
					var base = now();
					var pushA = dateAdd('q', 5, base );
					var pushB = dateAdd('q', -5, base );
					var test1 = moment( base );
					var test2 = moment( pushA );
					var test3 = moment( pushB );

					expect( test1.diff( moment(base), 'q' ) ).toBe( 0 );
					expect( test1.diff( test2, 'quarters' ) ).toBe( dateDiff( 'q', base, pushA ) );
					expect( test1.diff( test2, 'quarter'  ) ).toBe( dateDiff( 'q', base, pushA ) );
					expect( test1.diff( test2, 'q'        ) ).toBe( dateDiff( 'q', base, pushA ) );
					expect( test1.diff( test3, 'quarters' ) ).toBe( dateDiff( 'q', base, pushB ) );
					expect( test1.diff( test3, 'quarter'  ) ).toBe( dateDiff( 'q', base, pushB ) );
					expect( test1.diff( test3, 'q'        ) ).toBe( dateDiff( 'q', base, pushB ) );
				});

				it("works for months, month, m", function(){
					var base = now();
					var pushA = dateAdd('m', 5, base );
					var pushB = dateAdd('m', -5, base );
					var test1 = moment( base );
					var test2 = moment( pushA );
					var test3 = moment( pushB );

					expect( test1.diff( moment(base), 'm' ) ).toBe( 0 );
					expect( test1.diff( test2, 'months' ) ).toBe( dateDiff( 'm', base, pushA ) );
					expect( test1.diff( test2, 'month'  ) ).toBe( dateDiff( 'm', base, pushA ) );
					expect( test1.diff( test2, 'm'      ) ).toBe( dateDiff( 'm', base, pushA ) );
					expect( test1.diff( test3, 'months' ) ).toBe( dateDiff( 'm', base, pushB ) );
					expect( test1.diff( test3, 'month'  ) ).toBe( dateDiff( 'm', base, pushB ) );
					expect( test1.diff( test3, 'm'      ) ).toBe( dateDiff( 'm', base, pushB ) );
				});

				it("works for weeks, week, w", function(){
					var base = now();
					var pushA = dateAdd('ww', 5, base );
					var pushB = dateAdd('ww', -5, base );
					var test1 = moment( base );
					var test2 = moment( pushA );
					var test3 = moment( pushB );

					expect( test1.diff( moment(base), 'w' ) ).toBe( 0 );
					expect( test1.diff( test2, 'weeks' ) ).toBe( dateDiff( 'ww', base, pushA ) );
					expect( test1.diff( test2, 'week'  ) ).toBe( dateDiff( 'ww', base, pushA ) );
					expect( test1.diff( test2, 'w'     ) ).toBe( dateDiff( 'ww', base, pushA ) );
					expect( test1.diff( test3, 'weeks' ) ).toBe( dateDiff( 'ww', base, pushB ) );
					expect( test1.diff( test3, 'week'  ) ).toBe( dateDiff( 'ww', base, pushB ) );
					expect( test1.diff( test3, 'w'     ) ).toBe( dateDiff( 'ww', base, pushB ) );
				});

				it("works for days, day, d", function(){
					var base = now();
					var pushA = dateAdd('m', 5, base );
					var pushB = dateAdd('m', -5, base );
					var test1 = moment( base );
					var test2 = moment( pushA );
					var test3 = moment( pushB );

					expect( test1.diff( moment(base), 'd' ) ).toBe( 0 );
					expect( test1.diff( test2, 'days' ) ).toBe( dateDiff( 'd', base, pushA ) );
					expect( test1.diff( test2, 'day'  ) ).toBe( dateDiff( 'd', base, pushA ) );
					expect( test1.diff( test2, 'd'    ) ).toBe( dateDiff( 'd', base, pushA ) );
					expect( test1.diff( test3, 'days' ) ).toBe( dateDiff( 'd', base, pushB ) );
					expect( test1.diff( test3, 'day'  ) ).toBe( dateDiff( 'd', base, pushB ) );
					expect( test1.diff( test3, 'd'    ) ).toBe( dateDiff( 'd', base, pushB ) );
				});

				it("works for weekdays, weekday, wd", function(){
					var base = now();
					var pushA = dateAdd('w', 5, base );
					var pushB = dateAdd('w', -5, base );
					var test1 = moment( base );
					var test2 = moment( pushA );
					var test3 = moment( pushB );

					expect( test1.diff( moment(base), 'w' ) ).toBe( 0 );
					expect( test1.diff( test2, 'weekdays' ) ).toBe( dateDiff( 'w', base, pushA ) );
					expect( test1.diff( test2, 'weekday'  ) ).toBe( dateDiff( 'w', base, pushA ) );
					expect( test1.diff( test2, 'wd'       ) ).toBe( dateDiff( 'w', base, pushA ) );
					expect( test1.diff( test3, 'weekdays' ) ).toBe( dateDiff( 'w', base, pushB ) );
					expect( test1.diff( test3, 'weekday'  ) ).toBe( dateDiff( 'w', base, pushB ) );
					expect( test1.diff( test3, 'wd'       ) ).toBe( dateDiff( 'w', base, pushB ) );
				});

				it("works for hours, hour, h", function(){
					var base = now();
					var pushA = dateAdd('h', 5, base );
					var pushB = dateAdd('h', -5, base );
					var test1 = moment( base );
					var test2 = moment( pushA );
					var test3 = moment( pushB );

					expect( test1.diff( moment(base), 'h' ) ).toBe( 0 );
					expect( test1.diff( test2, 'hours' ) ).toBe( dateDiff( 'h', base, pushA ) );
					expect( test1.diff( test2, 'hour'  ) ).toBe( dateDiff( 'h', base, pushA ) );
					expect( test1.diff( test2, 'h'     ) ).toBe( dateDiff( 'h', base, pushA ) );
					expect( test1.diff( test3, 'hours' ) ).toBe( dateDiff( 'h', base, pushB ) );
					expect( test1.diff( test3, 'hour'  ) ).toBe( dateDiff( 'h', base, pushB ) );
					expect( test1.diff( test3, 'h'     ) ).toBe( dateDiff( 'h', base, pushB ) );
				});

				it("works for minutes, minute, n", function(){
					var base = now();
					var pushA = dateAdd('n', 5, base );
					var pushB = dateAdd('n', -5, base );
					var test1 = moment( base );
					var test2 = moment( pushA );
					var test3 = moment( pushB );

					expect( test1.diff( moment(base), 'n' ) ).toBe( 0 );
					expect( test1.diff( test2, 'minutes' ) ).toBe( dateDiff( 'n', base, pushA ) );
					expect( test1.diff( test2, 'minute'  ) ).toBe( dateDiff( 'n', base, pushA ) );
					expect( test1.diff( test2, 'n'       ) ).toBe( dateDiff( 'n', base, pushA ) );
					expect( test1.diff( test3, 'minutes' ) ).toBe( dateDiff( 'n', base, pushB ) );
					expect( test1.diff( test3, 'minute'  ) ).toBe( dateDiff( 'n', base, pushB ) );
					expect( test1.diff( test3, 'n'       ) ).toBe( dateDiff( 'n', base, pushB ) );
				});

				it("works for seconds, second, s", function(){
					var base = now();
					var pushA = dateAdd('s', 5, base );
					var pushB = dateAdd('s', -5, base );
					var test1 = moment( base );
					var test2 = moment( pushA );
					var test3 = moment( pushB );

					expect( test1.diff( moment(base), 's' ) ).toBe( 0 );
					expect( test1.diff( test2, 'seconds' ) ).toBe( dateDiff( 's', base, pushA ) );
					expect( test1.diff( test2, 'second'  ) ).toBe( dateDiff( 's', base, pushA ) );
					expect( test1.diff( test2, 's'       ) ).toBe( dateDiff( 's', base, pushA ) );
					expect( test1.diff( test3, 'seconds' ) ).toBe( dateDiff( 's', base, pushB ) );
					expect( test1.diff( test3, 'second'  ) ).toBe( dateDiff( 's', base, pushB ) );
					expect( test1.diff( test3, 's'       ) ).toBe( dateDiff( 's', base, pushB ) );
				});

				it("works for milliseconds, millisecond, ms", function(){
					var base = now();
					var pushA = dateAdd('l', 5, base );
					var pushB = dateAdd('l', -5, base );
					var test1 = moment( base );
					var test2 = moment( pushA );
					var test3 = moment( pushB );

					expect( test1.diff( moment(base), 'ms' ) ).toBe( 0 );
					expect( test1.diff( test2, 'milliseconds' ) ).toBe( pushA.getTime() - base.getTime() );
					expect( test1.diff( test2, 'millisecond'  ) ).toBe( pushA.getTime() - base.getTime() );
					expect( test1.diff( test2, 'ms'           ) ).toBe( pushA.getTime() - base.getTime() );
					expect( test1.diff( test3, 'milliseconds' ) ).toBe( pushB.getTime() - base.getTime() );
					expect( test1.diff( test3, 'millisecond'  ) ).toBe( pushB.getTime() - base.getTime() );
					expect( test1.diff( test3, 'ms'           ) ).toBe( pushB.getTime() - base.getTime() );
				});

			});

			describe("getZoneCurrentOffset()", function(){
				it("returns the offset in seconds (considering DST) of the specified zone", function(){
					var offset4h = -4*60*60;
					var offset5h = -5*60*60;

					var m = moment( now(), 'America/New_York' );
					var expectedOffset = m.isDST() ? offset4h : offset5h;

					expect( m.getZoneCurrentOffset( 'America/New_York' ) ).toBe( expectedOffset );
				});
			});

			describe("getSystemTZ()", function(){
				it("is a simple wrapper of core Java functionality, without need of testing", function(){});
			});

			describe("getZoneTable()", function(){
				it("returns a struct", function(){
					var tbl = moment().getZoneTable();
					expect( tbl ).toBeStruct();
					expect( tbl ).notToBeEmpty();
				});
			});

		});

		describe("TERMINATORS", function(){

			describe("format()", function(){
				
				it("formats standard masks correctly across time zones", function(){
				
					var testZones = [
						{ zone: 'Asia/Hong_Kong', short: 'HKT', shortDST: 'HKT' },
						{ zone: 'America/Los_Angeles', short: 'PST', shortDST: 'PDT' }
					];

					//these dates + times were chosen to have leading zeros in all applicable places, as well as being in and out of DST
					//2009 DST was May 8 to Nov 1
					var timeNoDST = '2009-03-05 09:03:07';
					var timeDST = '2009-03-09 09:03:07';

					for(var z in testZones){
						var testNoDST = moment( timeNoDST, z.zone );
						var testDST = moment( timeDST, z.zone );

						//basic date and time fields; these could easily pass through to dateTimeFormat

						expect( testNoDST.format('yyyy') ).toBe( '2009' );
						expect( testNoDST.format('yy') ).toBe( '09' );
						expect( testNoDST.format('mmmm') ).toBe( 'March' );
						expect( testNoDST.format('mmm') ).toBe( 'Mar' );
						expect( testNoDST.format('mm') ).toBe( '03' );
						expect( testNoDST.format('m') ).toBe( '3' );
						expect( testNoDST.format('EEEE') ).toBe( 'Thursday' );
						expect( testNoDST.format('EEE') ).toBe( 'Thu' );
						expect( testNoDST.format('dd') ).toBe( '05' );
						expect( testNoDST.format('d') ).toBe( '5' );

						expect( testNoDST.format('h') ).toBe( '9' );
						expect( testNoDST.format('hh') ).toBe( '09' );
						expect( testNoDST.format('H') ).toBe( '9' );
						expect( testNoDST.format('HH') ).toBe( '09' );
						expect( testNoDST.format('n') ).toBe( '3' );
						expect( testNoDST.format('nn') ).toBe( '03' );
						expect( testNoDST.format('s') ).toBe( '7' );
						expect( testNoDST.format('ss') ).toBe( '07' );

						expect( testDST.format('yyyy') ).toBe( '2009' );
						expect( testDST.format('yy') ).toBe( '09' );
						expect( testDST.format('mmmm') ).toBe( 'March' );
						expect( testDST.format('mmm') ).toBe( 'Mar' );
						expect( testDST.format('mm') ).toBe( '03' );
						expect( testDST.format('m') ).toBe( '3' );
						expect( testDST.format('EEEE') ).toBe( 'Monday' );
						expect( testDST.format('EEE') ).toBe( 'Mon' );
						expect( testDST.format('dd') ).toBe( '09' );
						expect( testDST.format('d') ).toBe( '9' );

						expect( testDST.format('h') ).toBe( '9' );
						expect( testDST.format('hh') ).toBe( '09' );
						expect( testDST.format('H') ).toBe( '9' );
						expect( testDST.format('HH') ).toBe( '09' );
						expect( testDST.format('n') ).toBe( '3' );
						expect( testDST.format('nn') ).toBe( '03' );
						expect( testDST.format('s') ).toBe( '7' );
						expect( testDST.format('ss') ).toBe( '07' );

						// DEPRECATED TESTS: check formattings with time zones
						// The 'long' format test is inherently fragile because
						// it includes system-specific timezone abbreviations.
						// Also, Java 21 introduced breaking change from comma after year.
						// expect( testNoDST.format('long') ).toBe( 'March 5, 2009 9:03:07 AM #z.short#' );
						// expect( testDST.format('long') ).toBe( 'March 9, 2009 9:03:07 AM #z.shortDST#' );
					}
				});
				
				it("works for custom masks", function(){
					var base = now();
					var mask = 'yyyy-mm-dd hh:nn:sstt';
					var compare = dateTimeFormat(base, mask);
					var test = moment( base );
					expect( test.format( mask ) ).toBe( compare );
				});
				
				it("works with the mysql mask", function(){
					var base = now();
					var compare = dateTimeFormat( base, 'yyyy-mm-dd HH:nn:ss' );
					var test = moment( base );
					expect( test.format( 'mysql' )).toBe( compare );
				});
				
				it("works with the mssql mask", function(){
					var base = now();
					var compare = dateTimeFormat(base, 'yyyy-mm-dd') & 'T' & dateTimeFormat(base, 'HH:nn:ss') & 'Z';
					var test = moment( base );
					expect( test.format( 'mssql' )).toBe( compare );
				});
			
			});

			describe("from()", function(){
				var base = moment();

				it("detects multiple years", function(){
					var test = base.clone().add( 3, 'years' ).add( 3, 'weeks' );
					var test2 = base.clone().add( 3, 'years' ).subtract( 3, 'weeks' );
					expect( test.from( base ) ).toBe( '3 years ago' );
				});

				it("detects single years", function(){
					var test = base.clone().add( 1, 'year' ).add( 3, 'weeks' );
					var test2 = base.clone().add( 1, 'year' ).subtract( 3, 'weeks' );
					expect( test.from( base ) ).toBe( 'Last year' );
				});

				it("detects multiple months", function(){
					var test = base.clone().add( 8, 'months' ).add( 3, 'days' );
					var test2 = base.clone().add( 8, 'months' ).subtract( 3, 'days' );
					expect( test.from( base ) ).toBe( '8 months ago' );
				});

				it("detects single months", function(){
					var test = base.clone().add( 1, 'months' ).add( 3, 'days' );
					var test2 = base.clone().add( 1, 'months' ).subtract( 3, 'days' );
					expect( test.from( base ) ).toBe( '4 weeks ago' );
				});

				it("detects multiple weeks", function(){
					var test = base.clone().add( 3, 'weeks' ).add( 2, 'hours' );
					var test2 = base.clone().add( 3, 'weeks' ).subtract( 2, 'hours' );
					expect( test.from( base ) ).toBe( '3 weeks ago' );
				});

				it("detects single weeks", function(){
					var test = base.clone().add( 1, 'weeks' ).add( 2, 'hours' );
					var test2 = base.clone().add( 1, 'weeks' ).subtract( 2, 'hours' );
					expect( test.from( base ) ).toBe( '1 week ago' );
				});

				it("detects days", function(){
					var test = base.clone().add( 4, 'days' ).add( 2, 'hours' );
					var test2 = base.clone().add( 4, 'days' ).subtract( 2, 'hours' );
					expect( test.from( base ) ).toBe( '4 days ago' );
				});

				it("detects yesterday", function(){
					var test = base.clone().add( 1, 'days' ).add( 3, 'hours' ).subtract( 11, 'minutes' );
					expect( test.from( base ) ).toBe( 'Yesterday' );
				});

				it("detects multiple hours", function(){
					var test = base.clone().add( 4, 'hours' ).add( 15, 'minutes' );
					var test2 = base.clone().add( 4, 'hours' ).subtract( 15, 'minutes' );
					expect( test.from( base ) ).toBe( '4 hours ago' );
				});

				it("detects single hours", function(){
					var test = base.clone().add( 1, 'hours' ).add( 15, 'minutes' );
					var test2 = base.clone().add( 1, 'hours' ).subtract( 15, 'minutes' );
					expect( test.from( base ) ).toBe( '1 hour ago' );
				});

				it("detects multiple minutes", function(){
					var test = base.clone().add( 10, 'minutes' ).add( 15, 'seconds' );
					var test2 = base.clone().add( 10, 'minutes' ).subtract( 15, 'seconds' );
					expect( test.from( base ) ).toBe( '10 minutes ago' );
				});

				it("detects single minutes", function(){
					var test = base.clone().add( 1, 'minute' ).add( 15, 'seconds' );
					expect( test.from( base ) ).toBe( '1 minute ago' );
				});

				it("detects seconds", function(){
					var test = base.clone().add( 20, 'seconds' ).add( 100, 'ms' );
					var test2 = base.clone().add( 20, 'seconds' ).subtract( 100, 'ms' );
					expect( test.from( base ) ).toBe( 'Just now' );
				});
			});

			describe("fromNow()", function(){
				it("is just a wrapper for from, so it gets a pass",function(){});
			});

			describe("epoch()", function(){
				
				it("gets the correct epoch from a PST time", function(){
					var zone = 'America/Los_Angeles';
					var test = moment( '2008-11-27 6:06', zone );
					expect( test.epoch() ).toBe( 1227794760000 );
				});

				it("gets the correct epoch from a EDT time", function(){
					var zone = 'America/New_York';
					var test = moment( '2015-03-20', zone );
					expect( test.epoch() ).toBe( 1426824000000 );
				});

				it("gets the correct epoch from a UTC time", function(){
					var zone = 'UTC';
					var test = moment( '2015-03-20', zone );
					expect( test.epoch() ).toBe( 1426809600000 );
				});

				it("is still correct if you change the target TZ after initialization", function(){
					var startzone = 'America/Los_Angeles';
					var newzone = 'Asia/Hong_Kong';
					var m = moment( '2008-11-27 6:06', startzone );
					expect( m.epoch() ).toBe( 1227794760000 );
					m.tz( newzone );
					expect( m.epoch() ).toBe( 1227794760000 );
					expect( m.format('yyyy-mm-dd HH:nn') ).toBe( '2008-11-27 22:06' );
				});
			
			});

			describe("getDateTime()", function(){
				it("returns a native time object", function(){
					var test = moment();
					expect( left( test.getDateTime(), 3) ).toBe( '{ts' );
				});
			});

			describe("getZone()", function(){
				it("returns a string", function(){
					var test = moment();
					expect( test.getZone() ).toBeString();
					expect( test.getZone() ).notToBeEmpty();
				});
			});

			describe("getOffset()", function(){
				it("returns the correct offset", function(){
					//this may be troublesome if tested in another zone... we'll see!
					var test = moment( now(), 'America/New_York' );
					expect( test.getOffset() ).toBe( test.isDST() ? -14400 : -18000 );
				});
			});

			describe("year()", function(){
				it("returns the current value when argument is empty", function(){
					var d = moment('2015-03-20 00:00:00', 'America/New_York');
					expect( d.year() ).toBe( 2015 );
				});
				it("returns an updated moment when argument is not empty", function(){
					var d = moment('2015-03-20 00:00:00', 'America/New_York');
					var test = d.year( 2014 );
					expect( test ).toBeComponent();
					expect( test.format('yyyy') ).toBe( 2014 );
					expect( test.format('mm') ).toBe( 3 );
					expect( test.format('dd') ).toBe( 20 );
				});
			});

			describe("month()", function(){
				it("returns the current value when argument is empty", function(){
					var d = moment('2015-03-20 00:00:00', 'America/New_York');
					expect( d.month() ).toBe( 3 );
				});
				it("returns an updated moment when argument is not empty", function(){
					var d = moment('2015-03-20 00:00:00', 'America/New_York');
					var test = d.month( 5 );
					expect( test ).toBeComponent();
					expect( test.format('yyyy') ).toBe( 2015 );
					expect( test.format('mm') ).toBe( 5 );
					expect( test.format('dd') ).toBe( 20 );
				});
			});

			describe("day()", function(){
				it("returns the current value when argument is empty", function(){
					var d = moment('2015-03-20 00:00:00', 'America/New_York');
					expect( d.day() ).toBe( 20 );
				});
				it("returns an updated moment when argument is not empty", function(){
					var d = moment('2015-03-20 00:00:00', 'America/New_York');
					var test = d.day( 7 );
					expect( test ).toBeComponent();
					expect( test.format('yyyy') ).toBe( 2015 );
					expect( test.format('mm') ).toBe( 03 );
					expect( test.format('dd') ).toBe( 7 );
				});
			});

			describe("hour()", function(){
				it("returns the current value when argument is empty", function(){
					var d = moment('2015-03-20 09:00:00', 'America/New_York');
					expect( d.hour() ).toBe( 9 );
				});
				it("returns an updated moment when argument is not empty", function(){
					var d = moment('2015-03-20 09:10:11', 'America/New_York');
					var test = d.hour( 13 );
					expect( test ).toBeComponent();
					expect( test.format('yyyy') ).toBe( 2015 );
					expect( test.format('mm') ).toBe( 03 );
					expect( test.format('dd') ).toBe( 20 );
					expect( test.format('HH') ).toBe( 13 );
					expect( test.format('nn') ).toBe( 10 );
					expect( test.format('ss') ).toBe( 11 );
				});
			});

			describe("minute()", function(){
				it("returns the current value when argument is empty", function(){
					var d = moment('2015-03-20 09:03:00', 'America/New_York');
					expect( d.minute() ).toBe( 3 );
				});
				it("returns an updated moment when argument is not empty", function(){
					var d = moment('2015-03-20 09:10:11', 'America/New_York');
					var test = d.minute( 44 );
					expect( test ).toBeComponent();
					expect( test.format('yyyy') ).toBe( 2015 );
					expect( test.format('mm') ).toBe( 03 );
					expect( test.format('dd') ).toBe( 20 );
					expect( test.format('HH') ).toBe( 09 );
					expect( test.format('nn') ).toBe( 44 );
					expect( test.format('ss') ).toBe( 11 );
				});
			});

			describe("second()", function(){
				it("returns the current value when argument is empty", function(){
					var d = moment('2015-03-20 09:00:59', 'America/New_York');
					expect( d.second() ).toBe( 59 );
				});
				it("returns an updated moment when argument is not empty", function(){
					var d = moment('2015-03-20 09:10:11', 'America/New_York');
					var test = d.second( 22 );
					expect( test ).toBeComponent();
					expect( test.format('yyyy') ).toBe( 2015 );
					expect( test.format('mm') ).toBe( 03 );
					expect( test.format('dd') ).toBe( 20 );
					expect( test.format('HH') ).toBe( 9 );
					expect( test.format('nn') ).toBe( 10 );
					expect( test.format('ss') ).toBe( 22 );
				});
			});

		});

		describe("QUERY", function(){

			describe("isBefore", function(){
				var base = moment();
				var clone = base.clone();
				var test = base.clone().add(10, 'years');

				it("works on true", function(){
					expect( base.isBefore( test, 'years' )).toBeTrue();
					expect( base.isBefore( test, 'months' )).toBeTrue();
					expect( base.isBefore( test, 'days' )).toBeTrue();
					expect( base.isBefore( test, 'hours' )).toBeTrue();
					expect( base.isBefore( test, 'minutes' )).toBeTrue();
					expect( base.isBefore( test, 'seconds' )).toBeTrue();
				});
				it("works on false", function(){
					expect( test.isBefore( base, 'years' )).toBeFalse();
					expect( test.isBefore( base, 'months' )).toBeFalse();
					expect( test.isBefore( base, 'days' )).toBeFalse();
					expect( test.isBefore( base, 'hours' )).toBeFalse();
					expect( test.isBefore( base, 'minutes' )).toBeFalse();
					expect( test.isBefore( base, 'seconds' )).toBeFalse();
				});
				it("works on same", function(){
					expect( test.isBefore( clone, 'years' )).toBeFalse();
					expect( test.isBefore( clone, 'months' )).toBeFalse();
					expect( test.isBefore( clone, 'days' )).toBeFalse();
					expect( test.isBefore( clone, 'hours' )).toBeFalse();
					expect( test.isBefore( clone, 'minutes' )).toBeFalse();
					expect( test.isBefore( clone, 'seconds' )).toBeFalse();
				});
			});

			describe("isAfter", function(){
				var base = moment();
				var clone = base.clone();
				var test = base.clone().subtract(10, 'years');

				it("works on true", function(){
					expect( base.isAfter( test, 'years' )).toBeTrue();
					expect( base.isAfter( test, 'months' )).toBeTrue();
					expect( base.isAfter( test, 'days' )).toBeTrue();
					expect( base.isAfter( test, 'hours' )).toBeTrue();
					expect( base.isAfter( test, 'minutes' )).toBeTrue();
					expect( base.isAfter( test, 'seconds' )).toBeTrue();
				});
				it("works on false", function(){
					expect( test.isAfter( base, 'years' )).toBeFalse();
					expect( test.isAfter( base, 'months' )).toBeFalse();
					expect( test.isAfter( base, 'days' )).toBeFalse();
					expect( test.isAfter( base, 'hours' )).toBeFalse();
					expect( test.isAfter( base, 'minutes' )).toBeFalse();
					expect( test.isAfter( base, 'seconds' )).toBeFalse();
				});
				it("works on same", function(){
					expect( test.isAfter( clone, 'years' )).toBeFalse();
					expect( test.isAfter( clone, 'months' )).toBeFalse();
					expect( test.isAfter( clone, 'days' )).toBeFalse();
					expect( test.isAfter( clone, 'hours' )).toBeFalse();
					expect( test.isAfter( clone, 'minutes' )).toBeFalse();
					expect( test.isAfter( clone, 'seconds' )).toBeFalse();
				});
			});

			describe("isSame", function(){
				var base = moment();

				it("works when cloned", function(){
					var clone = base.clone();
					expect( base.isSame( clone )).toBeTrue();
				});
				it("works when before", function(){
					var test = base.clone().subtract(5, 'months');
					expect( base.isSame( test )).toBeFalse();
				});
				it("works when after", function(){
					var test = base.clone().add(5, 'months');
					expect( base.isSame( test )).toBeFalse();
				});
			});

			describe("isBetween", function(){
				var x = moment('2001-09-11');
				var y = moment('2008-11-27');
				var z = moment('2015-01-01');

				it("works on true", function(){
					expect( y.isBetween( x, z ) ).toBeTrue();
				});
				it("works on false", function(){
					expect( x.isBetween( y, z ) ).toBeFalse();
				});
			});

			describe("isDST", function(){
				it("is a simple wrapper of core Java functionality, without need of testing", function(){});
			});

		});

	}

}
