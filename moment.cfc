/*
	MOMENT.CFC
	-------------------
	Inspired by (but not a strict port of) moment.js: http://momentjs.com/
	With help from: @seancorfield, @ryanguill
	And contributions (witting or otherwise) from:
	 - Dan Switzer: https://github.com/CounterMarch/momentcfc/issues/5
	 - Ryan Heldt: http://www.ryanheldt.com/post.cfm/working-with-fuzzy-dates-and-times
	 - Ben Nadel: http://www.bennadel.com/blog/2501-converting-coldfusion-date-time-values-into-iso-8601-time-strings.htm
	 - Zack Pitts: http://stackoverflow.com/a/16309780/751
	 - Kenric Ashe: https://github.com/kenricashe/momentcfc
*/

component displayname="moment" {

	this.zone = '';
	this.time = '';
	this.utcTime = '';
	this.localTime = '';

	/*
		Call:
			new moment();
				-- for instance initalized to current time in current system TZ
			new moment( someTimeValue );
				-- for instance initialized to someTimeValue in current system TZ
			new moment( someTimeValue, someTZID )
				-- for instance initialized to someTimeValue in someTZID TZ
	*/
	public function init( time = now(), zone = getSystemTZ() ) {
		this.time = (time contains '{ts') ? time : parseDateTimeSafe( arguments.time );
		this.zone = zone;
		this.utc_conversion_offset = getTargetOffsetDiff( getSystemTZ(), zone, time );
		this.utcTime = TZtoUTC( arguments.time, arguments.zone );
		this.localTime = UTCtoTZ( this.utcTime, getSystemTZ() );
		return this;
	}

	//===========================================
	//MUTATORS
	//===========================================

	public function utc() hint="convert datetime to utc zone" {
		this.time = this.utcTime;
		this.zone = 'UTC';
		return this;
	}

	public function tz( required string zone ) hint="convert datetime to specified zone" {
		// this.utc_conversion_offset = getZoneCurrentOffset( arguments.zone ) * 1000;
		this.utc_conversion_offset = getTargetOffsetDiff( getSystemTZ(), this.zone, this.time );
		this.time = UTCtoTZ( this.utcTime, arguments.zone );
		this.zone = arguments.zone;
		return this;
	}

	public function add( required numeric amount, required string part ){
		part = canonicalizeDatePart( part, 'dateAdd' );
		this.time = dateAdd( part, amount, this.time );
		this.utcTime = TZtoUTC( this.time, this.zone );
		this.localTime = UTCtoTZ( this.utcTime, getSystemTZ() );
		return this;
	}

	public function subtract( required numeric amount, required string part ){
		return add( -1 * amount, part );
	}

	public function startOf( required string part ){
		part = canonicalizeDatePart(part, "startOf");
		var dest = '';

		switch (part){
			case 'year':
				dest = createDateTime(year(this.localTime),1,1,0,0,0);
				break;
			case 'quarter':
				dest = createDateTime(year(this.localTime),(int((month(this.localTime)-1)/3)+1)*3-2,1,0,0,0);
				break;
			case 'month':
				dest = createDateTime(year(this.localTime),month(this.localTime),1,0,0,0);
				break;
			case 'week':
				dest = createDateTime(year(this.localTime),month(this.localTime),day(this.localTime),0,0,0);
				dest = dateAdd("d", (dayOfWeek(dest)-1)*-1, dest);
				break;
			case 'day':
				dest = createDateTime(year(this.localTime),month(this.localTime),day(this.localTime),0,0,0);
				break;
			case 'hour':
				dest = createDateTime(year(this.localTime),month(this.localTime),day(this.localTime),hour(this.localTime),0,0);
				break;
			case 'minute':
				dest = createDateTime(year(this.localTime),month(this.localTime),day(this.localTime),hour(this.localTime),minute(this.localTime),0);
				break;
			default:
				throw(message="Invalid date part value, expected one of: year, quarter, month, week, day, hour, minute; or one of their acceptable aliases (see dateTimeFormat docs)");
		}

		return init( dest, this.zone );
	}

	public function endOf(required string part) {
		part = canonicalizeDatePart(part, "startOf");

		var dest = '';
		switch (part){
			case 'year':
				dest = createDateTime(year(this.localTime),12,31,23,59,59);
				break;
			case 'quarter':
				dest = createDateTime(year(this.localTime),(int((month(this.localTime)-1)/3)+1)*3,1,23,59,59); //first day of last month of quarter (e.g. 12/1)
				dest = dateAdd('m', 1, dest); //first day of following month
				dest = dateAdd('d', -1, dest); //last day of last month of quarter
				break;
			case 'month':
				dest = createDateTime(year(this.localTime),month(this.localTime),1,23,59,59); //first day of month
				dest = dateAdd('m', 1, dest); //first day of following month
				dest = dateAdd('d', -1, dest); //last day of target month
				break;
			case 'week':
				dest = createDateTime(year(this.localTime),month(this.localTime),day(this.localTime),23,59,59);
				dest = dateAdd("d", (7-dayOfWeek(dest)), dest);
				break;
			case 'day':
				dest = createDateTime(year(this.localTime),month(this.localTime),day(this.localTime),23,59,59);
				break;
			case 'hour':
				dest = createDateTime(year(this.localTime),month(this.localTime),day(this.localTime),hour(this.localTime),59,59);
				break;
			case 'minute':
				dest = createDateTime(year(this.localTime),month(this.localTime),day(this.localTime),hour(this.localTime),minute(this.localTime),59);
				break;
			default:
				throw(message="Invalid date part value, expected one of: year, quarter, month, week, day, hour, minute; or one of their acceptable aliases (see dateTimeFormat docs)");
		}

		return init( dest, this.zone );
	}

	//===========================================
	//STATICS
	//===========================================

	public moment function clone() hint="returns a new instance with the same time & zone" {
		return new moment( this.time, this.zone );
	}

	public moment function min( required moment a, required moment b ) hint="returns whichever moment came first" {
		if ( a.isBefore( b ) ){
			return a;
		}
		return b;
	}

	public moment function max( required moment a, required moment b ) hint="returns whichever moment came last" {
		if ( a.isAfter( b ) ){
			return a;
		}
		return b;
	}

	public numeric function diff( required moment b, part = 'seconds' ) hint="get the difference between the current date and the specified date" {
		part = canonicalizeDatePart( part, 'dateDiff' );
		if (part == 'L'){ //custom support for millisecond diffing... because adobe couldn't be bothered to support it themselves
			return b.epoch() - this.epoch();
		}
		return dateDiff( part, this.getDateTime(), b.getDateTime() );
	}

	public function getZoneCurrentOffset( required string zone ) hint="returns the offset in seconds (considering DST) of the specified zone" {
		return getTZ( arguments.zone ).getOffset( getSystemTimeMS() ) / 1000;
	}

	public string function getSystemTZ(){
		return createObject('java', 'java.util.TimeZone').getDefault().getId();
	}

	public struct function getZoneTable(){
		var tz;
		var list = createObject('java', 'java.util.TimeZone').getAvailableIDs();
		var data = [:]; // ordered struct
		for (tz in list){
			//display *CURRENT* offsets
			var ms = getTZ(tz).getOffset(getSystemTimeMS());
			data[tz] = readableOffset(ms);
		}
		return data;
	}

	public function getArbitraryTimeOffset( required time, required string zone ) hint="returns what the offset was at that specific moment"{
		var timezone = getTZ( zone );
		//can't use a moment for this math b/c it would cause infinite recursion: constructor uses this method
		var epic = createDateTime(1970, 1, 1, 0, 0, 0);
		var parsedTime = parseDateTimeSafe( arguments.time );
		var seconds = timezone.getOffset( javacast('long', dateDiff('s', epic, parsedTime)*1000) ) / 1000;
		return seconds;
	}

	//===========================================
	//TERMINATORS
	//===========================================

	public function format( required string mask ) hint="return datetime formatted with specified mask (dateTimeFormat mask rules)" {
		switch( mask ){
			case 'mysql':
				mask = 'yyyy-mm-dd HH:nn:ss';
				break;
			case 'iso8601':
			case 'mssql':
				return dateTimeFormat(this.time, 'yyyy-mm-dd') & 'T' & dateTimeFormat(this.time, 'HH:nn:ss') & 'Z';
			default:
				mask = mask;
		}

		return dateTimeFormat( this.localTime, mask, this.zone );
	}

	public function from( required moment compare ) hint="returns fuzzy-date string e.g. 2 hours ago" {
		var base = this.clone().utc();
		var L = this.min( base, compare.clone().utc() ).getDateTime();
		var R = this.max( base, compare.clone().utc() ).getDateTime();
		var diff = 0;
		//Seconds
		if (dateDiff('s', L, R) < 60){
			return 'Just now';
		}
		//Minutes
		diff = dateDiff('n', L, R);
		if (diff < 60){
			return diff & " minute#(diff gt 1 ? 's' : '')# ago";
		}
		//Hours
		diff = dateDiff('h', L, R);
		if (diff < 24){
			return diff & " hour#(diff gt 1 ? 's' : '')# ago";
		}
		//Days
		diff = dateDiff('d', L, R);
		if (diff < 7){
			if (diff < 2){
				return 'Yesterday';
			}else if (diff >= 2){
				return diff & ' days ago';
			}
		}
		//Weeks
		diff = dateDiff('ww', L, R);
		if (diff == 1){
			return '1 week ago';
		}else if (diff lte 4){
			return diff & ' weeks ago';
		}
		//Months/Years
		diff = dateDiff('m', L, R);
		if (diff < 12){
			return diff & " month#(diff gt 1 ? 's' : '')# ago";
		}else if (diff == 12){
			return 'Last year';
		}else{
			diff = dateDiff('yyyy', L, R);
			return diff & " year#(diff gt 1 ? 's' : '')# ago";
		}
	}

	public function fromNow() {
		var nnow = new moment().clone().utc();
		return from( nnow );
	}

	public numeric function epoch() hint="returns the number of milliseconds since 1/1/1970 (local). Call .utc() first to get utc epoch" {
		/*
			It seems that we can't get CF to give us an actual UTC datetime object without using DateConvert(), which we
			can not rely on, because it depends on the system time being the local time converting from/to. Instead, we've
			devised a system of detecting the target time zone's offset and using it here (the only place it seems necessary)
			to return the expected epoch values.
		*/
		return javacast("bigdecimal",this.clone().getDateTime().getTime() - this.utc_conversion_offset);
	}

	public function getDateTime() hint="return raw datetime object in current zone" {
		return this.time;
	}

	public string function getZone() hint="return the current zone" {
		return this.zone;
	}

	public numeric function getOffset() hint="returns the offset in seconds (considering DST) of the current moment" {
		return getArbitraryTimeOffset( this.time, this.zone );
	}

	public function year( newYear = '' ){
		if ( newYear == '' ){
			return getDatePart( 'year' );
		}else{
			return init(
				time: createDateTime( newYear, month(this.time), day(this.time), hour(this.time), minute(this.time), second(this.time) )
				,zone: this.zone
			);
		}
	}

	public function month( newMonth = '' ){
		if ( newMonth == '' ){
			return getDatePart( 'month' );
		}else{
			return init(
				time: createDateTime( year(this.time), newMonth, day(this.time), hour(this.time), minute(this.time), second(this.time) )
				,zone: this.zone
			);
		}
	}

	public function day( newDay = '' ){
		if ( newDay == '' ){
			return getDatePart( 'day' );
		}else{
			return init(
				time: createDateTime( year(this.time), month(this.time), newDay, hour(this.time), minute(this.time), second(this.time) )
				,zone: this.zone
			);
		}
	}

	public function hour( newHour = '' ){
		if ( newHour == '' ){
			return getDatePart( 'hour' );
		}else{
			return init(
				time: createDateTime( year(this.time), month(this.time), day(this.time), newHour, minute(this.time), second(this.time) )
				,zone: this.zone
			);
		}
	}

	public function minute( newMinute = '' ){
		if ( newMinute == '' ){
			return getDatePart( 'minute' );
		}else{
			return init(
				time: createDateTime( year(this.time), month(this.time), day(this.time), hour(this.time), newMinute, second(this.time) )
				,zone: this.zone
			);
		}
	}

	public function second( newSecond = '' ){
		if ( newSecond == '' ){
			return getDatePart( 'second' );
		}else{
			return init(
				time: createDateTime( year(this.time), month(this.time), day(this.time), hour(this.time), minute(this.time), newSecond )
				,zone: this.zone
			);
		}
	}

	//===========================================
	//QUERY
	//===========================================

	public boolean function isBefore( required moment compare, part = 'seconds' ) {
		part = canonicalizeDatePart( part, 'dateCompare' );
		return (dateCompare( this.time, compare.getDateTime(), part ) == -1);
	}

	public boolean function isSame( required moment compare, part = 'seconds' ) {
		part = canonicalizeDatePart( part, 'dateCompare' );
		return (dateCompare( this.time, compare.getDateTime(), part ) == 0);
	}

	public boolean function isAfter( required moment compare, part = 'seconds' ) {
		part = canonicalizeDatePart( part, 'dateCompare' );
		return (dateCompare( this.time, compare.getDateTime(), part ) == 1);
	}

	public boolean function isBetween( required moment a, required moment c, part = 'seconds' ) {
		part = canonicalizeDatePart( part, 'dateCompare' );
		if ( isBefore(c, part) && isAfter(a, part) ){
			return true;
		}else if ( isBefore(a, part) && isAfter(c, part) ){
			return true;
		}
		return false;
	}

	public boolean function isDST() {
		var dt = createObject('java', 'java.util.Date').init( this.epoch() );
		return getTZ( this.zone ).inDayLightTime( dt );
	}

	public date function epochTimeToDate(epoch) {
		return createObject( "java", "java.util.Date" ).init( javaCast( "long", epoch ) );
	}

	//===========================================
	//INTERNAL HELPERS
	//===========================================

	private function getSystemTimeMS(){
		return createObject('java', 'java.lang.System').currentTimeMillis();
	}

	private function getTZ( id ){
		return createObject('java', 'java.util.TimeZone').getTimezone( id );
	}

	private function TZtoUTC( time, tz = getSystemTZ() ){
		var parsedTime = parseDateTimeSafe( time );
		var seconds = getArbitraryTimeOffset( parsedTime, tz );
		return dateAdd( 's', -1 * seconds, parsedTime );
	}

	private function UTCtoTZ( required time, required string tz ){
		var parsedTime = parseDateTimeSafe( time );
		var seconds = getArbitraryTimeOffset( parsedTime, tz );
		return dateAdd( 's', seconds, parsedTime );
	}

	private function readableOffset( offset ){
		var h = offset / 1000 / 60 / 60; //raw hours (decimal) offset
		var hh = fix( h ); //int hours
		var mm = ( hh == h ? ':00' : ':' & abs(round((h-hh)*60)) ); //hours modulo used to determine minutes
		var rep = ( h >= 0 ? '+' : '' ) & hh & mm;
		return rep;
	}

	private function canonicalizeDatePart( part, method = 'dateAdd' ){
		var isDateAdd = (lcase(method) == 'dateadd');
		var isDateDiff = (lcase(method) == 'datediff');
		var isDateCompare = (lcase(method) == 'datecompare');
		var isStartOf = (lcase(method) == 'startof');

		switch( lcase(arguments.part) ){
			case 'years':
			case 'year':
			case 'y':
				if (isStartOf) return 'year';
				return 'yyyy';
			case 'quarters':
			case 'quarter':
			case 'q':
				if (isStartOf) return 'quarter';
				if (!isDateCompare) return 'q';
				throw(message='DateCompare doesn''t support Quarter precision');
			case 'months':
			case 'month':
			case 'm':
				if (isStartOf) return 'month';
				return 'm';
			case 'weeks':
			case 'week':
			case 'w':
				if (isStartOf) return 'week';
				if (!isDateCompare) return 'ww';
				throw(message='DateCompare doesn''t support Week precision');
			case 'days':
			case 'day':
			case 'd':
				if (isStartOf) return 'day';
				return 'd';
			case 'weekdays':
			case 'weekday':
			case 'wd':
				if (!isDateCompare) return 'w';
				throw(message='DateCompare doesn''t support Weekday precision');
			case 'hours':
			case 'hour':
			case 'h':
				if (isStartOf) return 'hour';
				return 'H';
			case 'minutes':
			case 'minute':
			case 'n':
				if (isStartOf) return 'minute';
				return 'n';
			case 'seconds':
			case 'second':
			case 's':
				if (isStartOf) return 'second';
				return 's';
			case 'milliseconds':
			case 'millisecond':
			case 'ms':
				if (isStartOf) return 'millisecond';
				if (isDateAdd) return 'L';
				if (isDateDiff) return 'L'; //custom support for ms diffing is provided interally, because adobe sucks
				throw(message='#method# doesn''t support Millisecond precision');
		}
		throw(message='Unrecognized Date Part: `#part#`');
	}

	private function getTargetOffsetDiff( sourceTZ, destTZ, time ) hint="used to calculate what the custom offset should be, based on current target and new target"{
		var startOffset = getArbitraryTimeOffset( time, sourceTZ );
		var targetOffset = getArbitraryTimeOffset( time, destTZ );
		return (targetOffset - startOffset) * 1000;
	}

	private function getDatePart( datePart ){
		return val( format( canonicalizeDatePart( arguments.datePart ) ) );
	}

	/**
	 * Parse datetime object or string argument with a series of fallbacks
	 * and support for edge cases such as bash "$(date)", Oracle, etc.
	 */
	private function parseDateTimeSafe( required any timeValue ) {
	
		// If it's already a proper date object with getTime() method, return it
		if ( isDate( arguments.timeValue ) ) {
			try {
				// Test if it has getTime() method (proper date object)
				arguments.timeValue.getTime();
				return arguments.timeValue;
			} catch ( any e ) {
				// Fall through to parsing logic if getTime() fails
			}
		}
		
		// Convert to string for processing
		var strdttm = toString(arguments.timeValue);

		// Replace Narrow No-Break Space (e.g. found in Java 19+ datetime to string output)
		strdttm = strdttm.replace(chr(8239), " ", "all");
		
		// Try Lucee native parseDateTime() first with original format
		try {
			var parsed = parseDateTime( strdttm );
			// Ensure the result is a proper date object
			if ( isDate( parsed ) ) {
				return parsed;
			}
		}
		// Try again with comma removal for formats like "9/20/22, 12:34 PM"
		catch ( any e ) {
			try {
				var strdttmNoCommas = replace( strdttm, ",", "", "all" );
				var parsed = parseDateTime( strdttmNoCommas );
				if ( isDate( parsed ) ) {
					return parsed;
				}
			} catch ( any e2 ) {
				// Continue to custom parsing if both attempts fail
			}
		}
		
		// Handle bash date format: Mon Mar  3 03:09:07 PST 2025
		var bashDatePattern = '^\w{3}\s+\w{3}\s+\d{1,2}\s+\d{2}:\d{2}:\d{2}\s+\w{3}\s+\d{4}$';
		
		if ( reFind( bashDatePattern, strdttm ) ) {
			// Convert bash date to ISO format
			var parts = listToArray( strdttm, ' ' );
			if ( arrayLen( parts ) == 6 ) {
				var monthMap = {
					'Jan': '01', 'Feb': '02', 'Mar': '03', 'Apr': '04',
					'May': '05', 'Jun': '06', 'Jul': '07', 'Aug': '08',
					'Sep': '09', 'Oct': '10', 'Nov': '11', 'Dec': '12'
				};
				
				var month = parts[2];
				var day = numberFormat( parts[3], '00' );
				var time = parts[4];
				var year = parts[6];
				
				if ( structKeyExists( monthMap, month ) ) {
					var isoFormat = year & '-' & monthMap[month] & '-' & day & ' ' & time;
					try {
						return parseDateTime( isoFormat );
					}
					catch ( any parseError ) {
						// Fall through to createDateTime if parseDateTime fails
					}
				}
			}
		}
		
		// Handle Oracle date format: 20-SEP-22 12.34.00.000000 PM
		var oracleDatePattern = '^\d{2}-\w{3}-\d{2}\s+\d{1,2}\.\d{2}\.\d{2}\.\d{6}\s+(AM|PM)$';
		
		if ( reFind( oracleDatePattern, strdttm ) ) {
			// Convert Oracle date to parseable format
			var parts = listToArray( strdttm, ' ' );
			if ( arrayLen( parts ) == 3 ) {
				var monthMap = {
					'JAN': '01', 'FEB': '02', 'MAR': '03', 'APR': '04',
					'MAY': '05', 'JUN': '06', 'JUL': '07', 'AUG': '08',
					'SEP': '09', 'OCT': '10', 'NOV': '11', 'DEC': '12'
				};
				
				var datePart = parts[1]; // 20-SEP-22
				var timePart = parts[2]; // 12.34.00.000000
				var ampm = parts[3]; // PM
				
				// Parse date part
				var dateComponents = listToArray( datePart, '-' );
				if ( arrayLen( dateComponents ) == 3 ) {
					var day = dateComponents[1];
					var month = uCase( dateComponents[2] );
					var year = '20' & dateComponents[3]; // Convert 2-digit to 4-digit year
					
					// Parse time part (remove microseconds)
					var timeComponents = listToArray( timePart, '.' );
					if ( arrayLen( timeComponents ) >= 3 ) {
						var hour = timeComponents[1];
						var minute = timeComponents[2];
						var second = timeComponents[3];
						// Ignore microseconds (timeComponents[4])
						
						if ( structKeyExists( monthMap, month ) ) {
							// Convert to standard format with AM/PM
							var standardFormat = monthMap[month] & '/' & day & '/' & year & ' ' & hour & ':' & minute & ':' & second & ' ' & ampm;
							try {
								return parseDateTime( standardFormat );
							}
							catch ( any parseError ) {
								// Fall through to createDateTime if parseDateTime fails
							}
						}
					}
				}
			}
		}
		
		// Handle syslog date format: Sep 20 12:34:00 (no year, assumes current year)
		var syslogDatePattern = '^\w{3}\s+\d{1,2}\s+\d{2}:\d{2}:\d{2}$';
		
		if ( reFind( syslogDatePattern, strdttm ) ) {
			// Convert syslog date to parseable format
			var parts = listToArray( strdttm, ' ' );
			if ( arrayLen( parts ) == 3 ) {
				var monthMap = {
					'Jan': '01', 'Feb': '02', 'Mar': '03', 'Apr': '04',
					'May': '05', 'Jun': '06', 'Jul': '07', 'Aug': '08',
					'Sep': '09', 'Oct': '10', 'Nov': '11', 'Dec': '12'
				};
				
				var month = parts[1]; // Sep
				var day = numberFormat( parts[2], '00' ); // 20
				var time = parts[3]; // 12:34:00
				
				// Use current year since syslog doesn't include year
				var currentYear = year( now() );
				
				if ( structKeyExists( monthMap, month ) ) {
					// Convert to ISO format
					var isoFormat = currentYear & '-' & monthMap[month] & '-' & day & ' ' & time;
					try {
						return parseDateTime( isoFormat );
					}
					catch ( any parseError ) {
						// Fall through to createDateTime if parseDateTime fails
					}
				}
			}
		}
		
		// Handle Apache log date format: [20/Sep/2022:12:34:00 -0700]
		var apacheLogPattern = '^\[\d{2}/\w{3}/\d{4}:\d{2}:\d{2}:\d{2}\s+[+-]\d{4}\]$';
		
		if ( reFind( apacheLogPattern, strdttm ) ) {
			// Remove brackets and convert Apache log date to parseable format
			var cleanedDate = mid( strdttm, 2, len( strdttm ) - 2 ); // Remove [ and ]
			var parts = listToArray( cleanedDate, ' ' ); // Split by space to separate date/time from timezone
			if ( arrayLen( parts ) == 2 ) {
				var dateTimePart = parts[1]; // 20/Sep/2022:12:34:00
				var timezonePart = parts[2]; // -0700
				
				// Split date and time parts
				var colonPos = find( ':', dateTimePart );
				if ( colonPos > 0 ) {
					var datePart = left( dateTimePart, colonPos - 1 ); // 20/Sep/2022
					var timePart = mid( dateTimePart, colonPos + 1, len( dateTimePart ) ); // 12:34:00
					
					var monthMap = {
						'Jan': '01', 'Feb': '02', 'Mar': '03', 'Apr': '04',
						'May': '05', 'Jun': '06', 'Jul': '07', 'Aug': '08',
						'Sep': '09', 'Oct': '10', 'Nov': '11', 'Dec': '12'
					};
					
					// Parse date part: 20/Sep/2022
					var dateComponents = listToArray( datePart, '/' );
					if ( arrayLen( dateComponents ) == 3 ) {
						var day = dateComponents[1]; // 20
						var month = dateComponents[2]; // Sep
						var year = dateComponents[3]; // 2022
						
						if ( structKeyExists( monthMap, month ) ) {
							// Convert to ISO format (ignore timezone for now)
							var isoFormat = year & '-' & monthMap[month] & '-' & numberFormat( day, '00' ) & ' ' & timePart;
							try {
								return parseDateTime( isoFormat );
							}
							catch ( any parseError ) {
								// Fall through to createDateTime if parseDateTime fails
							}
						}
					}
				}
			}
		}
		
		// Try using createDateTime as a last resort e.g. for query datetime values
		// This handles cases where the value looks like a date but isn't recognized as one
		try {
			// If strdttm looks like YYYY-MM-DD HH:mm:ss format
			if ( reFind( '^\d{4}-\d{2}-\d{2}\s+\d{2}:\d{2}:\d{2}', strdttm ) ) {
				var dateParts = listToArray( strdttm, ' ' );
				if ( arrayLen( dateParts ) >= 2 ) {
					var dateOnly = dateParts[1];
					var timeOnly = dateParts[2];
					
					var ymd = listToArray( dateOnly, '-' );
					var hms = listToArray( timeOnly, ':' );
					
					if ( arrayLen( ymd ) == 3 && arrayLen( hms ) >= 2 ) {
						var year = val( ymd[1] );
						var month = val( ymd[2] );
						var day = val( ymd[3] );
						var hour = val( hms[1] );
						var minute = val( hms[2] );
						var second = arrayLen( hms ) > 2 ? val( hms[3] ) : 0;
						
						return createDateTime( year, month, day, hour, minute, second );
					}
				}
			}
		}
		catch ( any createError ) {
			// Fall through to error if createDateTime also fails
		}
		
		// If all parsing attempts fail, throw descriptive error
		throw(
			type = 'moment.parseDateTimeSafe',
			message = 'Unable to parse date/time value: ' & strdttm,
			detail = 'This may be due to stricter date parsing in Java 19+. Value type: ' & getMetaData( arguments.timeValue ).getName() & '. Consider using a standard date format or ensure MariaDB datetime columns return proper date objects.'
		);
	}

}
