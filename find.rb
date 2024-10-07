require "csv"
require "fileutils"
require "tempfile"
require "geocoder"

Geocoder.configure(
  # Geocoding options
  http_headers: { 'User-Agent' => 'hello@geocoding.com' },
  timeout: 5 # geocoding service timeout (secs)
  # lookup: :nominatim,         # name of geocoding service (symbol)
  # ip_lookup: :ipinfo_io,      # name of IP address geocoding service (symbol)
  # language: :fr,              # ISO-639 language code
  # use_https: false,           # use HTTPS for lookup requests? (if supported)
  # http_proxy: nil,            # HTTP proxy server (user:pass@host:port)
  # https_proxy: nil,           # HTTPS proxy server (user:pass@host:port)
  # api_key: nil,               # API key for geocoding service
  # cache: nil,                 # cache object (must respond to #[], #[]=, and #del)

  # Exceptions that should not be rescued by default
  # (if you want to implement custom error handling);
  # supports SocketError and Timeout::Error
  # always_raise: [],

  # Calculation options
  # units: :km,                 # :km for kilometers or :mi for miles
  # distances: :linear          # :spherical or :linear

  # Cache configuration
  # cache_options: {
  #   expiration: 2.days,
  #   prefix: 'geocoder:'
  # }
)


class FindCoordinates
    
  def checkAndPopulateCoordinates(csvFile) 
    # ex : read headers and add them to output
    fullHeaders = CSV.foreach(csvFile).first
    fullHeaders.append("latitude")
    fullHeaders.append("longitude")
    CSV.open("output.csv", "w+",:write_headers=> true, :headers => fullHeaders) do |temp_row|
            CSV.foreach(csvFile, headers: :first_row) do |row|
            # Vérifiez si les coordonnées existent déjà dans la ligne CSV
            #puts row
            latitude = row["latitude"].nil? || row["latitude"].empty?
            longitude = row["longitude"].nil? || row["longitude"].empty?
            # Si les coordonnées ne sont pas présentes dans le CSV
                if (latitude || longitude)
                  location_elements =[]
                  for i in fullHeaders do
                    location_elements.append(row[i])
                  end
                  location_elements.shift
                  location_elements.pop(2)
                  location_elements.reject!(&:empty?)
                coordinates = fetch_coordinates(location_elements.compact.join(', '))
                #puts coordinates
                latitude, longitude = coordinates 
                    if latitude.nil? ==false && longitude.nil? == false
                        row << latitude
                        row << longitude
                        #puts row
                        temp_row << row
                    end
                end
              end
          end
      end

    def fetch_coordinates(location_elements)
        puts "Processing location_query #{location_elements.inspect}"
        begin
          result = Geocoder.search(location_elements).first
          return result&.coordinates if result&.coordinates.nil? == false
        rescue Geocoder::Error => e
          puts "Geocoder error: #{e.message}"

        sleep(1)
      end
      nil
    end
  end