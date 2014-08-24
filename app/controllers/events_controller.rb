require 'csv'
class EventsController < ApplicationController

  def dashboard
    @events = Event.all

    @all_events_by_day = []
    @days = []
    @actors_in_past_days = {}
    @types_in_past_days = {}

    number_of_days = 30
    number_of_days.times do |number_of|
      events = Event.where(:event_date => number_of.days.ago.to_date)

      events.each do |event|
        if @types_in_past_days.include?(event.event_type)
          @types_in_past_days[event.event_type] += 1
        else
          @types_in_past_days.merge!({ event.event_type => 1})
        end

        if @actors_in_past_days.include?(event.actor1)
          @actors_in_past_days[event.actor1] += 1
        else
          @actors_in_past_days.merge!({ event.actor1 => 1})
        end

        if @actors_in_past_days.include?(event.actor2)
          @actors_in_past_days[event.actor2] += 2
        else
          @actors_in_past_days.merge!({ event.actor2 => 1})
        end
      end

      @all_events_by_day << events.count
      @days << number_of.days.ago.to_date.strftime("%m/%d/%Y")
    end

    colors = ["#F7464A", "#FF5A5E", 
              "#46BFBD", "#5AD3D1", 
              "#FDB45C", "#FFC870", 
              "#0C873F", "#12E369", 
              "#9D12E3", "#12E369",
              "#128FE3", "#3BA0E3",
              "#E0620D", "#E39C6D",
              "#E39C6D", "#F2949D",
              "#266331", "#60E679",
              "#F7464A", "#FF5A5E", 
              "#46BFBD", "#5AD3D1", 
              "#FDB45C", "#FFC870", 
              "#0C873F", "#12E369", 
              "#9D12E3", "#12E369",
              "#128FE3", "#3BA0E3",
              "#E0620D", "#E39C6D",
              "#E39C6D", "#F2949D",
              "#F7464A", "#FF5A5E", 
              "#46BFBD", "#5AD3D1", 
              "#FDB45C", "#FFC870", 
              "#0C873F", "#12E369", 
              "#9D12E3", "#12E369",
              "#128FE3", "#3BA0E3",
              "#E0620D", "#E39C6D",
              "#E39C6D", "#F2949D",
              "#266331", "#60E679",
              "#F7464A", "#FF5A5E", 
              "#46BFBD", "#5AD3D1", 
              "#FDB45C", "#FFC870", 
              "#0C873F", "#12E369", 
              "#9D12E3", "#12E369",
              "#128FE3", "#3BA0E3",
              "#E0620D", "#E39C6D",
              "#E39C6D", "#F2949D",
              "#F7464A", "#FF5A5E", 
              "#46BFBD", "#5AD3D1", 
              "#FDB45C", "#FFC870", 
              "#0C873F", "#12E369", 
              "#9D12E3", "#12E369",
              "#128FE3", "#3BA0E3",
              "#E0620D", "#E39C6D",
              "#E39C6D", "#F2949D",
              "#266331", "#60E679",
              "#F7464A", "#FF5A5E", 
              "#46BFBD", "#5AD3D1", 
              "#FDB45C", "#FFC870", 
              "#0C873F", "#12E369", 
              "#9D12E3", "#12E369",
              "#128FE3", "#3BA0E3",
              "#E0620D", "#E39C6D",
              "#E39C6D", "#F2949D"
            ]
    i = 0 

    @actor_chart_array = []
    @actors_in_past_days.each {|key, value|
      @actor_chart_array.push({value:value, color:colors[i], highlight:colors[i+1], label:key})
      i += 2
    @actors_in_past_days = @actors_in_past_days.to_json
    } 

    i = 0

    @type_chart_array = []
    @types_in_past_days.each {|key, value|
      @type_chart_array.push({value:value, color:colors[i], highlight:colors[i+1], label:key})
      i += 2
    } 
      

    @days = @days.reverse
    @all_events_by_day = @all_events_by_day.reverse.to_json
    
    @event_locations = []
    @events.each do |event| 
      @event_locations << {lat: event.latitude, lng: event.longitude, count: 1}
    end
    @event_locations = @event_locations.to_json


  end

  def index
    @events = Event.all
  end

  def show
    @event = Event.find_by(:id => params[:id])

    @map_url = "http://maps.googleapis.com/maps/api/staticmap?zoom=4&size=300x280&maptype=roadmap>#{@event.event_location}"
  end

  def countries
    @events = Event.all
    # @countries = @events.map(&:country).uniq
    @countries = Event.uniq.pluck(:country)
  end

  def actors
    @events = Event.all

    actor1s = Event.uniq.pluck(:actor1).compact.map(&:capitalize)
    actor2s = Event.uniq.pluck(:actor2).compact.map(&:capitalize)
    @actors = (actor1s+actor2s).uniq.sort
  end

  def by_country
    @country =  params[:country]

    @events_by_day = []
    @days = []
    number_of_days = 240
    number_of_days.times do |number_of|
      events = Event.where(:country => params[:country], :event_date => number_of.days.ago.to_date)
      @events_by_day << events.count
      @days << number_of.days.ago.to_date.strftime("%m/%d/%Y")
    end
    @events_by_day = @events_by_day.reverse
    @days = @days.reverse
    @count = 0

    @each_month = []
    months = ["", "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
    @days.each do |day_label|
      if day_label =~ /[0-9]\/01\/[0-9]/
        date = day_label.split("/")
        @each_month << "#{months[date[0].to_i]} #{date[1]}, #{date[2]}"
      else 
        @each_month << ""
      end
    end
  end

  def by_actor
    @actor =  params[:actor]

    @events_by_day = []
    @days = []
    number_of_days = 240
    number_of_days.times do |number_of|
      events = (Event.where(:actor1 => params[:actor], :event_date => number_of.days.ago.to_date) + Event.where(:actor2 => params[:actor], :event_date => number_of.days.ago.to_date)).uniq.compact
      @events_by_day << events.count
      @days << number_of.days.ago.to_date.strftime("%m/%d/%Y")
    end
    @events_by_day = @events_by_day.reverse
    @days = @days.reverse
    @count = 0

    @each_month = []
    months = ["", "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
    @days.each do |day_label|
      if day_label =~ /[0-9]\/01\/[0-9]/
        date = day_label.split("/")
        @each_month << "#{months[date[0].to_i]} #{date[1]}, #{date[2]}"
      else 
        @each_month << ""
      end
    end
  end

  end

  def new
  end

  def create
  end

  def upload
  end

  def import
    @new_events = params[:spreadsheet_as_csv]
    count = 0
    CSV.foreach(@new_events.path, :headers => true) do |row|
      count += 1
      begin
        Event.create(:event_date => row['EVENT_DATE'], 
                   :event_type => row['EVENT_TYPE'], 
                   :actor1 => row['ACTOR1'], 
                   :actor2 => row['ACTOR2'], 
                   :year => row['YEAR'].to_i, 
                   :country => row['COUNTRY'], 
                   :total_fatalities => row['TOTAL_FATALITIES'].to_i,
                   :latitude => row['LATITUDE'],
                   :longitude => BigDecimal(row['LONGITUDE']), 
                   :source => BigDecimal(row['SOURCE']), 
                   :notes => row['NOTES'], 
                   :interaction => row['INTERACTION'].to_i)
      rescue
        puts "MALFORMED ROW: #{count}" 
      end
    end
  end



