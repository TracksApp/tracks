
require 'date'
require 'ParseDate'

module ICal

SECONDS_PER_DAY = 24 * 60 * 60

class ICalReader
	@@iCalFolder = "/Users/jchappell/Library/Calendars"
		
	def initialize(calendarName = nil)
		@events = []
		@iCalFiles = Dir[@@iCalFolder + "/*.ics"]
		@iCalFiles.sort! {|x, y| x.downcase <=> y.downcase}
		if calendarName then
			fullName = @@iCalFolder + "/" + calendarName + ".ics"
			@iCalFiles = @iCalFiles.select {|name| name == fullName}
		end
	end
	
	def calendars
		@iCalFiles.collect {|name| File.basename(name, ".ics")}
	end
	
	def readEvents
		@events = []
		@iCalFiles.each do |fileName|
			lines = File.readlines(fileName);
			inEvent = false
			eventLines = []
			lines.each do |line|
				if line =~ /^BEGIN:VEVENT/ then
					inEvent = true
					eventLines = []
				end
				
				if inEvent
					eventLines << line
					if line =~ /^END:VEVENT/ then
						inEvent = false
						@events << parseEvent(eventLines)
					end
				end
			end
		end
		@events
	end
	
	def parseEvent(lines)
		event = ICalEvent.new()
		startDate = nil
		rule = nil
		
		lines.each do |line|
			if line =~ /^SUMMARY:(.*)/ then
				event.summary = $1
			elsif line =~ /^DTSTART;.*:(.*).*/ then
				startDate = parseDate($1)
			elsif line =~ /^EXDATE.*:(.*)/ then
				event.addExceptionDate(parseDate($1))
			elsif line =~ /^RRULE:(.*)/ then
				rule = $1
			end
		end
		
		event.startDate = startDate
		event.addRecurrenceRule(rule)
		event
	end
	
	def parseDate(dateStr)
		# We constrain the year to 1970 because Time won't handle lesser years
		# If it is less than 1970 then its probably a birthday or something
		# in which case, we don't really care about the year
		year = dateStr[0,4].to_i
		year = 1970 if year < 1970

		month = dateStr[4,2].to_i
		day = dateStr[6,2].to_i
		hour = dateStr[9,2].to_i
		minute = dateStr[11,2].to_i
		Time.local(year, month, day, hour, minute)
	end
	
	def events
		readEvents if @events == []
		@events
	end
	
	def selectEvents(&predicate)
		#
		# The start date of each event could be different due to recurring events
		# Since we can assume the date is the same for all events, we just compare
		# the times when sorting
		#
		now = Time.now
		events.select(&predicate).sort do |event1, event2| 
			time1 = Time.local(now.year, now.month, now.day, event1.startDate.hour, 
				event1.startDate.min)
			time2 = Time.local(now.year, now.month, now.day, event2.startDate.hour, 
				event2.startDate.min)
			time1 <=> time2
		end
	end
	
	def todaysEvents
		#events.select {|event| event.startsToday? }
		selectEvents {|event| event.startsToday? }
	end
	
	def tomorrowsEvents
		#events.select {|event| event.startsTomorrow? }
		selectEvents {|event| event.startsTomorrow?}
	end
	
	def eventsFor(date)
		#events.select {|event| event.startsOn?(date)}
		selectEvents {|event| event.startsOn?(date)}
	end
end

class DateParser
	# Given a date as a string, returns a Time object
	def DateParser.parse(dateStr)
		dateValues = ParseDate::parsedate(dateStr)
		Time.local(*dateValues[0, 3])
	end
	
	def DateParser.format(date)
		date.strftime("%m/%d/%Y")
	end
end

class ICalEvent

	def initialize
		@exceptionDates = []
	end
	
	def <=>(otherEvent)
		return @startDate <=> otherEvent.startDate
	end
	
	def addExceptionDate(date)
		@exceptionDates << date
	end
	
	def addRecurrenceRule(rule)
		@dateSet = DateSet.new(@startDate, rule)
	end
	
	def startsToday?
		startsOn?(Time.now)
	end
	
	def startsTomorrow?
		tomorrow = Time.now + SECONDS_PER_DAY;
		startsOn?(tomorrow)
	end
	
	def startsOn?(date)
		(startDate.year == date.year and startDate.month == date.month and 
			startDate.day == date.day) or @dateSet.includes?(date)
	end
	
	def to_s
		"#{@startDate.strftime("%m/%d/%Y (%I:%M %p)")} - #{@summary}"
	end
	
	def startTime
		@startDate
	end
	
	attr_accessor :startDate, :summary
end

class DateSet
	
	def initialize(startDate, rule)
		@startDate = startDate
		@frequency = nil
		@count = nil
		@untilDate = nil
		@byMonth = nil
		@byDay = nil
		parseRecurrenceRule(rule)
	end
	
	def parseRecurrenceRule(rule)
	
		if rule =~ /FREQ=(.*?);/ then
			@frequency = $1
		end
		
		if rule =~ /COUNT=(\d*)/ then
			@count = $1.to_i
		end
		
		if rule =~ /UNTIL=(.*?);/ then
			@untilDate = DateParser.parse($1)
			#puts @untilDate
		end
		
		if rule =~ /INTERVAL=(\d*)/ then
			@interval = $1.to_i
		end

		if rule =~ /BYMONTH=(.*?);/ then
			@byMonth = $1
		end

		if rule =~ /BYDAY=(.*?);/ then
			@byDay = $1
			#puts "byDay = #{@byDay}"
		end
	end
	
	def to_s
		puts "#<DateSet: starts: #{@startDate.strftime("%m/%d/%Y")}, occurs: #{@frequency}, count: #{@count}, until: #{@until}, byMonth: #{@byMonth}, byDay: #{@byDay}>"
	end
	
	def includes?(date)
		return true if date == @startDate
		return false if @untilDate and date > @untilDate
		
		case @frequency
			when 'DAILY'
				#if @untilDate then
				#	return (@startDate..@untilDate).include?(date)
				#end
				increment = @interval ? @interval : 1
				d = @startDate
				counter = 0
				until d > date
					
					if @count then
						counter += 1
						if counter >= @count
							return false
						end
					end

					d += (increment * SECONDS_PER_DAY)
					if 	d.day == date.day and 
						d.year == date.year and 
						d.month == date.month then
						return true
					end

				end
				
			when 'WEEKLY'
				return true if @startDate.wday == date.wday
				
			when 'MONTHLY'
				
			when 'YEARLY'
		end
		
		false
	end
	
	attr_reader :frequency	
	attr_accessor :startDate
end

if $0 == __FILE__ then
	#reader = ICalReader.new("Test")
	reader = ICalReader.new
	
	puts
	puts "Today"
	puts "====="
	puts reader.todaysEvents
	
	puts
	puts "Tomorrow"
	puts "========"
	puts reader.tomorrowsEvents
	
	puts
	puts "08/14/2003 Events"
	puts "================="
	puts reader.eventsFor(Time.local(2003, 8, 14))
	puts
end

end
